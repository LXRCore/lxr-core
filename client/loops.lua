--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - Client Loops
    
    FPS-aware client-side loops for continuous state tracking, health
    monitoring, and periodic client-server synchronization.
    
    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════
    
    Server:      The Land of Wolves 🐺
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    Store:       https://theluxempire.tebex.io
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXR CORE - CLIENT LOOPS
-- ═══════════════════════════════════════════════════════════════════════════════

local sid = GetPlayerServerId(PlayerId())
local isLoggedIn = false

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(sid), function(_, _, value)
    isLoggedIn = value
end)

-- Performance: Optimized loop with proper wait times
CreateThread(function()
    while true do
        if isLoggedIn then
            Wait((1000 * 60) * LXRConfig.UpdateInterval)
            TriggerServerEvent('LXRCore:UpdatePlayer')
        else
            -- Wait longer when not logged in to save resources
            Wait(5000)
        end
    end
end)
