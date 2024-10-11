-- Player load and unload handling
-- New method for checking if logged in across all scripts (optional)
-- if LocalPlayer.state['isLoggedIn'] then
RegisterNetEvent('LXRCore:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    if LXRConfig.EnablePVP then
        Citizen.InvokeNative(0xF808475FA571D823, true)
        SetRelationshipBetweenGroups(5, `PLAYER`, `PLAYER`)
    end
    if LXRConfig.Player.RevealMap then
		SetMinimapHideFow(true)
	end
end)

RegisterNetEvent('LXRCore:Client:OnPlayerUnload', function()
    LocalPlayer.state:set('isLoggedIn', false, false)
end)

RegisterNetEvent('LXRCore:Client:PvpHasToggled', function(pvp_state)
    NetworkSetFriendlyFireOption(pvp_state)
end)

-- LXRCore Teleport Events
RegisterNetEvent('LXRCore:Command:TeleportToPlayer', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('LXRCore:Command:TeleportToCoords', function(x, y, z)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z)
end)

RegisterNetEvent('LXRCore:Command:GoToMarker', function()
    local PlayerPedId = PlayerPedId
    local GetEntityCoords = GetEntityCoords
    local GetGroundZAndNormalFor_3dCoord = GetGroundZAndNormalFor_3dCoord

    if not IsWaypointActive() then
        Notify(9, 'No Waypoint Set', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        return 'marker'
    end

    --Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped, coords <const> = PlayerPedId(), GetWaypointCoords()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end
        Citizen.InvokeNative(0x387AD749E3B69B70, x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while Citizen.InvokeNative(0xCF45DF50C7775F2A) do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        Citizen.InvokeNative(0x5A8B01199C3E79C3)
        SetEntityCoords(ped, x, y, z - 1000)
        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        --found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
        found, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z)
        if found then
            Wait(0)
            SetEntityCoords(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end

    -- Remove black screen once the loop has ended.
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetEntityCoords(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
        Notify(9, 'Error teleporting', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end

    -- If Z coord was found, set coords in found coords.
    SetEntityCoords(ped, x, y, groundZ)
    Notify(9, 'Teleported', 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
end)

-- Vehicle | Horse Events

RegisterNetEvent('LXRCore:Command:SpawnVehicle', function(model)
    local vehicle = exports['lxr-core']:SpawnVehicle(model)
	TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
end)

RegisterNetEvent('LXRCore:Command:DeleteVehicle', function()
	local ped = PlayerPedId()
	local vehicle = exports['lxr-core']:GetClosestVehicle()
	if IsPedInAnyVehicle(ped) then vehicle = GetVehiclePedIsIn(ped, false) end
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end)

RegisterNetEvent('LXRCore:Command:GetCoords', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped, false)
    local heading = GetEntityHeading(ped)
    AddTextEntry("FMMC_KEY_TIP12", "Coords")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP12", "", vector4(pos.x, pos.y, pos.z, heading), "", "", "", 150)
end)

RegisterNetEvent('LXRCore:Command:SpawnHorse', function(HorseName)
    local ped = PlayerPedId()
    local hash = tostring(HorseName)
    if hash then
        local animalHash = GetHashKey(hash)
        if not IsModelValid(animalHash) then return end
        local endlessLoop = 50
        while not HasModelLoaded(animalHash) and endlessLoop > 0 do 
            Wait(100) 
            endlessLoop = endlessLoop - 1
        end
        if endlessLoop <= 0 then return end
        
		local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.5))
        local npc = CreatePed(animalHash, x, y, z, GetEntityHeading(ped) + 90, 1, 0)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
        SetPedScale(npc, num)

        endlessLoop = 500
		while not Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, npc) and endlessLoop > 0 do
            Wait(0) 
            endlessLoop = endlessLoop - 1
        end
        if endlessLoop <= 0 then 
            DeleteEntity(npc)
            return 
        end
        
		Citizen.InvokeNative(0x704C908E9C405136, npc)
		Citizen.InvokeNative(0xAAB86462966168CE, npc, 1)
        Wait(500)
    else
		Notify(9, 'Model not found', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
    end
end)

-- Other stuff

RegisterNetEvent('LXRCore:Player:SetPlayerData', function(val)
    LXRCore.PlayerData = val
end)

RegisterNetEvent('LXRCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('LXRCore:UpdatePlayer')
end)

RegisterNetEvent('LXRCore:Notify', function(id, text, duration, subtext, dict, icon, color)
    Notify(id, text, duration, subtext, dict, icon, color)
end)

RegisterNetEvent('LXRCore:Client:UseItem', function(item)
    TriggerServerEvent('LXRCore:Server:UseItem', item)
end)

RegisterNetEvent('LXRCore:Client:TriggerCallback', function(name, ...)
    if LXRCore.ServerCallbacks[name] then
        LXRCore.ServerCallbacks[name](...)
        LXRCore.ServerCallbacks[name] = nil
    end
end)

-- Listen to Shared being updated
RegisterNetEvent('LXRCore:Client:OnSharedUpdate', function(tableName, key, value)
    LXRShared[tableName][key] = value
    TriggerEvent('LXRCore:Client:UpdateObject')
end)

RegisterNetEvent('LXRCore:Client:OnSharedUpdateMultiple', function(tableName, values)
    for key, value in pairs(values) do
        LXRShared[tableName][key] = value
    end
    TriggerEvent('LXRCore:Client:UpdateObject')
end)
