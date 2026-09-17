--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Usable Items & Inventory Abstraction (server)
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore.Items      — shared item registry mutations + usable-item callbacks
     LXRCore.Inventory  — one API, several providers:
        'core'           built-in slot inventory in PlayerData.items, persisted in
                         players.inventory. Also what the legacy lxr-inventory UI
                         drives (it reads PlayerData.items and calls the player
                         functions), so 'lxr-inventory' resolves to this provider.
        'rsg-inventory'  delegates to rsg-inventory exports
        'vorp_inventory' delegates to vorp_inventory exports (item subset)
     Inventory is never a hard dependency: with no inventory resource the core
     provider keeps items working headlessly.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Items = {}
LXRCore.Inventory = {}
local Items = LXRCore.Items
local Inventory = LXRCore.Inventory

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 SHARED ITEM REGISTRY
-- ═══════════════════════════════════════════════════════════════════════════════

local function broadcast(key, value)
    LXRCore.EmitClient(-1, 'lxr:client:shared', { legacy = 'LXRCore:Client:OnSharedUpdate', rsg = 'RSGCore:Client:OnSharedUpdate' }, 'Items', key, value)
    LXRCore.Emit('lxr:shared:updated', nil, 'Items', key, value)
    LXRCore.NotifyObjectUpdate()
end

function Items.Add(name, data)
    if type(name) ~= 'string' then return false, 'invalid_item_name' end
    name = name:lower()
    if LXRShared.Items[name] then return false, 'item_exists' end
    if type(data) ~= 'table' then return false, 'invalid_item_data' end
    data.name = data.name or name
    data.weight = tonumber(data.weight) or 0
    LXRShared.Items[name] = data
    broadcast(name, data)
    return true, 'success'
end

function Items.AddMany(list)
    if type(list) ~= 'table' then return false, 'invalid_item_data' end
    for key in pairs(list) do
        if type(key) ~= 'string' then return false, 'invalid_item_name', list[key] end
        if LXRShared.Items[key:lower()] then return false, 'item_exists', list[key] end
    end
    local added = {}
    for key, data in pairs(list) do
        key = key:lower()
        data.name = data.name or key
        data.weight = tonumber(data.weight) or 0
        LXRShared.Items[key] = data
        added[key] = data
    end
    LXRCore.EmitClient(-1, 'lxr:client:sharedMany', { legacy = 'LXRCore:Client:OnSharedUpdateMultiple', rsg = 'RSGCore:Client:OnSharedUpdateMultiple' }, 'Items', added)
    LXRCore.Emit('lxr:shared:updated', nil, 'Items', nil, added)
    LXRCore.NotifyObjectUpdate()
    return true, 'success', nil
end

function Items.Update(name, data)
    if type(name) ~= 'string' then return false, 'invalid_item_name' end
    name = name:lower()
    if not LXRShared.Items[name] then return false, 'item_not_exists' end
    data.name = data.name or name
    LXRShared.Items[name] = data
    broadcast(name, data)
    return true, 'success'
end

function Items.Remove(name)
    if type(name) ~= 'string' then return false, 'invalid_item_name' end
    name = name:lower()
    if not LXRShared.Items[name] then return false, 'item_not_exists' end
    LXRShared.Items[name] = nil
    broadcast(name, nil)
    return true, 'success'
end

function Items.Get(name)
    if type(name) ~= 'string' then return nil end
    return LXRShared.Items[name:lower()]
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🍞 USABLE ITEMS
-- ═══════════════════════════════════════════════════════════════════════════════

---Register a server-side handler: fn(source, item, ...) — `item` is the slot table.
function Items.RegisterUsable(name, fn)
    if type(name) ~= 'string' or type(fn) ~= 'function' then return false end
    LXRCore.UsableItems[name:lower()] = fn
    return true
end

function Items.UnregisterUsable(name)
    if type(name) ~= 'string' then return end
    LXRCore.UsableItems[name:lower()] = nil
