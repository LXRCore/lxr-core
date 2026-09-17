--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Public Export Surface & Misc Core Functions (server)
     ═══════════════════════════════════════════════════════════════════════════
     Two consumer styles are served from the same implementation:
       1. exports['lxr-core']:GetCoreObject()  → LXRCore (RSG-shaped + native)
       2. exports['lxr-core']:GetPlayer(src)   → legacy export-per-function (QBR)
     Everything exported here is documented in docs/exports.md.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local F = LXRCore.Functions

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧭 ENTITY / WORLD HELPERS (RSG-shaped)
-- ═══════════════════════════════════════════════════════════════════════════════

function F.GetCoords(entity)
    local c = GetEntityCoords(entity)
    return vector4(c.x, c.y, c.z, GetEntityHeading(entity))
end

local function closest(source, coords, pool, skipSelf)
    local ped = GetPlayerPed(source)
    if coords then coords = type(coords) == 'table' and vector3(coords.x, coords.y, coords.z) or coords end
    if not coords then coords = GetEntityCoords(ped) end
    local bestId, bestDist = -1, -1
    for i = 1, #pool do
        local ent = pool[i]
        local target = skipSelf and GetPlayerPed(ent) or ent
        if target ~= ped then
            local d = #(GetEntityCoords(target) - coords)
            if bestDist == -1 or d < bestDist then bestId, bestDist = ent, d end
        end
    end
    return bestId, bestDist
end

function F.GetClosestPlayer(source, coords) return closest(source, coords, GetPlayers(), true) end
function F.GetClosestObject(source, coords) return closest(source, coords, GetAllObjects(), false) end
function F.GetClosestVehicle(source, coords) return closest(source, coords, GetAllVehicles(), false) end
function F.GetClosestPed(source, coords) return closest(source, coords, GetAllPeds(), false) end

-- Routing buckets
LXRCore.Player_Buckets = {}
LXRCore.Entity_Buckets = {}

function F.GetBucketObjects() return LXRCore.Player_Buckets, LXRCore.Entity_Buckets end

function F.SetPlayerBucket(source, bucket)
    source = LXRCore.ToSource(source)
    bucket = tonumber(bucket)
    if not source or not bucket then return false end
    local license = GetPlayerIdentifierByType(source, 'license')
    Player(source).state:set('instance', bucket, true)
    SetPlayerRoutingBucket(source, bucket)
    LXRCore.Player_Buckets[license] = { id = source, bucket = bucket }
    return true
end

function F.SetEntityBucket(entity, bucket)
    if not entity or not tonumber(bucket) then return false end
    SetEntityRoutingBucket(entity, bucket)
    LXRCore.Entity_Buckets[entity] = { id = entity, bucket = bucket }
    return true
end

