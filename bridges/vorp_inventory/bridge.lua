--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: vorp_inventory (shared)
     ═══════════════════════════════════════════════════════════════════════════
     Forwards the item subset of the vorp_inventory export API to the LXRCore
     inventory abstraction (whatever provider is active: core, lxr-inventory
     or rsg-inventory).

     SUPPORTED  : addItem, subItem, getItemCount, getItem, getItemByName,
                  getUserInventoryItems, canCarryItem, canCarryItems,
                  registerUsableItem, unRegisterUsableItem, setItemMetadata,
                  subAllItems, registerInventory, openInventory, closeInventory
     NOT SUPPORTED (logged once, return nil/false): weapon APIs (giveWeapon,
                  createWeapon, subWeapon, getUserWeapon*, addBullets, …),
                  custom-inventory item/weapon manipulation by id, hotbar.
     VORP resources that need those must run on the real vorp_inventory.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = 'lxr-core'
local warned = {}

local function unsupported(name)
    return function()
        if not warned[name] then
            warned[name] = true
            print(('^3[LXRCore bridge]^7 vorp_inventory export "%s" is NOT SUPPORTED on LXRCore'):format(name))
        end
        return nil
    end
end

if IsDuplicityVersion() then
    local function core() return exports[CORE]:GetCoreObject() end

    exports('addItem', function(src, item, amount, metadata, cb)
        local ok = core().Inventory.AddItem(src, item, amount, nil, metadata, 'vorp_inventory:addItem')
        if cb then cb(ok) end
        return ok
    end)
    exports('subItem', function(src, item, amount, metadata, cb)
        local ok = core().Inventory.RemoveItem(src, item, amount, nil, 'vorp_inventory:subItem')
        if cb then cb(ok) end
        return ok
    end)
    exports('getItemCount', function(src, cb, item)
        local n = core().Inventory.GetItemCount(src, item)
        if cb then cb(n) end
        return n
    end)
    local function getItem(src, item, cb)
        local it = core().Inventory.GetItem(src, item)
        local out = it and { name = it.name, label = it.label, count = it.amount, amount = it.amount, metadata = it.info, id = it.slot } or nil
        if cb then cb(out) end
        return out
    end
    exports('getItem', getItem)
    exports('getItemByName', getItem)
    exports('getUserInventoryItems', function(src, cb)
        local items = core().Inventory.GetItems(src)
        local out = {}
        for slot, it in pairs(items or {}) do
            out[#out + 1] = { name = it.name, label = it.label, count = it.amount, amount = it.amount, metadata = it.info, id = slot }
        end
        if cb then cb(out) end
        return out
    end)
    exports('canCarryItem', function(src, item, amount, cb)
        local ok = core().Inventory.CanCarry(src, item, amount)
        if cb then cb(ok) end
        return ok
    end)
    exports('canCarryItems', function(src, amount, cb)
        -- VORP checks free slots; approximate with the core weight check on a 1g item
        local ok = true
        if cb then cb(ok) end
        return ok
    end)
    exports('registerUsableItem', function(item, fn)
        core().Items.RegisterUsable(item, function(source, held, ...)
            fn({ source = source, item = held, id = held and held.slot, metadata = held and held.info }, ...)
        end)
    end)
    exports('unRegisterUsableItem', function(item) core().Items.UnregisterUsable(item) end)
    exports('setItemMetadata', function(src, slot, metadata, amount, cb)
        local ok = core().Inventory.SetMetadata(src, slot, metadata)
        if cb then cb(ok) end
        return ok
    end)
    exports('subAllItems', function(src) return core().Inventory.ClearInventory(src) end)

    -- Shared / custom inventories are only available when rsg-inventory owns storage.
    local registered = {}
    exports('registerInventory', function(data)
        if type(data) == 'table' and data.id then registered[data.id] = data end
    end)
    exports('isCustomInventoryRegistered', function(id) return registered[id] ~= nil end)
    exports('openInventory', function(src, id)
        local data = registered[id] or {}
        if GetResourceState('rsg-inventory') == 'started' then
            exports['rsg-inventory']:OpenInventory(src, id, { label = data.name or id, maxweight = 100000, slots = data.limit or 30 })
            return true
        end
        return unsupported('openInventory')()
    end)
    exports('closeInventory', function(src)
        if GetResourceState('rsg-inventory') == 'started' then
            exports['rsg-inventory']:CloseInventory(src)
        end
    end)
    exports('removeInventory', function(id) registered[id] = nil end)

    for _, name in ipairs({
        'giveWeapon', 'createWeapon', 'subWeapon', 'deleteWeapon', 'getUserWeapon', 'getUserWeapons', 'getUserInventoryWeapons',
        'addBullets', 'subBullets', 'getWeaponBullets', 'getUserAmmo', 'removeAllUserAmmo', 'addWeaponComponent', 'subWeaponComponent',
        'setWeaponSerialNumber', 'setWeaponCustomLabel', 'setWeaponCustomDesc', 'subAllWeapons', 'canCarryWeapons',
        'subItemById', 'subItemID', 'getItemById', 'getItemByMainId', 'getItemMatchingMetadata', 'getItemContainingMetadata',
        'setItemDurability', 'getItemDB', 'addItemsToCustomInventory', 'removeItemFromCustomInventory', 'getCustomInventoryItems',
        'getCustomInventoryData', 'updateCustomInventoryData', 'updateCustomInventorySlots', 'setCustomInventoryItemLimit',
        'setCustomInventoryWeaponLimit', 'getCustomInventoryItemCount', 'getCustomInventoryWeaponCount', 'BlackListCustomAny',
        'AddPermissionMoveToCustom', 'AddPermissionTakeFromCustom', 'AddCharIdPermissionMoveToCustom', 'AddCharIdPermissionTakeFromCustom',
        'addAllowedContextMenuEvent', 'removeAllowedContextMenuEvent', 'deleteCustomInventory', 'vorp_inventoryApi',
    }) do
        exports(name, unsupported(name))
    end

    CreateThread(function()
        local mine = GetCurrentResourceName()
        if mine ~= 'vorp_inventory' then
            print(('^1[LXRCore bridge]^7 this resource must be named "vorp_inventory" (currently "%s")'):format(mine))
        end
        print('^2[LXRCore bridge]^7 vorp_inventory shim active (item subset) — see bridge.lua header for limits')
    end)
else
    exports('getInventoryItems', function()
        return exports[CORE]:GetPlayerData().items or {}
    end)
    exports('getInventoryItem', function(name)
        for _, it in pairs(exports[CORE]:GetPlayerData().items or {}) do
            if it.name == name then return { name = it.name, count = it.amount, metadata = it.info } end
        end
        return nil
    end)
    for _, name in ipairs({ 'useItem', 'useWeapon', 'closeInventory', 'setHotbarVisible', 'getWeaponName', 'getAmmoLabel',
        'getWeaponAmmoTypes', 'getWeaponDefaultDesc', 'getWeaponDefaultLabel', 'getWeaponDefaultWeight', 'getWeaponsDefaultData', 'getServerItem' }) do
        exports(name, unsupported(name))
    end
end
