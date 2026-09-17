--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: vorp_core (shared)
     exports.vorp_core:GetCore() → LXRCore VORP facade (server & client).
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = 'lxr-core'

exports('GetCore', function()
    return exports[CORE]:GetVorpCore()
end)

-- deprecated VORP acquisition event
AddEventHandler('getCore', function(cb)
    if type(cb) == 'function' then cb(exports[CORE]:GetVorpCore()) end
end)

if IsDuplicityVersion() then
    CreateThread(function()
        local mine = GetCurrentResourceName()
        if mine ~= 'vorp_core' then
            print(('^1[LXRCore bridge]^7 this resource must be named "vorp_core" (currently "%s")'):format(mine))
        end
        print('^2[LXRCore bridge]^7 vorp_core shim active — VORP resources are served by lxr-core')
    end)
else
    -- VORP client notification exports (vorp_core exposes these directly)
    local names = {
        'DisplayTip', 'DisplayLeftNotification', 'DisplayTopCenterNotification', 'DisplayTipRight', 'DisplayObjective',
        'ShowTopNotification', 'ShowAdvancedRightNotification', 'ShowSimpleCenterText', 'showBottomRight',
        'failmissioNotifY', 'deadplayerNotifY', 'updatemissioNotify', 'warningNotify', 'LeftRank',
        'ThreeSimpleTop', 'OneSimpleTop', 'LeftInteractive',
    }
    local map = {
        DisplayTip = 'NotifyTip', DisplayLeftNotification = 'NotifyLeft', DisplayTopCenterNotification = 'NotifyTop',
        DisplayTipRight = 'NotifyRightTip', DisplayObjective = 'NotifyObjective', ShowTopNotification = 'NotifySimpleTop',
        ShowAdvancedRightNotification = 'NotifyAdvanced', ShowSimpleCenterText = 'NotifyCenter', showBottomRight = 'NotifyBottomRight',
        failmissioNotifY = 'NotifyFail', deadplayerNotifY = 'NotifyDead', updatemissioNotify = 'NotifyUpdate',
        warningNotify = 'NotifyWarning', LeftRank = 'NotifyLeftRank', ThreeSimpleTop = 'NotifyThreeSimpleTop',
        OneSimpleTop = 'NotifyOneSimpleTop', LeftInteractive = 'NotifyLeftInteractive',
    }
    for _, name in ipairs(names) do
        exports(name, function(...)
            local core = exports[CORE]:GetVorpCore()
            local fn = core[map[name]]
            if fn then return fn(...) end
        end)
    end
end