function F.GetPlayersInBucket(bucket)
    local out = {}
    for _, v in pairs(LXRCore.Player_Buckets) do
        if v.bucket == bucket then out[#out + 1] = v.id end
    end
    return out
end

function F.GetEntitiesInBucket(bucket)
    local out = {}
    for _, v in pairs(LXRCore.Entity_Buckets) do
        if v.bucket == bucket then out[#out + 1] = v.id end
    end
    return out
end

---Server-side vehicle creation. Returns the entity handle (or nil).
function F.SpawnVehicle(source, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local heading = coords.w or 0.0
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
    local tries = 0
    while not DoesEntityExist(veh) and tries < 100 do Wait(10) tries = tries + 1 end
    if not DoesEntityExist(veh) then return nil end
    if warp then TaskWarpPedIntoVehicle(ped, veh, -1) end
    return veh
end
F.CreateVehicle = function(source, model, _, coords, warp) return F.SpawnVehicle(source, model, coords, warp) end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧩 OBJECT EXTENSION (RSG-shaped)
-- ═══════════════════════════════════════════════════════════════════════════════

function F.SetMethod(name, handler)
    if type(name) ~= 'string' then return false, 'invalid_method_name' end
    F[name] = handler
    LXRCore.NotifyObjectUpdate()
    return true, 'success'
end

function F.SetField(name, data)
    if type(name) ~= 'string' then return false, 'invalid_field_name' end
    LXRCore[name] = data
    LXRCore.NotifyObjectUpdate()
    return true, 'success'
end

function F.AddPlayerMethod(ids, name, handler)
    if type(ids) == 'number' then
        if ids == -1 then
            for _, p in pairs(LXRCore.Players) do p.Functions.AddMethod(name, handler) end
        elseif LXRCore.Players[ids] then
            LXRCore.Players[ids].Functions.AddMethod(name, handler)
        end
    elseif type(ids) == 'table' then
        for _, id in ipairs(ids) do F.AddPlayerMethod(id, name, handler) end
    end
end

function F.AddPlayerField(ids, name, data)
    if type(ids) == 'number' then
        if ids == -1 then
            for _, p in pairs(LXRCore.Players) do p.Functions.AddField(name, data) end
        elseif LXRCore.Players[ids] then
            LXRCore.Players[ids].Functions.AddField(name, data)
        end
    elseif type(ids) == 'table' then
        for _, id in ipairs(ids) do F.AddPlayerField(id, name, data) end
    end
end

function F.ChangeWeight(source, weight)
    local p = F.GetPlayer(source); if not p then return false end
    weight = tonumber(weight); if not weight or weight < 0 then return false end
    p.Functions.SetPlayerData('weight', math.floor(weight))
    return true
end

function F.ChangeSlots(source, slots)
    local p = F.GetPlayer(source); if not p then return false end
    slots = tonumber(slots); if not slots or slots < 1 then return false end
    p.Functions.SetPlayerData('slots', math.floor(slots))
    return true
end

function F.IsOptin(source)
    if not LXRCore.Perms.Has(source, 'admin') then return false end
    local p = F.GetPlayer(source)
    return p ~= nil and p.PlayerData.optin == true
end

function F.ToggleOptin(source)
    if not LXRCore.Perms.Has(source, 'admin') then return end
    local p = F.GetPlayer(source); if not p then return end
    p.Functions.SetPlayerData('optin', not p.PlayerData.optin)
end

function F.GetCoreVersion(invoking)
    local v = GetResourceMetadata(LXRCore.ResourceName, 'version', 0)
    if invoking and invoking ~= '' then LXRCore.Log.debug('core', ('%s asked for core version %s'):format(invoking, v)) end
    return v
end

function F.GetDatabaseInfo()
    local details = { exists = false, database = '' }
    local cs = GetConvar('mysql_connection_string', '')
    if cs == '' then return details end
    if cs:find('mysql://') then
        local path = cs:sub(9)
        local slash = path:find('/')
        if slash then
            details.database = path:sub(slash + 1):gsub('[%?]+[%w%p]*$', '')
            details.exists = details.database ~= ''
        end
        return details
    end
    for part in cs:gmatch('[^;]+') do
        local k, v = part:match('^%s*([^=]+)%s*=%s*(.-)%s*$')
        if k and k:lower() == 'database' then
            details.database = v
            details.exists = v ~= ''
        end
    end
    return details
end

---Validate that `data` fully matches `pattern` (legacy anti-SQL helper).
function F.PrepForSQL(source, data, pattern)
    data = tostring(data)
    local match = string.match(data, pattern)
    if not match or #match ~= #data then
        LXRCore.Log.exploit(source, 'PrepForSQL rejected input', { data = data:sub(1, 64) })
        return false
    end
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS — legacy export-per-function surface (QBR / old LXR resources)
-- ═══════════════════════════════════════════════════════════════════════════════

exports('GetPlayer', F.GetPlayer)
exports('GetPlayers', F.GetPlayers)
exports('GetLXRPlayers', F.GetLXRPlayers)
exports('GetPlayerByCitizenId', F.GetPlayerByCitizenId)
exports('GetPlayerByLicense', F.GetPlayerByLicense)
exports('GetOfflinePlayerByCitizenId', F.GetOfflinePlayerByCitizenId)
exports('GetIdentifier', F.GetIdentifier)
exports('GetSource', F.GetSource)
exports('GetPlayersOnDuty', F.GetPlayersOnDuty)
exports('GetDutyCount', F.GetDutyCount)
exports('GetPlayersByJob', F.GetPlayersByJob)
exports('GetCharacters', LXRCore.Player.GetCharacters)
exports('Login', LXRCore.Player.Login)
exports('Logout', LXRCore.Player.Logout)
exports('SavePlayer', LXRCore.Player.Save)
exports('DeleteCharacter', LXRCore.Player.DeleteCharacter)
exports('ForceDeleteCharacter', LXRCore.Player.ForceDeleteCharacter)
exports('RegisterCharacterTable', LXRCore.Player.RegisterCharacterTable)
exports('KickPlayer', F.Kick)
exports('Kick', F.Kick)
exports('ExploitBan', F.ExploitBan)
exports('IsPlayerBanned', F.IsPlayerBanned)
exports('IsOptin', F.IsOptin)
exports('ToggleOptin', F.ToggleOptin)
exports('GetConfig', function() return Config end)
exports('GetShared', function() return LXRShared end)
exports('GetCoreVersion', F.GetCoreVersion)
exports('GetMetrics', LXRCore.Metrics.Get)
exports('SetMethod', F.SetMethod)
exports('SetField', F.SetField)
exports('SetPlayerBucket', F.SetPlayerBucket)
exports('SetEntityBucket', F.SetEntityBucket)
exports('GetPlayersInBucket', F.GetPlayersInBucket)
exports('GetClosestPlayer', F.GetClosestPlayer)
exports('IsDatabaseConnected', function() return LXRCore.DB.Connected end)
-- shared utilities
exports('RandomStr', LXRShared.RandomStr)
exports('RandomInt', LXRShared.RandomInt)
exports('SplitStr', LXRShared.SplitStr)
exports('Trim', LXRShared.Trim)
exports('Round', LXRShared.Round)
-- player-scoped convenience wrappers (source-based)
exports('AddMoney', function(source, account, amount, reason)
    local p = F.GetPlayer(source); if not p then return false, 'not_online' end
    return p.Functions.AddMoney(account, amount, reason)
end)
exports('RemoveMoney', function(source, account, amount, reason)
    local p = F.GetPlayer(source); if not p then return false, 'not_online' end
    return p.Functions.RemoveMoney(account, amount, reason)
end)
exports('GetMoney', function(source, account)
    local p = F.GetPlayer(source); if not p then return nil end
    return p.Functions.GetMoney(account)
end)
exports('SetJob', function(source, job, grade)
    local p = F.GetPlayer(source); if not p then return false, 'not_online' end
    return p.Functions.SetJob(job, grade)
end)
exports('SetGang', function(source, gang, grade)
    local p = F.GetPlayer(source); if not p then return false, 'not_online' end
    return p.Functions.SetGang(gang, grade)
end)
exports('GetPlayerData', function(source)
    local p = F.GetPlayer(source)
    return p and p.PlayerData or nil
end)
exports('IsPlayerLoaded', function(source)
    return LXRCore.Players[LXRCore.ToSource(source) or -1] ~= nil
end)
exports('Notify', function(source, message, kind, duration)
    -- server → client notification; (source, message, type, duration) or (source, {title=…, description=…})
    TriggerClientEvent('LXRCore:Notify', source, message, kind, duration)
end)
