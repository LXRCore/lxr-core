--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Compatibility Adapter: VORP Core (client)
     ═══════════════════════════════════════════════════════════════════════════
     Client-side vorp_core-shaped object returned by bridges/vorp_core:GetCore():
       Notify*(…)  → LXRCore.Functions.Notify
       Callback.Register / TriggerAsync / TriggerAwait → LXRCore.Callback
       RpcCall(name, cb, …) (deprecated VORP RPC) → TriggerAsync
     Plus the vorp:* notification events VORP scripts fire from the server.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not Config.Compat.vorp.enabled then return end

LXRCore.Compat = LXRCore.Compat or {}
local Core = {}
LXRCore.Compat.VorpClient = Core

local function n(text, kind) LXRCore.Functions.Notify(tostring(text or ''), kind or 'inform') end
local function pair(a, b, kind) LXRCore.Functions.Notify({ title = tostring(a or ''), description = tostring(b or ''), type = kind or 'inform' }) end

Core.NotifyTip = function(text) n(text) end
Core.NotifyLeft = function(title, subtitle) pair(title, subtitle) end
Core.NotifyRightTip = function(text) n(text) end
Core.NotifyObjective = function(text) n(text) end
Core.NotifyTop = function(text) n(text) end
Core.NotifySimpleTop = function(text, subtitle) pair(text, subtitle) end
Core.NotifyAdvanced = function(text) n(text) end
Core.NotifyBasicTop = function(text) n(text) end
Core.NotifyCenter = function(text) n(text) end
Core.NotifyBottomRight = function(text) n(text) end
Core.NotifyFail = function(text, subtitle) pair(text, subtitle, 'error') end
Core.NotifyDead = function(title) n(title, 'error') end
Core.NotifyUpdate = function(title, subtitle) pair(title, subtitle) end
Core.NotifyWarning = function(title, msg) pair(title, msg, 'error') end
Core.NotifyLeftRank = Core.NotifyLeft
Core.NotifyThreeSimpleTop = function(a, b, c) pair(a, ('%s — %s'):format(tostring(b), tostring(c))) end
Core.NotifyOneSimpleTop = function(title) n(title) end
Core.NotifyLeftInteractive = function(title, desc) pair(title, desc) end

Core.Callback = {
    Register = function(name, cb) LXRCore.Callback.RegisterLegacy(name, cb) end,
    TriggerAsync = function(name, cb, ...) LXRCore.Callback.Trigger(name, cb, ...) end,
    TriggerAwait = function(name, ...) return LXRCore.Callback.Await(name, ...) end,
}
Core.RpcCall = function(name, cb, ...) LXRCore.Callback.Trigger(name, cb, ...) end
Core.instancePlayers = function(set)
    -- VORP used routing buckets per player; LXR keeps that server-side (SetPlayerBucket)
    TriggerServerEvent('LXRCore:Server:RequestInstance', set)
end
Core.AddWebhook = function() end
Core.Utils = { ScreenResolution = function() local w, h = GetActiveScreenResolution() return w, h end }

-- Server-originated VORP notification events
RegisterNetEvent('vorp:Tip', function(text) n(text) end)
RegisterNetEvent('vorp:TipRight', function(text) n(text) end)
RegisterNetEvent('vorp:TipBottom', function(text) n(text) end)
RegisterNetEvent('vorp:NotifyLeft', function(title, subtitle) pair(title, subtitle) end)
RegisterNetEvent('vorp:NotifyTop', function(text) n(text) end)
RegisterNetEvent('vorp:ShowTopNotification', function(text, subtitle) pair(text, subtitle) end)
RegisterNetEvent('vorp:ShowAdvancedRightNotification', function(text) n(text) end)
RegisterNetEvent('vorp:ShowSimpleCenterText', function(text) n(text) end)
RegisterNetEvent('vorp:ShowBottomRight', function(text) n(text) end)
RegisterNetEvent('vorp:failmissioNotifY', function(text, subtitle) pair(text, subtitle, 'error') end)
RegisterNetEvent('vorp:deadplayerNotifY', function(title) n(title, 'error') end)
RegisterNetEvent('vorp:updatemissioNotify', function(title, subtitle) pair(title, subtitle) end)
RegisterNetEvent('vorp:warningNotify', function(title, msg) pair(title, msg, 'error') end)
RegisterNetEvent('vorp:LeftRank', function(title, subtitle) pair(title, subtitle) end)
RegisterNetEvent('vorp:ThreeSimpleTop', function(a, b, c) Core.NotifyThreeSimpleTop(a, b, c) end)
RegisterNetEvent('vorp:OneSimpleTop', function(title) n(title) end)
RegisterNetEvent('vorp:LeftInteractive', function(title, desc) pair(title, desc) end)

-- VORP callback wire protocol (for scripts that fire it manually)
RegisterNetEvent('vorp:ServerCallback', function(uniqueId, isSync, name, ...)
    local cb = LXRCore.ServerCallbacks[uniqueId] or LXRCore.ServerCallbacks[name]
    if cb then
        LXRCore.ServerCallbacks[uniqueId] = nil
        LXRCore.ServerCallbacks[name] = nil
        cb(...)
    end
end)

RegisterNetEvent('vorp:SelectedCharacter', function()
    if LXRCore.IsLoggedIn then return end
    TriggerEvent('lxr:client:loaded')
end)

exports('GetVorpCore', function() return Core end)
