--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Compatibility Adapter: RSG-Core (server)
     ═══════════════════════════════════════════════════════════════════════════
     The LXRCore object is already RSG-shaped (Functions / Player / Players /
     Shared / Config / Commands). This file answers the RSGCore:* net events an
     unmodified RSG resource fires, so together with bridges/rsg-core (which
     exports GetCoreObject under the rsg-core resource name) RSG resources run
     without edits. Lifecycle events (RSGCore:Server:PlayerLoaded, OnJobUpdate,
     OnMoneyChange, …) are emitted by the core modules themselves.

     Known limits (documented, not faked):
       • RSG resources that query RSG-only tables directly (playerskins,
         player_horses, …) need those tables — install the matching resource.
       • ox_lib is not provided by the core; RSG resources declare it themselves.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not Config.Compat.rsg.enabled then return end

local buckets = {}
local function limited(src)
    local rl = Config.Security.eventRateLimit
    return rl and not LXRCore.RateLimit(buckets, src, rl.burst, rl.windowMs)
end

-- Server callbacks (name-keyed RSG protocol)
RegisterNetEvent('RSGCore:Server:TriggerCallback', function(name, ...)
    local src = source
    if limited(src) or type(name) ~= 'string' then return end
    LXRCore.Callback.Invoke(name, src, function(...)
        TriggerClientEvent('RSGCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Client callback answers (RSG stores the handler by name)
RegisterNetEvent('RSGCore:Server:TriggerClientCallback', function(name, ...)
    local cb = LXRCore.ClientCallbacks[name]
    if cb then
        LXRCore.ClientCallbacks[name] = nil
        cb(...)
    end
end)

RegisterNetEvent('RSGCore:UpdatePlayer', function()
    TriggerEvent('LXRCore:UpdatePlayer')
end)

RegisterNetEvent('RSGCore:Server:SetMetaData', function(meta, data)
    local src = source
    if limited(src) then return end
    local player = LXRCore.Players[src]
    if not player or type(meta) ~= 'string' or type(data) ~= 'number' then return end
    for _, k in ipairs(Config.Security.clientMetadataWhitelist or {}) do
        if k == meta then player.Functions.SetMetaData(meta, data) return end
    end
    LXRCore.Log.exploit(src, 'RSG SetMetaData on protected key', { key = meta })
end)

RegisterNetEvent('RSGCore:ToggleDuty', function()
    local src = source
    if limited(src) then return end
    local player = LXRCore.Players[src]
    if not player then return end
    player.Functions.SetJobDuty(not player.PlayerData.job.onduty)
    TriggerClientEvent('LXRCore:Notify', src, player.PlayerData.job.onduty and Lang:t('info.on_duty') or Lang:t('info.off_duty'))
end)

RegisterNetEvent('RSGCore:CallCommand', function(command, args)
    local src = source
    if not LXRCore.Players[src] then return end
    LXRCore.Commands.Call(src, command, args)
end)

RegisterNetEvent('RSGCore:Server:CloseServer', function(reason)
    TriggerEvent('LXRCore:Server:CloseServer', reason)
end)

RegisterNetEvent('RSGCore:Server:OpenServer', function()
    TriggerEvent('LXRCore:Server:OpenServer')
end)

RegisterNetEvent('RSGCore:Server:KickCSRF', function()
    DropPlayer(source, 'CSRF validation failed')
end)

-- RSG names the vehicle callback differently
LXRCore.Functions.CreateCallback('RSGCore:Server:SpawnVehicle', function(src, cb, model, coords, warp)
    LXRCore.Callback.Invoke('LXRCore:Server:SpawnVehicle', src, cb, model, coords, warp)
end)

-- Deprecated exploitable RSG events: log only.
for _, ev in ipairs({ 'RSGCore:Server:UseItem', 'RSGCore:Server:RemoveItem', 'RSGCore:Server:AddItem' }) do
    RegisterNetEvent(ev, function()
        LXRCore.Log.exploit(source, ('deprecated RSG client event %s called'):format(ev), { resource = GetInvokingResource() })
    end)
end

LXRCore.Log.info('compat', 'RSG-Core adapter active (events + aces)')
