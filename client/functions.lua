--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Client Helper Functions
     ═══════════════════════════════════════════════════════════════════════════
     RedM-native helpers exposed on LXRCore.Functions and as exports. No loops;
     every function does its work and returns. Entity pools use GetGamePool.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local F = LXRCore.Functions

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📍 POSITIONS & DISTANCES
-- ═══════════════════════════════════════════════════════════════════════════════

function F.GetCoords(entity)
    entity = entity or PlayerPedId()
    local c = GetEntityCoords(entity, false)
    return vector4(c.x, c.y, c.z, GetEntityHeading(entity))
end

local function toVec3(coords)
    if coords == nil then return GetEntityCoords(PlayerPedId()) end
    if type(coords) == 'table' then return vector3(coords.x, coords.y, coords.z) end
    return vector3(coords.x, coords.y, coords.z)
end

function F.GetPlayers() return GetActivePlayers() end
function F.GetVehicles() return GetGamePool('CVehicle') end
function F.GetObjects() return GetGamePool('CObject') end

function F.GetPeds(ignoreList)
    local ignore = {}
    for _, v in ipairs(ignoreList or {}) do ignore[v] = true end
    local out = {}
    for _, ped in ipairs(GetGamePool('CPed')) do
        if not ignore[ped] then out[#out + 1] = ped end
    end
    return out
end

function F.GetPlayersFromCoords(coords, distance)
    coords = toVec3(coords)
    distance = tonumber(distance) or 5.0
    local out = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if #(GetEntityCoords(ped) - coords) <= distance then out[#out + 1] = player end
    end
    return out
end

local function closestOf(pool, coords, skip)
    local best, bestDist = -1, -1
    for _, ent in ipairs(pool) do
        if ent ~= skip then
            local d = #(GetEntityCoords(ent) - coords)
            if bestDist == -1 or d < bestDist then best, bestDist = ent, d end
        end
    end
    return best, bestDist
end

function F.GetClosestPlayer(coords)
    coords = toVec3(coords)
    local me = PlayerPedId()
    local best, bestDist = -1, -1
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped ~= me then
            local d = #(GetEntityCoords(ped) - coords)
            if bestDist == -1 or d < bestDist then best, bestDist = player, d end
        end
    end
    return best, bestDist
end

function F.GetClosestPed(coords, ignoreList)
    return closestOf(F.GetPeds(ignoreList), toVec3(coords), PlayerPedId())
end

function F.GetClosestVehicle(coords)
    return closestOf(GetGamePool('CVehicle'), toVec3(coords), nil)
end

function F.GetClosestObject(coords)
    return closestOf(GetGamePool('CObject'), toVec3(coords), nil)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📦 ASSETS
-- ═══════════════════════════════════════════════════════════════════════════════

function F.LoadModel(model)
    model = type(model) == 'string' and joaat(model) or model
    if not IsModelValid(model) then return false end
    if HasModelLoaded(model) then return true end
    RequestModel(model)
    local tries = 0
    while not HasModelLoaded(model) and tries < 500 do Wait(10) tries = tries + 1 end
    return HasModelLoaded(model)
end

function F.RequestAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local tries = 0
    while not HasAnimDictLoaded(dict) and tries < 500 do Wait(10) tries = tries + 1 end
    return HasAnimDictLoaded(dict)
end
F.LoadAnimDict = F.RequestAnimDict

function F.PlayAnim(dict, name, upperbodyOnly, duration)
    if not F.RequestAnimDict(dict) then return false end
    local flag = upperbodyOnly and 16 or 0
    TaskPlayAnim(PlayerPedId(), dict, name, 8.0, -8.0, duration or -1, flag, 0, false, false, false)
    RemoveAnimDict(dict)
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧍 PEDS, PROPS, VEHICLES
-- ═══════════════════════════════════════════════════════════════════════════════

---Spawn a named, persistent ped (registry LXRCore.Peds[name]).
function F.SpawnPed(name, model, x, y, z, heading, networked)
    if LXRCore.Peds[name] and DoesEntityExist(LXRCore.Peds[name]) then return LXRCore.Peds[name] end
    local hash = type(model) == 'string' and joaat(model) or model
    if not F.LoadModel(hash) then return nil end
    local ped = CreatePed(hash, x, y, z, heading or 0.0, networked == true, false, false, false)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- SetRandomOutfitVariation
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetModelAsNoLongerNeeded(hash)
    LXRCore.Peds[name] = ped
    return ped
end

function F.RemovePed(name)
    local ped = LXRCore.Peds[name]
    if ped and DoesEntityExist(ped) then DeleteEntity(ped) end
    LXRCore.Peds[name] = nil
end

function F.AttachProp(ped, model, boneId, x, y, z, xR, yR, zR, vertex)
    local hash = type(model) == 'string' and joaat(model) or model
    if not F.LoadModel(hash) then return nil end
    local c = GetEntityCoords(ped)
    local prop = CreateObject(hash, c.x, c.y, c.z + 0.2, true, true, true)
    local bone = GetEntityBoneIndexByName(ped, boneId)
    AttachEntityToEntity(prop, ped, bone, x, y, z, xR, yR, zR, true, true, false, true, vertex and 0 or 2, true)
    SetModelAsNoLongerNeeded(hash)
    return prop
end

---Client-side vehicle spawn (networked by default). cb(vehicle) optional.
function F.SpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    local hash = type(model) == 'string' and joaat(model) or model
    local ped = PlayerPedId()
    coords = coords or F.GetCoords(ped)
    if not F.LoadModel(hash) then if cb then cb(nil) end return nil end
    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w or 0.0, isnetworked ~= false, false)
    SetModelAsNoLongerNeeded(hash)
    if isnetworked ~= false then
        local netId = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(netId, true)
        SetEntityAsMissionEntity(veh, true, true)
    end
    if teleportInto then TaskWarpPedIntoVehicle(ped, veh, -1) end
    if cb then cb(veh) end
    return veh
