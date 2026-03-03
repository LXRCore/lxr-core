--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - Draw Text / HUD System
    
    Client-side text drawing utilities and NUI-based HUD elements for
    displaying on-screen text, help prompts, and UI notifications.
    
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
-- 🐺 LXR CORE - DRAW TEXT / HUD
-- ═══════════════════════════════════════════════════════════════════════════════


    SendNUIMessage({
        action = 'HIDE_TEXT',
    })
end

local function DrawText(text, position)
    if (not type(position) == "string") then position = "left" end

    SendNUIMessage({
        action = 'DRAW_TEXT',
        data = {
            text = text,
            position = position
        }
    })
end

local function ChangeText(text, position)
    if (not type(position) == "string") then position = "left" end

    SendNUIMessage({
        action = 'CHANGE_TEXT',
        data = {
            text = text,
            position = position
        }
    })
end

local function KeyPressed()
    Citizen.CreateThread(function() -- Not sure if a thread is needed but why not eh?
        SendNUIMessage({
            action = 'KEY_PRESSED',
        })
        Wait(500)
        HideText()
    end)
end

RegisterNetEvent('lxr-drawtext:client:DrawText', function(text, position)
    DrawText(text, position)
end)

RegisterNetEvent('lxr-drawtext:client:ChangeText', function(text, position)
    ChangeText(text, position)
end)

RegisterNetEvent('lxr-drawtext:client:HideText', function()
    HideText()
end)

RegisterNetEvent('lxr-drawtext:client:KeyPressed', function()
    KeyPressed()
end)

exports('DrawText', DrawText)
exports('ChangeText', ChangeText)
exports('HideText', HideText)
exports('KeyPressed', KeyPressed)