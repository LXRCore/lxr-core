--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Compatibility Adapter: RSG-Core (client)
     ═══════════════════════════════════════════════════════════════════════════
     RSG resources obtain our core object through bridges/rsg-core and call
     RSGCore.Functions.* (our functions). This file covers the events they fire
     or listen to by name. Loop guards prevent LXR ↔ RSG event ping-pong.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not Config.Compat.rsg.enabled then return end

-- rsg-spawn / rsg-multicharacter announce the spawn with this event
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    if LXRCore.IsLoggedIn then return end -- re-fired by the core itself
    TriggerEvent('LXRCore:Client:OnPlayerLoaded')
    TriggerServerEvent('LXRCore:Server:OnPlayerLoaded')
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    if not LXRCore.IsLoggedIn then return end
    TriggerEvent('LXRCore:Client:OnPlayerUnload')
end)

RegisterNetEvent('RSGCore:Player:SetPlayerData', function(data)
    if type(data) == 'table' then LXRCore.PlayerData = data end
end)

RegisterNetEvent('RSGCore:Player:UpdatePlayerData', function()
    TriggerServerEvent('LXRCore:UpdatePlayer')
end)

RegisterNetEvent('RSGCore:Client:PvpHasToggled', function(state)
    TriggerEvent('LXRCore:Client:PvpHasToggled', state)
end)

-- Shared registry updates (server sends both names; keep RSG-only senders working)
RegisterNetEvent('RSGCore:Client:OnSharedUpdate', function(tbl, key, value)
    TriggerEvent('LXRCore:Client:OnSharedUpdate', tbl, key, value)
end)
RegisterNetEvent('RSGCore:Client:OnSharedUpdateMultiple', function(tbl, values)
    TriggerEvent('LXRCore:Client:OnSharedUpdateMultiple', tbl, values)
end)
RegisterNetEvent('RSGCore:Client:SharedUpdate', function(shared)
    TriggerEvent('LXRCore:Client:SharedUpdate', shared)
end)

-- RSG name-keyed callback protocol
RegisterNetEvent('RSGCore:Client:TriggerCallback', function(name, ...)
    local cb = LXRCore.ServerCallbacks[name]
    if cb then
        LXRCore.ServerCallbacks[name] = nil
        cb(...)
    end
end)

RegisterNetEvent('RSGCore:Client:TriggerClientCallback', function(name, ...)
    LXRCore.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('RSGCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- Admin command helpers
RegisterNetEvent('RSGCore:Command:TeleportToPlayer', function(coords) TriggerEvent('LXRCore:Command:TeleportToCoords', coords) end)
RegisterNetEvent('RSGCore:Command:TeleportToCoords', function(x, y, z) TriggerEvent('LXRCore:Command:TeleportToCoords', vector3(x, y, z)) end)
RegisterNetEvent('RSGCore:Command:GoToMarker', function() TriggerEvent('LXRCore:Command:GoToMarker') end)
RegisterNetEvent('RSGCore:Command:SpawnVehicle', function(model) TriggerEvent('LXRCore:Command:SpawnVehicle', model) end)
RegisterNetEvent('RSGCore:Command:DeleteVehicle', function() TriggerEvent('LXRCore:Command:DeleteVehicle') end)
RegisterNetEvent('RSGCore:Command:ShowMe3D', function(id, msg) TriggerEvent('LXRCore:Command:ShowMe3D', id, msg) end)

-- RSG client helpers that exist on RSGCore.Functions but not natively here
LXRCore.Functions.LookAtEntity = function(entity, timeout, speed)
    if not DoesEntityExist(entity) then return end
    TaskLookAtEntity(PlayerPedId(), entity, timeout or 2000, 2048, speed or 3, 0)
end

-- CSRF helper used by rsg-inventory NUI
local csrfToken
exports('GenerateCSRFToken', function()
    csrfToken = tostring(math.random(100000, 999999)) .. GetGameTimer()
    return csrfToken
end)
RegisterNUICallback('validateCSRF', function(data, cb)
    if csrfToken and data and data.clientToken == csrfToken then
        csrfToken = nil
        cb({ valid = true })
    else
        cb({ valid = false })
    end
end)