end

function Items.CanUse(name)
    if type(name) ~= 'string' then return nil end
    return LXRCore.UsableItems[name:lower()]
end

---Invoke the usable handler after confirming the player really holds the item.
---@param source integer
---@param item table|string slot table (name, slot, amount, info) or item name
function Items.Use(source, item, ...)
    local player = LXRCore.Functions.GetPlayer(source)
    if not player then return false end
    local name = type(item) == 'table' and item.name or item
    if type(name) ~= 'string' then return false end
    name = name:lower()
    local handler = LXRCore.UsableItems[name]
    if not handler then return false end
    -- authoritative lookup: never trust the slot table sent by a client
    local held = Inventory.GetItem(source, name, type(item) == 'table' and tonumber(item.slot) or nil)
    if not held then held = Inventory.GetItem(source, name) end
    if not held or (tonumber(held.amount) or 0) <= 0 then
        LXRCore.Log.debug('items', 'use rejected: item not held', { source = source, item = name })
        return false
    end
    LXRCore.Metrics.Inc('items.use')
    local ok, err = pcall(handler, source, held, ...)
    if not ok then LXRCore.Log.error('items', ('usable handler for %s errored'):format(name), { error = tostring(err) }) end
    return ok
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎒 INVENTORY PROVIDER RESOLUTION
-- ═══════════════════════════════════════════════════════════════════════════════

Inventory.Provider = nil       -- 'core' | 'rsg-inventory' | 'vorp_inventory'
Inventory.Resource = nil       -- resource that owns the UI (informational)

local function started(res)
    return GetResourceState(res) == 'started'
end

function Inventory.Resolve()
    local want = Config.Inventory.provider or 'auto'
    local candidates = want == 'auto' and Config.Inventory.providers or { want }
    for _, id in ipairs(candidates) do
        if id == 'internal' or id == 'core' then
            Inventory.Provider, Inventory.Resource = 'core', nil
            break
        elseif id == 'lxr-inventory' and started(id) then
            Inventory.Provider, Inventory.Resource = 'core', 'lxr-inventory'
            break
        elseif (id == 'rsg-inventory' or id == 'vorp_inventory') and started(id) then
            Inventory.Provider, Inventory.Resource = id, id
            break
        end
    end
    if not Inventory.Provider then
        Inventory.Provider, Inventory.Resource = 'core', nil
    end
    LXRCore.Log.info('inventory', ('provider: %s%s'):format(Inventory.Provider, Inventory.Resource and (' (' .. Inventory.Resource .. ')') or ''))
    return Inventory.Provider
end

