--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Client Event Handlers
     ═══════════════════════════════════════════════════════════════════════════
     Lifecycle, PlayerData replication, shared-data sync, admin command helpers.
     The login flag is a replicated state bag (LocalPlayer.state.isLoggedIn)
     so any resource can read it without an event subscription.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 👤 PLAYER LIFECYCLE
-- ═══════════════════════════════════════════════════════════════════════════════

local function applyWorldSettings()
    local ped = PlayerPedId()
    if Config.General.enablePVP then
        Citizen.InvokeNative(0xF808475FA571D823, true)             -- NetworkSetFriendlyFireOption
        SetRelationshipBetweenGroups(5, joaat('PLAYER'), joaat('PLAYER'))
    end
    if Config.General.revealMap then SetMinimapHideFow(true) end
    Citizen.InvokeNative(0x39363DFD04E91496, PlayerId(), true)     -- enable mercy kill
    Citizen.InvokeNative(0x8899C244EBCF70DE, ped, 0.0)             -- SetPlayerHealthRechargeMultiplier
    Citizen.InvokeNative(0xDE1B1907A83A1550, ped, 0.0)             -- SetHealthRechargeMultiplier
end

-- Legacy event names are re-fired locally for old resources that listen to them.
-- `mirroring` stops the alias handlers from re-entering the native handler.
local mirroring = false
local function mirror(name, ...)
    if not Config.Compat.legacy.enabled or mirroring then return end
    mirroring = true
    TriggerEvent(name, ...)
    mirroring = false
end
local function alias(name, fn)
    RegisterNetEvent(name, function(...) if not mirroring then fn(...) end end)
end

-- Native: lxr:client:loaded — fired by spawn resources once the character stands in the world.
local function onLoaded()
    if LXRCore.IsLoggedIn then return end
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    LXRCore.IsLoggedIn = true
    LXRCore.Cache.ped = PlayerPedId()
    applyWorldSettings()
    TriggerEvent('lxr:client:loaded:done')
    mirror('LXRCore:Client:OnPlayerLoaded')
    if Config.Compat.rsg.enabled then TriggerEvent('RSGCore:Client:OnPlayerLoaded') end
end
RegisterNetEvent('lxr:client:loaded', onLoaded)
alias('LXRCore:Client:OnPlayerLoaded', onLoaded)

local function onUnloaded()
    if not LXRCore.IsLoggedIn then return end
    LocalPlayer.state:set('isLoggedIn', false, false)
    LXRCore.IsLoggedIn = false
    LXRCore.PlayerData = {}
    TriggerEvent('lxr:client:unloaded:done')
    mirror('LXRCore:Client:OnPlayerUnload')
end
RegisterNetEvent('lxr:client:unloaded', onUnloaded)
alias('LXRCore:Client:OnPlayerUnload', onUnloaded)

local function onData(data)
    if type(data) ~= 'table' then return end
    LXRCore.PlayerData = data
    TriggerEvent('lxr:client:data:done', data)
    mirror('LXRCore:Player:SetPlayerData', data)
    if Config.Compat.legacy.enabled then TriggerEvent('LXRCore:Client:OnPlayerDataUpdate', data) end
end
RegisterNetEvent('lxr:client:data', onData)
alias('LXRCore:Player:SetPlayerData', onData)

RegisterNetEvent('LXRCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('LXRCore:UpdatePlayer')
end)

local function onPvp(state)
    Config.General.enablePVP = state == true
    Citizen.InvokeNative(0xF808475FA571D823, state == true)
    SetRelationshipBetweenGroups(state and 5 or 1, joaat('PLAYER'), joaat('PLAYER'))
end
RegisterNetEvent('lxr:client:pvp', onPvp)
RegisterNetEvent('LXRCore:Client:PvpHasToggled', onPvp) -- legacy name

