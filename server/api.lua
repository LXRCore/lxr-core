--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Native API (server)

    This is LXRCore's own developer surface. It is what official LXR resources
    are written against, and the only API the docs teach. Everything else the
    core exposes (the RSG-shaped GetCoreObject, the QBR export-per-function
    list, the VORP facade) lives behind Config.Compat and exists so foreign
    resources keep running — it is not the framework.

        local LXR = exports['lxr-core']:GetLXR()

        local player = LXR.Players.Get(source)
        player:AddMoney('cash', 25, 'bounty')
        player:SetJob('vallaw', 1)
        player:Notify('Welcome back', 'success')

        LXR.RPC.Register('shop:buy', function(source, name, amount) … return ok, err end)
        LXR.Events.On('lxr:player:loaded', function(player) … end)

    Vocabulary: lxr:<domain>:<verb> events, colon-call player handles, one
    module per domain (Players, Characters, Economy, Roles, Permissions, RPC,
    Items, Inventory, Commands, Database, Log, Events, Utils).

    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

LXR = LXR or {}
LXR.Version = LXRCore.Version
LXR.ApiLevel = LXRCore.ApiLevel
LXR.Config = Config
LXR.Shared = LXRShared
LXR.Utils = LXRShared
LXR.Log = LXRCore.Log
LXR.Metrics = LXRCore.Metrics
LXR.Database = LXRCore.DB

local Accounts, Roles, Perms, Callback, Items, Inventory = LXRCore.Accounts, LXRCore.Roles, LXRCore.Perms, LXRCore.Callback, LXRCore.Items, LXRCore.Inventory

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧍 PLAYER HANDLE — a thin object over the engine's player record
-- ═══════════════════════════════════════════════════════════════════════════════

local Handle = {}
Handle.__index = Handle
local handles = setmetatable({}, { __mode = 'k' }) -- engine record → handle (weak)

local function wrap(record)
    if not record then return nil end
    local h = handles[record]
    if h then return h end
    h = setmetatable({ _r = record }, Handle)
    handles[record] = h
    return h
end
LXR._Wrap = wrap

