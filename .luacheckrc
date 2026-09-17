-- LXRCore luacheck configuration (FXServer Lua 5.4 runtime)
std = 'lua54'
max_line_length = 220
codes = true
ignore = { '212', '213', '631' } -- unused args / loop vars, long lines

exclude_files = { 'tests/lib/json.lua', '.git/' }

-- Runtime globals (Cfx natives are declared per file via read_globals below)
globals = {
    'LXRCore', 'LXRShared', 'LXRConfig', 'Config', 'Lang', 'Locale', 'T', 'json', 'source',
}

read_globals = {
    -- Cfx runtime
    'exports', 'Citizen', 'CreateThread', 'Wait', 'SetTimeout', 'promise', 'RegisterNetEvent', 'RegisterServerEvent',
    'AddEventHandler', 'TriggerEvent', 'TriggerServerEvent', 'TriggerClientEvent', 'CancelEvent', 'RegisterCommand',
    'RegisterNUICallback', 'SendNUIMessage', 'SetNuiFocus', 'GetCurrentResourceName', 'GetInvokingResource',
    'GetResourceState', 'GetResourceMetadata', 'LoadResourceFile', 'GetConvar', 'GetConvarInt', 'ExecuteCommand',
    'IsDuplicityVersion', 'GetGameTimer', 'GetHashKey', 'joaat', 'vector2', 'vector3', 'vector4', 'vec3',
    'GlobalState', 'LocalPlayer', 'Player', 'AddStateBagChangeHandler', 'MySQL',
    -- server natives
    'GetPlayerIdentifierByType', 'GetPlayerIdentifiers', 'GetPlayerName', 'GetPlayers', 'GetNumPlayerIndices',
    'GetPlayerPed', 'GetPlayerPing', 'DropPlayer', 'IsPlayerAceAllowed', 'SetPlayerRoutingBucket', 'SetEntityRoutingBucket',
    'GetEntityCoords', 'GetEntityHeading', 'GetAllObjects', 'GetAllVehicles', 'GetAllPeds', 'CreateVehicle', 'DoesEntityExist',
    'TaskWarpPedIntoVehicle', 'NetworkGetNetworkIdFromEntity',
    -- client natives
    'PlayerPedId', 'PlayerId', 'GetPlayerServerId', 'GetPlayerFromServerId', 'GetActivePlayers', 'GetGamePool',
    'SetEntityCoords', 'SetEntityCoordsNoOffset', 'GetGroundZAndNormalFor_3dCoord', 'GetHeightmapBottomZForPosition',
    'IsWaypointActive', 'GetWaypointCoords', 'GetMount', 'IsModelInCdimage', 'IsModelValid', 'HasModelLoaded', 'RequestModel',
    'SetModelAsNoLongerNeeded', 'HasAnimDictLoaded', 'RequestAnimDict', 'RemoveAnimDict', 'TaskPlayAnim', 'CreatePed',
    'SetEntityAsMissionEntity', 'SetBlockingOfNonTemporaryEvents', 'FreezeEntityPosition', 'SetEntityInvincible', 'DeleteEntity',
    'CreateObject', 'GetEntityBoneIndexByName', 'AttachEntityToEntity', 'SetNetworkIdCanMigrate', 'DeleteVehicle',
    'GetVehiclePedIsIn', 'GetLabelText', 'GetDisplayNameFromVehicleModel', 'GetEntityModel', 'SetBlipSprite', 'SetBlipScale',
    'RemoveBlip', 'ShutdownLoadingScreenNui', 'SetMinimapHideFow', 'SetRelationshipBetweenGroups', 'SetPedPromptName',
    'RequestStreamedTextureDict', 'HasStreamedTextureDictLoaded', 'CreateVarString', 'SetTextScale', 'SetTextColor',
    'SetTextCentre', 'SetTextFontForCurrentCommand', 'DisplayText', 'GetScreenCoordFromWorldCoord', 'GetGameplayCamCoord',
    'GetGameplayCamFov', 'DrawMarker', 'GetRandomIntInRange', 'GetActiveScreenResolution', 'TaskLookAtEntity',
    'PromptRegisterBegin', 'PromptSetControlAction', 'PromptSetText', 'PromptSetEnabled', 'PromptSetVisible',
    'PromptSetStandardizedHoldMode', 'PromptSetStandardMode', 'PromptSetGroup', 'PromptRegisterEnd',
    'PromptHasHoldModeCompleted', 'PromptHasStandardModeCompleted', 'PromptDelete', 'PromptSetActiveGroupThisFrame',
}

files['tests/**'] = { globals = { 'Shim', 'T', 'arg' }, ignore = { '111', '112', '113', '121', '122', '142', '143' } }
files['tests/lib/fxshim.lua'] = { ignore = { '111', '112', '113', '121', '122', '131', '142', '143' } }
