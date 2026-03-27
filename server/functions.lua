--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - Core Server Functions
    
    Core server-side functions and utilities including player management,
    callbacks, useable items, and shared data management.
    
    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════
    
    Server:      The Land of Wolves 🐺
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    Store:       https://theluxempire.tebex.io
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR CORE - SERVER FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

LXRCore = {}
LXRCore.Player = {}
LXRCore.Players = {}          -- source → player object (primary index)
LXRCore.UseableItems = {}
LXRCore.ServerCallbacks = {}

-- O(1) secondary index: citizenid → source
-- Eliminates O(n) linear scans for citizenid lookups
LXRCore.CitizenIdMap = {}

-- Returns a cached list of active player source IDs
-- Reuses a single table reference to reduce GC pressure
function GetPlayers()
    local sources = {}
    for k in pairs(LXRCore.Players) do
        sources[#sources + 1] = k
    end
    return sources
end
exports('GetPlayers', GetPlayers)

-- Returns the entire player object table
exports('GetLXRPlayers', function()
    return LXRCore.Players
end)

-- Returns a player's specific identifier
-- Accepts steamid, license, discord, xbl, liveid, ip
function GetIdentifier(source, idtype)
    if type(idtype) ~= "string" then return print('Invalid usage') end
    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end
exports('GetIdentifier', GetIdentifier)

-- Returns the object of a single player by source ID
function GetPlayer(source)
    return LXRCore.Players[source]
end
exports('GetPlayer', GetPlayer)

-- O(1) lookup: Returns the object of a single player by Citizen ID
-- Uses CitizenIdMap hash table instead of O(n) linear scan
exports('GetPlayerByCitizenId', function(citizenid)
    local src = LXRCore.CitizenIdMap[citizenid]
    if src then
        return LXRCore.Players[src]
    end
    return nil
end)

-- Gets a list of all on-duty players of a specified job and the count
exports('GetPlayersOnDuty', function(job)
    local players = {}
    local count = 0
    for k, v in pairs(LXRCore.Players) do
        if v.PlayerData.job.name == job and v.PlayerData.job.onduty then
            players[#players + 1] = k
            count = count + 1
        end
    end
    return players, count
end)

-- Returns only the count of players on duty for the specified job
exports('GetDutyCount', function(job)
    if not job then return 0 end
    local count = 0
    for _, v in pairs(LXRCore.Players) do
        if v.PlayerData and v.PlayerData.job and v.PlayerData.job.name == job and v.PlayerData.job.onduty then
            count = count + 1
        end
    end
    return count
end)

-- Callbacks

function CreateCallback(name, cb)
    LXRCore.ServerCallbacks[name] = cb
end
exports('CreateCallback', CreateCallback)

function TriggerCallback(name, source, cb, ...)
    if not LXRCore.ServerCallbacks[name] then return end
    LXRCore.ServerCallbacks[name](source, cb, ...)
end
exports('TriggerCallback', TriggerCallback)

-- ═══════════════════════════════════════════════════════════════════════════════
-- TRANSACTION HELPER: Atomic multi-table operations for downstream resources.
-- Wraps MySQL.transaction so resource devs don't need to import oxmysql directly.
--
-- Usage (async):
--   exports['lxr-core']:Transaction({
--       { 'UPDATE players SET cash = cash - ? WHERE citizenid = ? AND cash >= ?', {price, cid, price} },
--       { 'INSERT INTO player_items (citizenid, item, amount) VALUES (?, ?, ?)', {cid, item, qty} },
--   }, function(success)
--       if not success then -- rollback happened end
--   end)
--
-- Usage (sync/await):
--   local success = exports['lxr-core']:TransactionAwait({
--       { 'UPDATE players SET cash = cash - ? WHERE citizenid = ? AND cash >= ?', {price, cid, price} },
--       { 'INSERT INTO player_items (citizenid, item, amount) VALUES (?, ?, ?)', {cid, item, qty} },
--   })
-- ═══════════════════════════════════════════════════════════════════════════════

exports('Transaction', function(queries, cb)
    if type(queries) ~= 'table' or #queries == 0 then
        if cb then cb(false) end
        return
    end
    -- Convert {sql, params} pairs to the format oxmysql expects
    local formatted = {}
    for i = 1, #queries do
        local q = queries[i]
        formatted[i] = { query = q[1], values = q[2] or {} }
    end
    MySQL.transaction(formatted, function(success)
        if cb then cb(success) end
    end)
end)

exports('TransactionAwait', function(queries)
    if type(queries) ~= 'table' or #queries == 0 then
        return false
    end
    local formatted = {}
    for i = 1, #queries do
        local q = queries[i]
        formatted[i] = { query = q[1], values = q[2] or {} }
    end
    return MySQL.transaction.await(formatted)
end)

-- Items

-- Creates an item as usable
exports('CreateUseableItem', function(item, cb)
    LXRCore.UseableItems[item] = cb
end)

-- Checks if an item can be used
exports('CanUseItem', function(item)
    return LXRCore.UseableItems[item]
end)

-- Uses an item
exports('UseItem', function(source, item)
    LXRCore.UseableItems[item.name](source, item)
end)

-- Kick Player with reason
exports('KickPlayer', function(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. LXRConfig.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        local i = 0
        while (i <= 4) do
            i = i + 1
            while true do
                if source then
                    if (GetPlayerPing(source) >= 0) then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end)

-- Setting & Removing Permissions

function AddPermission(source, permission)
    local src = source
    local license = GetIdentifier(src, 'license')
    ExecuteCommand(('add_principal identifier.%s LXRCore.%s'):format(license, permission))
    RefreshCommands(src)
end
exports('AddPermission', AddPermission)

function RemovePermission(source, permission)
    local src = source
    local license = GetIdentifier(src, 'license')
    if permission then
        if IsPlayerAceAllowed(src, permission) then
            ExecuteCommand(('remove_principal identifier.%s LXRCore.%s'):format(license, permission))
            RefreshCommands(src)
        end
    else
        for k,v in pairs(LXRConfig.Permissions) do
            if IsPlayerAceAllowed(src, v) then
                ExecuteCommand(('remove_principal identifier.%s LXRCore.%s'):format(license, v))
                RefreshCommands(src)
            end
        end
    end
end
exports('RemovePermission', RemovePermission)

-- Checking for Permission Level

function HasPermission(source, permission)
    local src = source
    if IsPlayerAceAllowed(src, permission) then return true end
    return false
end
exports('HasPermission', HasPermission)

function GetPermissions(source)
    local src = source
    local perms = {}
    for k,v in pairs (LXRConfig.Permissions) do
        if IsPlayerAceAllowed(src, v) then
            perms[v] = true
        end
    end
    return perms
end
exports('GetPermissions', GetPermissions)

-- Opt in or out of admin reports

function IsOptin(source)
    local src = source
    local license = GetIdentifier(src, 'license')
    if not license or not HasPermission(src, 'admin') then return false end
    local Player = GetPlayer(src)
    return Player.PlayerData.metadata.optin
end
exports('IsOptin', IsOptin)

function ToggleOptin(source)
    local src = source
    local license = GetIdentifier(src, 'license')
    if not license or not HasPermission(src, 'admin') then return end
    local Player = GetPlayer(src)
    Player.PlayerData.metadata.optin = not Player.PlayerData.metadata.optin
    Player.Functions.SetMetaData('optin', Player.PlayerData.metadata.optin)
end
exports('ToggleOptin', ToggleOptin)
