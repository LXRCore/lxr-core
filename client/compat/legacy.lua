--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Compatibility Adapter: Legacy LXR (v1/v2) & QBR (client)
     ═══════════════════════════════════════════════════════════════════════════
     Legacy resources use export-per-function calls (registered in
     client/functions.lua / notify.lua / prompts.lua) and the numeric-id
     notification exports below. QBRCore:* event names are forwarded.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not Config.Compat.legacy.enabled then return end

local RES = LXRCore.ResourceName

-- Legacy QBR notification exports are already provided by notify.js; these
-- wrappers keep the older Lua-side names with identical argument order.
exports('ShowSimpleTopNotification', function(text, duration) exports[RES]:ShowBasicTopNotification(text, duration) end)
exports('KeyPressed', function() return false end) -- removed: use prompts

RegisterNetEvent('QBRCore:Client:OnPlayerLoaded', function()
    if LXRCore.IsLoggedIn then return end
    TriggerEvent('LXRCore:Client:OnPlayerLoaded')
end)
RegisterNetEvent('QBRCore:Player:SetPlayerData', function(data)
    if type(data) == 'table' then LXRCore.PlayerData = data end
end)
RegisterNetEvent('QBRCore:Client:TriggerCallback', function(name, ...)
    local cb = LXRCore.ServerCallbacks[name]
    if cb then
        LXRCore.ServerCallbacks[name] = nil
        cb(...)
    end
end)
RegisterNetEvent('QBRCore:Notify', function(...) LXRCore.Functions.Notify(...) end)
