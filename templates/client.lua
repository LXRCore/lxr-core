-- LXRCore Client-Side Resource Template
-- Replace 'your-resource' with your resource name

local LXRCore = exports['lxr-core']:GetCoreObject()
local PlayerData = {}

-- ══════════════════════════════════════════════════════════════
-- PLAYER LOADED / UNLOADED
-- ══════════════════════════════════════════════════════════════

RegisterNetEvent('LXRCore:Client:OnPlayerLoaded', function()
    PlayerData = LXRCore.Functions.GetPlayerData()
    -- Initialize your resource here
end)

RegisterNetEvent('LXRCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    -- Clean up your resource here
end)

-- ══════════════════════════════════════════════════════════════
-- EVENTS
-- ══════════════════════════════════════════════════════════════

RegisterNetEvent('your-resource:client:notify', function(message, type)
    -- type: 'success', 'error', 'info'
    TriggerEvent('LXRCore:Notify', message, type)
end)

-- ══════════════════════════════════════════════════════════════
-- CALLBACKS
-- ══════════════════════════════════════════════════════════════

-- Example: Request data from server
local function requestData(callback)
    LXRCore.Functions.TriggerCallback('your-resource:server:getData', function(result)
        if result then
            callback(result)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
-- THREADS
-- ══════════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        Wait(1000) -- Check every second, adjust as needed

        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            -- Your periodic logic here
        end

        -- Use longer waits when not needed to save performance
        -- Wait(5000) for less critical checks
    end
end)

-- ══════════════════════════════════════════════════════════════
-- NUI CALLBACKS (if using NUI)
-- ══════════════════════════════════════════════════════════════

-- RegisterNUICallback('action', function(data, cb)
--     -- Handle NUI action
--     cb({ success = true })
-- end)
