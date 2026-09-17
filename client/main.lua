--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Client Core Object

    Client-side LXRCore object: replicated PlayerData, shared data, callbacks
    and RedM helpers (notifications, prompts, entities). No per-frame loops run
    in the core; everything is event or state-bag driven (0.00 ms idle).

    exports['lxr-core']:GetCoreObject() returns this table.

    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

LXRCore = LXRCore or {}
LXRCore.Config = Config
LXRCore.Shared = LXRShared
LXRCore.PlayerData = {}
LXRCore.Functions = LXRCore.Functions or {}
LXRCore.ClientCallbacks = {}
LXRCore.ServerCallbacks = {}
LXRCore.Peds = {}
LXRCore.Blips = {}
LXRCore.IsLoggedIn = false

local function GetCoreObject()
    return LXRCore
end
exports('GetCoreObject', GetCoreObject)
exports('GetCore', GetCoreObject)

-- Convenience: cache the local ped only when it changes (no polling loop).
LXRCore.Cache = { ped = PlayerPedId(), serverId = GetPlayerServerId(PlayerId()) }

AddEventHandler('LXRCore:Client:RefreshPed', function()
    LXRCore.Cache.ped = PlayerPedId()
end)

---True once the server confirmed a loaded character.
function LXRCore.Functions.IsLoggedIn()
    return LocalPlayer.state.isLoggedIn == true
end

---Current PlayerData (replicated by the server, read-only on the client).
---@param cb function|nil
function LXRCore.Functions.GetPlayerData(cb)
    if cb then cb(LXRCore.PlayerData) end
    return LXRCore.PlayerData
end