end

function F.DeleteVehicle(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function F.GetPlate(vehicle)
    if not vehicle or vehicle == 0 then return nil end
    return LXRShared.Trim(Citizen.InvokeNative(0xE8522D58, vehicle)) -- GetVehicleNumberPlateText
end

function F.GetVehicleLabel(vehicle)
    if not vehicle or vehicle == 0 then return nil end
    return GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗺️ BLIPS
-- ═══════════════════════════════════════════════════════════════════════════════

function F.CreateBlip(uniqueId, label, x, y, z, sprite, scale, rotation, radius)
    if type(sprite) == 'string' then sprite = joaat(sprite) end
    F.DeleteBlip(uniqueId)
    local blip
    if radius then
        blip = Citizen.InvokeNative(0x45F13B7E0A15C880, 1664425300, x, y, z, radius) -- BlipAddForRadius
    else
        blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)         -- BlipAddForCoords
    end
    if sprite then SetBlipSprite(blip, sprite, true) end
    if scale then SetBlipScale(blip, scale) end
    if rotation then Citizen.InvokeNative(0x24A5F8A3A5CDF2E7, blip, rotation) end
    if label then Citizen.InvokeNative(0x9CB1A1623062F402, blip, label) end          -- SetBlipNameFromPlayerString
    LXRCore.Blips[uniqueId] = blip
    return blip
end

function F.DeleteBlip(uniqueId)
    local blip = LXRCore.Blips[uniqueId]
    if blip then RemoveBlip(blip) end
    LXRCore.Blips[uniqueId] = nil
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎒 ITEMS (client-side view of replicated PlayerData)
-- ═══════════════════════════════════════════════════════════════════════════════

---HasItem(name, amount) · HasItem({ 'a', 'b' }, amount) · HasItem({ a = 2, b = 1 })
function F.HasItem(items, amount)
    local inv = LXRCore.PlayerData.items or {}
    local function count(name)
        local n = 0
        for _, it in pairs(inv) do
            if it and it.name == name then n = n + (it.amount or 0) end
        end
        return n
    end
    amount = tonumber(amount) or 1
    if type(items) == 'string' then return count(items) >= amount end
    if type(items) ~= 'table' then return false end
    for k, v in pairs(items) do
        if type(k) == 'string' then
            if count(k) < (tonumber(v) or 1) then return false end
        elseif count(v) < amount then
            return false
        end
    end
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⏳ PROGRESS BAR (delegates to the progressbar resource when present)
-- ═══════════════════════════════════════════════════════════════════════════════

function F.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if GetResourceState('progressbar') == 'started' then
        exports['progressbar']:Progress({
            name = name:lower(), duration = duration, label = label, useWhileDead = useWhileDead,
            canCancel = canCancel, controlDisables = disableControls, animation = animation, prop = prop, propTwo = propTwo,
        }, function(cancelled)
            if not cancelled then if onFinish then onFinish() end else if onCancel then onCancel() end end
        end)
        return
    end
    -- headless fallback: wait, then finish
    CreateThread(function()
        Wait(tonumber(duration) or 0)
        if onFinish then onFinish() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS (legacy export-per-function surface)
-- ═══════════════════════════════════════════════════════════════════════════════

exports('GetPlayerData', F.GetPlayerData)
exports('IsLoggedIn', F.IsLoggedIn)
exports('GetCoords', F.GetCoords)
exports('HasItem', F.HasItem)
exports('LoadModel', F.LoadModel)
exports('SpawnPed', F.SpawnPed)
exports('RemovePed', F.RemovePed)
exports('GetPeds', F.GetPeds)
exports('GetClosestPed', F.GetClosestPed)
exports('GetClosestPlayer', F.GetClosestPlayer)
exports('GetClosestVehicle', F.GetClosestVehicle)
exports('GetClosestObject', F.GetClosestObject)
exports('GetPlayersFromCoords', F.GetPlayersFromCoords)
exports('AttachProp', F.AttachProp)
exports('SpawnVehicle', F.SpawnVehicle)
exports('DeleteVehicle', F.DeleteVehicle)
exports('GetPlate', F.GetPlate)
exports('Progressbar', F.Progressbar)
exports('CreateBlip', F.CreateBlip)
exports('DeleteBlip', F.DeleteBlip)
exports('PlayAnim', F.PlayAnim)
exports('GetConfig', function() return Config end)
exports('GetItems', function() return LXRShared.Items end)
exports('GetJobs', function() return LXRShared.Jobs end)
exports('GetGangs', function() return LXRShared.Gangs end)
exports('GetWeapons', function() return LXRShared.Weapons end)
exports('GetHorses', function() return LXRShared.Horses end)
exports('GetVehicles', function() return LXRShared.Vehicles end)
exports('RandomStr', LXRShared.RandomStr)
exports('RandomInt', LXRShared.RandomInt)
exports('SplitStr', LXRShared.SplitStr)
exports('Trim', LXRShared.Trim)
exports('Round', LXRShared.Round)
exports('Debug', function(_, obj) print(json.encode(obj)) end)