-- Re-resolve when an inventory resource starts after the core (start-order tolerant).
AddEventHandler('onResourceStart', function(res)
    if res == 'lxr-inventory' or res == 'rsg-inventory' or res == 'vorp_inventory' then
        SetTimeout(500, Inventory.Resolve)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧮 CORE PROVIDER — pure slot logic (unit-tested in tests/test_inventory.lua)
-- ═══════════════════════════════════════════════════════════════════════════════

local Core = {}

function Core.TotalWeight(items)
    local w = 0
    for _, it in pairs(items or {}) do
        if it then w = w + (tonumber(it.weight) or 0) * (tonumber(it.amount) or 0) end
    end
    return w
end

function Core.SlotsByItem(items, name)
    local out = {}
    for slot, it in pairs(items or {}) do
        if it and it.name == name then out[#out + 1] = slot end
    end
    table.sort(out)
    return out
end

function Core.FirstSlotByItem(items, name)
    local slots = Core.SlotsByItem(items, name)
    return slots[1]
end

function Core.FirstFreeSlot(items, maxSlots)
    for i = 1, maxSlots do
        if items[i] == nil then return i end
    end
    return nil
end

local function buildSlotItem(def, amount, slot, info)
    return {
        name = def.name, amount = amount, info = info or {}, label = def.label,
        description = def.description or '', weight = def.weight, type = def.type,
        unique = def.unique, useable = def.useable, image = def.image,
        shouldClose = def.shouldClose, slot = slot, combinable = def.combinable,
    }
end

---@return boolean ok, string|nil err
function Core.AddItem(player, name, amount, slot, info)
    name = tostring(name or ''):lower()
    local def = LXRShared.Items[name]
    if not def then return false, 'item_not_exist' end
    amount = math.floor(tonumber(amount) or 1)
    if amount <= 0 then return false, 'invalid_amount' end
    local pd = player.PlayerData
    local items = pd.items
    local maxWeight = tonumber(pd.weight) or Config.Player.maxWeight
    local maxSlots = tonumber(pd.slots) or Config.Player.maxSlots
    if Core.TotalWeight(items) + (def.weight or 0) * amount > maxWeight then return false, 'too_heavy' end

    info = type(info) == 'table' and info or {}
    if def.type == 'weapon' then
        info.serie = info.serie or (LXRShared.RandomInt(2) .. LXRShared.RandomStr(3) .. LXRShared.RandomInt(1) .. LXRShared.RandomStr(2) .. LXRShared.RandomInt(3) .. LXRShared.RandomStr(4))
        info.quality = info.quality or 100
    end

    if not def.unique then
        local target = slot
        if not target then target = Core.FirstSlotByItem(items, name) end
        if target and items[target] and items[target].name == name then
            items[target].amount = items[target].amount + amount
            return true, nil, target
        end
    end
    if slot and items[slot] then slot = nil end
    slot = slot or Core.FirstFreeSlot(items, maxSlots)
    if not slot then return false, 'too_heavy' end
    items[slot] = buildSlotItem(def, amount, slot, info)
    return true, nil, slot
end

---@return boolean ok, string|nil err
function Core.RemoveItem(player, name, amount, slot)
    name = tostring(name or ''):lower()
    amount = math.floor(tonumber(amount) or 1)
    if amount <= 0 then return false, 'invalid_amount' end
    local items = player.PlayerData.items
    if slot then
        local it = items[slot]
        if not it or it.name ~= name or it.amount < amount then return false, 'item_not_exist' end
        it.amount = it.amount - amount
        if it.amount <= 0 then items[slot] = nil end
        return true
    end
    -- remove across stacks; verify total first so the operation is all-or-nothing
    local total = 0
    for _, s in ipairs(Core.SlotsByItem(items, name)) do total = total + items[s].amount end
    if total < amount then return false, 'item_not_exist' end
    local remaining = amount
    for _, s in ipairs(Core.SlotsByItem(items, name)) do
        local take = math.min(items[s].amount, remaining)
        items[s].amount = items[s].amount - take
        if items[s].amount <= 0 then items[s] = nil end
        remaining = remaining - take
        if remaining <= 0 then break end
    end
    return true
end

function Core.GetItemByName(items, name)
    name = tostring(name or ''):lower()
    local slot = Core.FirstSlotByItem(items, name)
    return slot and items[slot] or nil
end

function Core.GetItemsByName(items, name)
    name = tostring(name or ''):lower()
    local out = {}
    for _, s in ipairs(Core.SlotsByItem(items, name)) do out[#out + 1] = items[s] end
    return out
end

function Core.Count(items, name)
    local n = 0
    for _, it in ipairs(Core.GetItemsByName(items, name)) do n = n + it.amount end
    return n
end

---Rebuild slot items from the JSON stored in players.inventory.
function Core.Deserialize(raw)
    local list = LXRShared.JsonDecode(raw, {})
    local items = {}
    for _, it in pairs(list) do
        if type(it) == 'table' and type(it.name) == 'string' then
            local def = LXRShared.Items[it.name:lower()]
            local slot = tonumber(it.slot)
            if def and slot then
                items[slot] = buildSlotItem(def, tonumber(it.amount) or 1, slot, type(it.info) == 'table' and it.info or {})
            end
        end
    end
    return items
end

function Core.Serialize(items)
    local out = {}
    for slot, it in pairs(items or {}) do
        if it and it.amount and it.amount > 0 then
            out[#out + 1] = { name = it.name, amount = it.amount, info = type(it.info) == 'table' and it.info or {}, type = it.type, slot = slot }
        end
    end
    return json.encode(out)
end

Inventory.CoreLogic = Core

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔌 PUBLIC INVENTORY API (provider-aware)
-- ═══════════════════════════════════════════════════════════════════════════════

local function rsg() return exports['rsg-inventory'] end
local function vorp() return exports['vorp_inventory'] end

local function player(source)
    return LXRCore.Functions.GetPlayer(source)
end

local function afterChange(p)
    p._dirty = true
    if not p.Offline then
        p.Functions.UpdatePlayerData()
        LXRCore.Emit('lxr:inventory:changed', { legacy = 'LXRCore:Server:OnInventoryUpdate' }, p.PlayerData.source)
    end
end

---@return table items loaded for a citizenid (called during login)
function Inventory.Load(source, citizenid)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, items = pcall(function() return rsg():LoadInventory(source, citizenid) end)
        return ok and items or {}
    end
    if Inventory.Provider == 'vorp_inventory' then
        return {} -- VORP keeps items in its own tables; PlayerData.items stays empty
    end
    local raw = LXRCore.DB.Scalar('SELECT inventory FROM players WHERE citizenid = ?', { citizenid })
    return Core.Deserialize(raw)
end

---Persist items (core provider writes players.inventory; RSG delegates).
function Inventory.Save(playerOrSource, offline)
    if Inventory.Provider == 'rsg-inventory' then
        pcall(function() rsg():SaveInventory(playerOrSource, offline) end)
        return
    end
    if Inventory.Provider == 'vorp_inventory' then return end
    local pd = offline and playerOrSource or (player(playerOrSource) and player(playerOrSource).PlayerData)
    if not pd then return end
    LXRCore.DB.UpdateAsync('UPDATE players SET inventory = ? WHERE citizenid = ?', { Core.Serialize(pd.items), pd.citizenid })
end

function Inventory.AddItem(source, name, amount, slot, info, reason)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, res = pcall(function() return rsg():AddItem(source, name, amount, slot, info, reason) end)
        return ok and res == true
    end
    if Inventory.Provider == 'vorp_inventory' then
        local ok, res = pcall(function() return vorp():addItem(source, name, amount, info) end)
        return ok and res ~= false
    end
    local p = player(source); if not p then return false, 'not_online' end
    local ok, err, usedSlot = Core.AddItem(p, name, amount, slot, info)
    if ok then
        afterChange(p)
        if Config.Compat.legacy.enabled then TriggerClientEvent('lxr-inventory:client:UpdateItems', source, usedSlot, p.PlayerData.items[usedSlot]) end
        LXRCore.Log.info('inventory', ('add %sx %s'):format(amount or 1, name), { source = source, slot = usedSlot, reason = reason, resource = LXRCore.Invoker() })
    end
    return ok, err
end

function Inventory.RemoveItem(source, name, amount, slot, reason)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, res = pcall(function() return rsg():RemoveItem(source, name, amount, slot, reason) end)
        return ok and res == true
    end
    if Inventory.Provider == 'vorp_inventory' then
        local ok, res = pcall(function() return vorp():subItem(source, name, amount) end)
        return ok and res ~= false
    end
    local p = player(source); if not p then return false, 'not_online' end
    local ok, err = Core.RemoveItem(p, name, amount, slot)
    if ok then
        afterChange(p)
        if Config.Compat.legacy.enabled then TriggerClientEvent('lxr-inventory:client:UpdateItems', source, slot, slot and p.PlayerData.items[slot] or nil) end
        LXRCore.Log.info('inventory', ('remove %sx %s'):format(amount or 1, name), { source = source, slot = slot, reason = reason, resource = LXRCore.Invoker() })
    end
    return ok, err
end

---@return table|nil slot item
function Inventory.GetItem(source, name, slot)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, res = pcall(function()
            if slot then return rsg():GetItemBySlot(source, slot) end
            return rsg():GetItemByName(source, name)
        end)
        if ok and res and (not name or res.name == name) then return res end
        return nil
    end
    if Inventory.Provider == 'vorp_inventory' then
        local ok, res = pcall(function() return vorp():getItemByName(source, name) end)
        if ok and res then return { name = name, amount = res.count or res.amount or 0, info = res.metadata, label = res.label } end
        return nil
    end
    local p = player(source); if not p then return nil end
    if slot then
        local it = p.PlayerData.items[slot]
        if it and (not name or it.name == name) then return it end
        return nil
    end
    return Core.GetItemByName(p.PlayerData.items, name)
end

function Inventory.GetItems(source)
    if Inventory.Provider == 'rsg-inventory' then
        local p = player(source); return p and p.PlayerData.items or {}
    end
    if Inventory.Provider == 'vorp_inventory' then
        local ok, res = pcall(function() return vorp():getUserInventoryItems(source) end)
        return ok and res or {}
    end
    local p = player(source); return p and p.PlayerData.items or {}
end

function Inventory.GetItemCount(source, name)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, n = pcall(function() return rsg():GetItemCount(source, name) end)
        return ok and tonumber(n) or 0
    end
    if Inventory.Provider == 'vorp_inventory' then
        local ok, n = pcall(function() return vorp():getItemCount(source, nil, name) end)
        return ok and tonumber(n) or 0
    end
    local p = player(source); if not p then return 0 end
    return Core.Count(p.PlayerData.items, name)
end

---HasItem(source, 'bread', 2) · HasItem(source, {'bread','water'}, 1) · HasItem(source, { bread = 2, water = 1 })
function Inventory.HasItem(source, items, amount)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, res = pcall(function() return rsg():HasItem(source, items, amount) end)
        return ok and res == true
    end
    if type(items) == 'string' then
        return Inventory.GetItemCount(source, items) >= (tonumber(amount) or 1)
    end
    if type(items) ~= 'table' then return false end
    for k, v in pairs(items) do
        if type(k) == 'string' then
            if Inventory.GetItemCount(source, k) < (tonumber(v) or 1) then return false end
        else
            if Inventory.GetItemCount(source, v) < (tonumber(amount) or 1) then return false end
        end
    end
    return true
end

function Inventory.CanCarry(source, name, amount)
    if Inventory.Provider == 'rsg-inventory' then
        local ok, res = pcall(function() return rsg():CanAddItem(source, name, amount) end)
        return ok and res == true
    end
    if Inventory.Provider == 'vorp_inventory' then
        local ok, res = pcall(function() return vorp():canCarryItem(source, name, amount) end)
        return ok and res == true
    end
    local p = player(source); if not p then return false end
    local def = LXRShared.Items[tostring(name):lower()]; if not def then return false end
    local pd = p.PlayerData
    return Core.TotalWeight(pd.items) + (def.weight or 0) * (tonumber(amount) or 1) <= (tonumber(pd.weight) or Config.Player.maxWeight)
end

function Inventory.SetMetadata(source, slot, info)
    if Inventory.Provider == 'rsg-inventory' then
        return pcall(function() return rsg():SetItemData(source, slot, 'info', info) end)
    end
    if Inventory.Provider == 'vorp_inventory' then
        return pcall(function() return vorp():setItemMetadata(source, slot, info) end)
    end
    local p = player(source); if not p then return false end
    local it = p.PlayerData.items[slot]; if not it then return false end
    it.info = type(info) == 'table' and info or {}
    afterChange(p)
    return true
end

function Inventory.ClearInventory(source, filterItems)
    if Inventory.Provider == 'rsg-inventory' then
        return pcall(function() rsg():ClearInventory(source, filterItems) end)
    end
    if Inventory.Provider == 'vorp_inventory' then
        return pcall(function() vorp():subAllItems(source) end)
    end
    local p = player(source); if not p then return false end
    local keep = {}
    if type(filterItems) == 'string' then keep[filterItems] = true
    elseif type(filterItems) == 'table' then for _, n in ipairs(filterItems) do keep[n] = true end end
    local items = {}
    for slot, it in pairs(p.PlayerData.items) do
        if keep[it.name] then items[slot] = it end
    end
    p.PlayerData.items = items
    afterChange(p)
    LXRCore.Log.info('inventory', 'inventory cleared', { source = source, resource = LXRCore.Invoker() })
    return true
end

function Inventory.SetInventory(source, items)
    local p = player(source); if not p then return false end
    if Inventory.Provider == 'rsg-inventory' then
        return pcall(function() rsg():SetInventory(source, items) end)
    end
    p.PlayerData.items = type(items) == 'table' and items or {}
    afterChange(p)
    return true
end

function Inventory.GetTotalWeight(items) return Core.TotalWeight(items) end
function Inventory.GetSlotsByItem(items, name) return Core.SlotsByItem(items, name) end
function Inventory.GetFirstSlotByItem(items, name) return Core.FirstSlotByItem(items, name) end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧩 RSG / QBR-SHAPED ALIASES & EXPORTS
-- ═══════════════════════════════════════════════════════════════════════════════

LXRCore.Functions.CreateUseableItem = Items.RegisterUsable
LXRCore.Functions.RegisterUsableItem = Items.RegisterUsable
LXRCore.Functions.CanUseItem = Items.CanUse
LXRCore.Functions.UseItem = Items.Use
LXRCore.Functions.HasItem = Inventory.HasItem
LXRCore.Functions.CanCarryItem = Inventory.CanCarry
LXRCore.Functions.AddItem = Items.Add          -- RSG semantics: registry add (not player add)
LXRCore.Functions.AddItems = Items.AddMany
LXRCore.Functions.UpdateItem = Items.Update
LXRCore.Functions.RemoveItem = Items.Remove
LXRCore.Player.GetTotalWeight = Core.TotalWeight
LXRCore.Player.GetSlotsByItem = Core.SlotsByItem
LXRCore.Player.GetFirstSlotByItem = Core.FirstSlotByItem
LXRCore.Player.SaveInventory = function(source) Inventory.Save(source, false) end
LXRCore.Player.SaveOfflineInventory = function(pd) Inventory.Save(pd, true) end

exports('CreateUseableItem', Items.RegisterUsable)
exports('RegisterUsableItem', Items.RegisterUsable)
exports('CanUseItem', Items.CanUse)
exports('UseItem', Items.Use)
exports('AddItem', Items.Add)
exports('AddItems', Items.AddMany)
exports('UpdateItem', Items.Update)
exports('RemoveItem', Items.Remove)
exports('GetItem', Items.Get)
exports('GetItems', function() return LXRShared.Items end)
exports('GetWeapons', function() return LXRShared.Weapons end)
exports('GetHorses', function() return LXRShared.Horses end)
exports('GetVehicles', function() return LXRShared.Vehicles end)
exports('GetTotalWeight', Core.TotalWeight)
exports('GetSlotsByItem', Core.SlotsByItem)
exports('GetFirstSlotByItem', Core.FirstSlotByItem)
exports('HasItem', Inventory.HasItem)
exports('GetInventoryProvider', function() return Inventory.Provider, Inventory.Resource end)
-- Player-level item helpers (namespaced to avoid clashing with registry exports above)
exports('AddPlayerItem', Inventory.AddItem)
exports('RemovePlayerItem', Inventory.RemoveItem)
exports('GetPlayerItem', Inventory.GetItem)
exports('GetPlayerItems', Inventory.GetItems)
exports('GetPlayerItemCount', Inventory.GetItemCount)
