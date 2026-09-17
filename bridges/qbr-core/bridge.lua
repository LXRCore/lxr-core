--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: qbr-core (shared)
     QBR resources call exports['qbr-core']:<Function>(…). LXRCore registers the
     same export-per-function surface, so every call is forwarded by name.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = 'lxr-core'

local SERVER = {
    'GetPlayers', 'GetQBPlayers', 'GetLXRPlayers', 'GetIdentifier', 'GetPlayer', 'GetPlayerByCitizenId', 'GetPlayersOnDuty', 'GetDutyCount',
    'CreateCallback', 'TriggerCallback', 'CreateUseableItem', 'CanUseItem', 'UseItem', 'KickPlayer', 'AddPermission', 'RemovePermission',
    'HasPermission', 'GetPermissions', 'IsOptin', 'ToggleOptin', 'Login', 'Logout', 'DeleteCharacter', 'AddCommand', 'RefreshCommands',
    'ShowError', 'ShowSuccess', 'Debug', 'AddJob', 'AddJobs', 'AddItem', 'AddItems', 'AddGang', 'AddGangs',
    'GetTotalWeight', 'GetSlotsByItem', 'GetFirstSlotByItem', 'GetConfig', 'GetItems', 'GetItem', 'GetJobs', 'GetGangs', 'GetWeapons',
    'GetHorses', 'GetVehicles', 'RandomStr', 'RandomInt', 'SplitStr', 'Trim', 'Round', 'GetCoreObject', 'GetCore',
}

local CLIENT = {
    'GetPlayerData', 'GetCoords', 'HasItem', 'Debug', 'TriggerCallback', 'LoadModel', 'SpawnPed', 'RemovePed', 'GetPeds', 'GetClosestPed',
    'GetClosestPlayer', 'GetPlayersFromCoords', 'GetClosestVehicle', 'GetClosestObject', 'AttachProp', 'SpawnVehicle', 'GetPlate',
    'DeleteVehicle', 'Progressbar', 'Notify', 'CreateBlip', 'DeleteBlip', 'DrawText', 'DrawText3D',
    'createPrompt', 'createPromptGroup', 'getPrompt', 'getPromptGroup', 'deletePrompt', 'deletePromptGroup',
    'ShowAdvancedLeftNotification', 'ShowAdvancedRightNotification', 'ShowBasicTopNotification', 'ShowLocationNotification',
    'ShowObjective', 'ShowSimpleCenterText', 'ShowTooltip', 'ShowTopNotification', 'DisplayRightText',
    'GetConfig', 'GetItems', 'GetJobs', 'GetGangs', 'GetWeapons', 'GetHorses', 'GetVehicles', 'RandomStr', 'RandomInt', 'SplitStr', 'Trim', 'Round',
    'GetCoreObject', 'GetCore',
}

local list = IsDuplicityVersion() and SERVER or CLIENT
for _, name in ipairs(list) do
    exports(name, function(...)
        return exports[CORE][name](nil, ...)
    end)
end

if IsDuplicityVersion() then
    CreateThread(function()
        local mine = GetCurrentResourceName()
        if mine ~= 'qbr-core' then
            print(('^1[LXRCore bridge]^7 this resource must be named "qbr-core" (currently "%s")'):format(mine))
        end
        print('^2[LXRCore bridge]^7 qbr-core shim active — QBR resources are served by lxr-core')
    end)
end