-- Ped handle changes on respawn / model swap; refresh the cache lazily.
AddEventHandler('playerSpawned', function()
    LXRCore.Cache.ped = PlayerPedId()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 SHARED DATA SYNC
-- ═══════════════════════════════════════════════════════════════════════════════

local function sharedChanged()
    TriggerEvent('lxr:client:shared:done')
    if Config.Compat.legacy.enabled then TriggerEvent('LXRCore:Client:UpdateObject') end
    if Config.Compat.rsg.enabled then TriggerEvent('RSGCore:Client:UpdateObject') end
end

local function onSharedOne(tbl, key, value)
    if type(tbl) ~= 'string' or LXRShared[tbl] == nil then return end
    LXRShared[tbl][key] = value
    sharedChanged()
end
RegisterNetEvent('lxr:client:shared', onSharedOne)
RegisterNetEvent('LXRCore:Client:OnSharedUpdate', onSharedOne) -- legacy name

local function onSharedMany(tbl, values)
    if type(tbl) ~= 'string' or LXRShared[tbl] == nil or type(values) ~= 'table' then return end
    for k, v in pairs(values) do LXRShared[tbl][k] = v end
    sharedChanged()
end
RegisterNetEvent('lxr:client:sharedMany', onSharedMany)
RegisterNetEvent('LXRCore:Client:OnSharedUpdateMultiple', onSharedMany) -- legacy name

local function onSharedAll(shared)
    if type(shared) ~= 'table' then return end
    for k, v in pairs(shared) do LXRShared[k] = v end
    LXRCore.Shared = LXRShared
    sharedChanged()
end
RegisterNetEvent('lxr:client:sharedAll', onSharedAll)
RegisterNetEvent('LXRCore:Client:SharedUpdate', onSharedAll) -- legacy name

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🛠️ ADMIN COMMAND HELPERS (server-initiated only)
-- ═══════════════════════════════════════════════════════════════════════════════

local function placeOnGround(entity, coords)
    local found, groundZ = GetGroundZAndNormalFor_3dCoord(coords.x, coords.y, coords.z)
    SetEntityCoordsNoOffset(entity, coords.x, coords.y, found and groundZ or coords.z, true, true, true)
end

local function teleport(coords)
    if type(coords) ~= 'vector3' and type(coords) ~= 'table' then return end
    local ped = PlayerPedId()
    local mount = GetMount(ped)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if mount and mount ~= 0 then
        SetEntityCoords(mount, coords.x, coords.y, coords.z, false, false, false, false)
        Citizen.InvokeNative(0x028F76B6E78246EB, ped, mount, -1) -- TaskMountAnimal
    end
end
RegisterNetEvent('lxr:client:teleport', teleport)
RegisterNetEvent('LXRCore:Command:TeleportToCoords', teleport) -- legacy name

local function teleportMarker()
    if not IsWaypointActive() then
        return LXRCore.Functions.Notify(Lang:t('error.no_waypoint'), 'error')
    end
    local wp = GetWaypointCoords()
    local ped = PlayerPedId()
    local z = GetHeightmapBottomZForPosition(wp.x, wp.y)
    SetEntityCoords(ped, wp.x, wp.y, z + 3.0, false, false, false, false)
    placeOnGround(ped, vector3(wp.x, wp.y, z + 3.0))
    LXRCore.Functions.Notify(Lang:t('success.teleported_waypoint'), 'success')
end
RegisterNetEvent('lxr:client:teleportMarker', teleportMarker)
RegisterNetEvent('LXRCore:Command:GoToMarker', teleportMarker) -- legacy name

local function spawnVehicle(model)
    local ped = PlayerPedId()
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return LXRCore.Functions.Notify(Lang:t('error.vehicle_not_driveable'), 'error') end
    local current = GetVehiclePedIsIn(ped, false)
    if current ~= 0 then LXRCore.Functions.DeleteVehicle(current) end
    LXRCore.Functions.SpawnVehicle(hash, nil, LXRCore.Functions.GetCoords(ped), true, true)
end
RegisterNetEvent('lxr:client:vehicle:spawn', spawnVehicle)
RegisterNetEvent('LXRCore:Command:SpawnVehicle', spawnVehicle) -- legacy name

local function deleteVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then return LXRCore.Functions.DeleteVehicle(veh) end
    local pos = GetEntityCoords(ped)
    for _, v in ipairs(GetGamePool('CVehicle')) do
        if #(pos - GetEntityCoords(v)) <= 5.0 then LXRCore.Functions.DeleteVehicle(v) end
    end
end
RegisterNetEvent('lxr:client:vehicle:delete', deleteVehicle)
RegisterNetEvent('LXRCore:Command:DeleteVehicle', deleteVehicle) -- legacy name

local function showMe(senderId, msg)
    -- lxr-me renders /me through a NUI overlay (Georgian-capable font); the native text stays off then
    local renderer = Config.Commands.meRenderer or 'auto'
    if renderer == 'lxr-me' or (renderer == 'auto' and GetResourceState('lxr-me') == 'started') then return end
    local sender = GetPlayerFromServerId(senderId)
    if sender == -1 then return end
    CreateThread(function()
        local until_ = GetGameTimer() + (Config.Commands.meDurationMs or 10000)
        while GetGameTimer() < until_ do
            local ped = GetPlayerPed(sender)
            if ped == 0 then return end
            local c = GetEntityCoords(ped)
            LXRCore.Functions.DrawText3D(c.x, c.y, c.z + 1.0, msg)
            Wait(0)
        end
    end)
end
RegisterNetEvent('lxr:client:me', showMe)
RegisterNetEvent('LXRCore:Command:ShowMe3D', showMe) -- legacy name

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🏷️ OVERHEAD NAMES — refreshed on demand, not every 5 s
-- ═══════════════════════════════════════════════════════════════════════════════

if Config.General.hidePlayerNames then
    local function hideNames()
        for _, player in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            if ped and ped ~= 0 then
                SetPedPromptName(ped, ('Stranger (%s)'):format(GetPlayerServerId(player)))
            end
        end
    end
    AddEventHandler('lxr:client:loaded:done', hideNames)
    AddStateBagChangeHandler('isLoggedIn', nil, function(bagName, _, value)
        if value == true then SetTimeout(1000, hideNames) end
    end)
    -- players joining after us are covered by the state-bag handler above; a slow
    -- 30 s sweep catches ped swaps (outfits / respawns) without per-frame cost
    CreateThread(function()
        while true do
            Wait(30000)
            if LocalPlayer.state.isLoggedIn then hideNames() end
        end
    end)
end