-- identity
function Handle:Source() return self._r.PlayerData.source end
function Handle:CitizenId() return self._r.PlayerData.citizenid end
function Handle:License() return self._r.PlayerData.license end
function Handle:Name() return self._r.PlayerData.name end
function Handle:Identifiers() return self._r.PlayerData.identifiers or {} end
function Handle:IsOffline() return self._r.Offline == true end
function Handle:Data() return self._r.PlayerData end
function Handle:CharInfo() return self._r.PlayerData.charinfo end
function Handle:FullName()
    local ci = self._r.PlayerData.charinfo or {}
    return ((ci.firstname or '') .. ' ' .. (ci.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
end
function Handle:Coords()
    if self._r.Offline then return self._r.PlayerData.position end
    local ped = GetPlayerPed(self._r.PlayerData.source)
    return ped ~= 0 and GetEntityCoords(ped) or self._r.PlayerData.position
end

-- money
function Handle:Money(account) return Accounts.Get(self._r, account) end
function Handle:AddMoney(account, amount, reason) return Accounts.Add(self._r, account, amount, reason) end
function Handle:RemoveMoney(account, amount, reason) return Accounts.Remove(self._r, account, amount, reason) end
function Handle:SetMoney(account, amount, reason) return Accounts.Set(self._r, account, amount, reason) end
function Handle:HasMoney(account, amount) return Accounts.Has(self._r, account, amount) end
function Handle:Pay(target, account, amount, reason)
    local other = type(target) == 'table' and target._r or LXRCore.Functions.GetPlayer(target)
    if not other then return false, 'not_online' end
    return Accounts.Transfer(self._r, other, account, amount, reason)
end

-- roles
function Handle:Job() return self._r.PlayerData.job end
function Handle:SetJob(name, grade) return self._r.Functions.SetJob(name, grade) end
function Handle:OnDuty() return self._r.PlayerData.job.onduty == true end
function Handle:SetDuty(state) return self._r.Functions.SetJobDuty(state == true) end
function Handle:HasJob(name) return self._r.PlayerData.job.name == name end
function Handle:JobType() return self._r.PlayerData.job.type end
function Handle:IsBoss() return self._r.PlayerData.job.isboss == true end
function Handle:Gang() return self._r.PlayerData.gang end
function Handle:SetGang(name, grade) return self._r.Functions.SetGang(name, grade) end

-- metadata / reputation / skills
function Handle:Meta(key) return self._r.Functions.GetMetaData(key) end
function Handle:SetMeta(key, value) return self._r.Functions.SetMetaData(key, value) end
function Handle:Rep(rep) return self._r.Functions.GetRep(rep) end
function Handle:AddRep(rep, amount) return self._r.Functions.AddRep(rep, amount) end
function Handle:RemoveRep(rep, amount) return self._r.Functions.RemoveRep(rep, amount) end
function Handle:Xp(skill) return self._r.Functions.GetXp(skill) end
function Handle:Level(skill) return self._r.Functions.GetLevel(skill) end
function Handle:AddXp(skill, amount) return self._r.Functions.AddXp(skill, amount) end
function Handle:RemoveXp(skill, amount) return self._r.Functions.RemoveXp(skill, amount) end

-- items
function Handle:Items() return self._r.PlayerData.items end
function Handle:Item(nameOrSlot)
    if type(nameOrSlot) == 'number' then return self._r.Functions.GetItemBySlot(nameOrSlot) end
    return self._r.Functions.GetItemByName(nameOrSlot)
end
function Handle:Count(name) return Inventory.CoreLogic.Count(self._r.PlayerData.items, name) end
function Handle:HasItem(items, amount) return self._r.Functions.HasItem(items, amount) end
function Handle:AddItem(name, amount, slot, info, reason) return self._r.Functions.AddItem(name, amount, slot, info, reason) end
function Handle:RemoveItem(name, amount, slot, reason) return self._r.Functions.RemoveItem(name, amount, slot, reason) end
function Handle:ClearItems(keep) return self._r.Functions.ClearInventory(keep) end
function Handle:Weight() return Inventory.CoreLogic.TotalWeight(self._r.PlayerData.items) end
function Handle:MaxWeight() return tonumber(self._r.PlayerData.weight) or Config.Player.maxWeight end
function Handle:Slots() return tonumber(self._r.PlayerData.slots) or Config.Player.maxSlots end

-- permissions
function Handle:Has(permission) return Perms.Has(self._r.PlayerData.source, permission) end
function Handle:Group() return Perms.Group(self._r.PlayerData.source) end
function Handle:Grant(group) return Perms.Add(self._r.PlayerData.source, group) end
function Handle:Revoke(group) return Perms.Remove(self._r.PlayerData.source, group) end

-- session
function Handle:Save() return self._r.Functions.Save() end
function Handle:Logout() return self._r.Functions.Logout() end
function Handle:Kick(reason) return LXRCore.Functions.Kick(self._r.PlayerData.source, reason) end
function Handle:Notify(message, kind, duration) LXRCore.Notify(self._r.PlayerData.source, message, kind, duration) end
function Handle:Ask(name, ...) return Callback.Await(name, self._r.PlayerData.source, ...) end
function Handle:Emit(name, ...) TriggerClientEvent(name, self._r.PlayerData.source, ...) end
function Handle:Sync() return self._r.Functions.UpdatePlayerData() end
function Handle:Set(key, value) return self._r.Functions.SetPlayerData(key, value) end
---Escape hatch to the underlying engine record (RSG-shaped) — for compat code only.
function Handle:Raw() return self._r end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 MODULES
-- ═══════════════════════════════════════════════════════════════════════════════

LXR.Players = {
    Get = function(source) return wrap(LXRCore.Functions.GetPlayer(source)) end,
    ByCitizenId = function(cid) return wrap(LXRCore.PlayersByCitizenId[cid]) end,
    ByLicense = function(license) return wrap(LXRCore.PlayersByLicense[license]) end,
    Offline = function(cid) return wrap(LXRCore.Player.GetOfflinePlayer(cid)) end,
    All = function()
        local out = {}
        for _, rec in pairs(LXRCore.Players) do out[#out + 1] = wrap(rec) end
        return out
    end,
    Sources = LXRCore.Functions.GetPlayers,
    Count = function() local n = 0 for _ in pairs(LXRCore.Players) do n = n + 1 end return n end,
    OnDuty = function(job)
        local out = {}
        for _, rec in pairs(LXRCore.Players) do
            if rec.PlayerData.job.name == job and rec.PlayerData.job.onduty then out[#out + 1] = wrap(rec) end
        end
        return out
    end,
    WithJob = function(job)
        local out = {}
        for _, rec in pairs(LXRCore.Players) do
            if rec.PlayerData.job.name == job then out[#out + 1] = wrap(rec) end
        end
        return out
    end,
    Each = function(fn) for _, rec in pairs(LXRCore.Players) do fn(wrap(rec)) end end,
    IsLoaded = function(source) return LXRCore.Players[LXRCore.ToSource(source) or -1] ~= nil end,
    Identifier = LXRCore.Functions.GetIdentifier,
    Kick = LXRCore.Functions.Kick,
    Ban = LXRCore.Functions.ExploitBan,
    IsBanned = LXRCore.Functions.IsPlayerBanned,
    Notify = LXRCore.Notify,
    Broadcast = function(message, kind, duration) LXRCore.Notify(-1, message, kind, duration) end,
}

LXR.Characters = {
    List = LXRCore.Player.GetCharacters,
    Count = LXRCore.Player.CountCharacters,
    Load = LXRCore.Player.Login,
    Create = function(source, cid, charinfo) return LXRCore.Player.Login(source, false, { cid = cid, charinfo = charinfo }) end,
    Unload = LXRCore.Player.Logout,
    Save = LXRCore.Player.Save,
    SaveAll = LXRCore.Player.SaveAll,
    Delete = LXRCore.Player.DeleteCharacter,
    ForceDelete = LXRCore.Player.ForceDeleteCharacter,
    RegisterTable = LXRCore.Player.RegisterCharacterTable,
    ValidateId = LXRCore.Player.ValidateCitizenId,
}

LXR.Economy = {
    Accounts = function() return Config.Money.MoneyTypes end,
    Transfer = function(from, to, account, amount, reason)
        local a = type(from) == 'table' and from._r or LXRCore.Functions.GetPlayer(from)
        local b = type(to) == 'table' and to._r or LXRCore.Functions.GetPlayer(to)
        if not a or not b then return false, 'not_online' end
        return Accounts.Transfer(a, b, account, amount, reason)
    end,
    Normalize = Accounts.Normalize,
    Flush = Accounts.FlushLedger,
}

LXR.Roles = {
    Job = function(name) return LXRShared.Jobs[name] end,
    Jobs = function() return LXRShared.Jobs end,
    Gang = function(name) return LXRShared.Gangs[name] end,
    Gangs = function() return LXRShared.Gangs end,
    BuildJob = Roles.BuildJob,
    BuildGang = Roles.BuildGang,
    RegisterJob = Roles.AddJob,
    RegisterJobs = Roles.AddJobs,
    UpdateJob = Roles.UpdateJob,
    RemoveJob = Roles.RemoveJob,
    RegisterGang = Roles.AddGang,
    RegisterGangs = Roles.AddGangs,
    UpdateGang = Roles.UpdateGang,
    RemoveGang = Roles.RemoveGang,
}

LXR.Permissions = {
    Has = Perms.Has,
    Grant = Perms.Add,
    Revoke = Perms.Remove,
    Group = Perms.Group,
    Groups = Perms.Get,
    IsWhitelisted = Perms.IsWhitelisted,
}

LXR.RPC = {
    ---Answer clients: fn(source, ...) return ...
    Register = Callback.Register,
    Unregister = Callback.Unregister,
    IsRegistered = Callback.IsRegistered,
    ---Ask a client and yield for the answer (nil on timeout).
    Client = Callback.Await,
    ---Ask a client, answer delivered to cb.
    ClientAsync = Callback.Trigger,
    ---Run a registered server callback locally.
    Invoke = Callback.Invoke,
}

LXR.Items = {
    Get = Items.Get,
    All = function() return LXRShared.Items end,
    Register = Items.Add,
    RegisterMany = Items.AddMany,
    Update = Items.Update,
    Remove = Items.Remove,
    ---Usable handler: fn(source, item)
    Usable = Items.RegisterUsable,
    Unusable = Items.UnregisterUsable,
    IsUsable = Items.CanUse,
    Use = Items.Use,
}

LXR.Inventory = Inventory

LXR.Commands = {
    ---Register({ name, help, args = { { name, help } }, required = bool, permission = 'admin', handler = fn(source, args, raw) })
    Register = function(def)
        if type(def) ~= 'table' or type(def.name) ~= 'string' or type(def.handler) ~= 'function' then return false end
        return LXRCore.Commands.Add(def.name, def.help or '', def.args or {}, def.required == true, def.handler, def.permission or 'user', table.unpack(def.extraGroups or {}))
    end,
    Refresh = LXRCore.Commands.Refresh,
    Run = LXRCore.Commands.Call,
    List = function() return LXRCore.Commands.List end,
}

LXR.Events = {
    ---Subscribe to a server event (native lxr:* names documented in docs/events.md).
    On = function(name, fn) return AddEventHandler(name, fn) end,
    ---Fire a server event.
    Emit = function(name, ...) TriggerEvent(name, ...) end,
    ---Fire a client event on one player (or -1 for all).
    EmitClient = function(target, name, ...) TriggerClientEvent(name, target, ...) end,
    ---Register a validated net event: handler(source, ...) is only called for loaded players and is rate limited.
    OnNet = function(name, handler, opts)
        opts = opts or {}
        local bucket = {}
        local rl = opts.rateLimit or Config.Security.eventRateLimit
        RegisterNetEvent(name, function(...)
            local src = source
            if opts.requireLoaded ~= false and not LXRCore.Players[src] then return end
            if rl and not LXRCore.RateLimit(bucket, src, rl.burst, rl.windowMs) then
                LXRCore.Log.warn('event', 'rate limit exceeded', { event = name, source = src })
                return
            end
            handler(src, ...)
        end)
    end,
}

LXR.Ready = function() return LXRCore.Ready end
LXR.Migration = LXRCore.DB.RegisterMigration
LXR.RateLimit = LXRCore.RateLimit
LXR.Locale = Lang

exports('GetLXR', function() return LXR end)
