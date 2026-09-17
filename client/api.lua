--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Native API (client)

        local LXR = exports['lxr-core']:GetLXR()

        if LXR.Player.IsLoaded() then … end
        local job = LXR.Player.Job()
        local ok, err = LXR.RPC.Server('shop:buy', 'bread', 2)
        LXR.UI.Notify('Bought bread', 'success')
        LXR.Events.On('lxr:client:job', function(job) … end)

    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

LXR = LXR or {}
LXR.Version = LXRCore.Version
LXR.ApiLevel = LXRCore.ApiLevel
LXR.Config = Config
LXR.Shared = LXRShared
LXR.Utils = LXRShared
LXR.Locale = Lang

local F = LXRCore.Functions

LXR.Player = {
    IsLoaded = function() return LocalPlayer.state.isLoggedIn == true end,
    Data = function() return LXRCore.PlayerData end,
    CitizenId = function() return LXRCore.PlayerData.citizenid end,
    CharInfo = function() return LXRCore.PlayerData.charinfo or {} end,
    Job = function() return LXRCore.PlayerData.job or {} end,
    OnDuty = function() return LXRCore.PlayerData.job and LXRCore.PlayerData.job.onduty == true end,
    Gang = function() return LXRCore.PlayerData.gang or {} end,
    Money = function(account) return LXRCore.PlayerData.money and LXRCore.PlayerData.money[account] or 0 end,
    Meta = function(key) return LXRCore.PlayerData.metadata and LXRCore.PlayerData.metadata[key] end,
    Items = function() return LXRCore.PlayerData.items or {} end,
    HasItem = F.HasItem,
    Ped = function() return PlayerPedId() end,
    Coords = function() return F.GetCoords(PlayerPedId()) end,
    ServerId = function() return GetPlayerServerId(PlayerId()) end,
    ---Ask the server to persist now (rate limited server-side).
    Save = function() TriggerServerEvent('lxr:player:save') end,
    ToggleDuty = function() TriggerServerEvent('lxr:player:duty') end,
    ---Client-settable status keys only (Config.Security.clientMetadataWhitelist).
    SetStatus = function(key, value) TriggerServerEvent('lxr:player:meta', key, value) end,
    ---Tell the framework the character now stands in the world (spawn resources).
    Spawned = function()
        TriggerEvent('lxr:client:loaded')
        TriggerServerEvent('lxr:player:spawned')
    end,
}

LXR.RPC = {
    ---Ask the server and yield: local a, b = LXR.RPC.Server('name', ...)
    Server = LXRCore.Callback.Await,
    ---Ask the server, answer in cb.
    ServerAsync = LXRCore.Callback.Trigger,
    ---Answer server → client requests: fn(...) return ...
    Register = LXRCore.Callback.Register,
}

LXR.UI = {
    Notify = F.Notify,
    Prompts = LXRCore.Prompts,
    DrawText = F.DrawText,
    DrawText3D = F.DrawText3D,
    Progress = F.Progressbar,
}

LXR.World = {
    LoadModel = F.LoadModel,
    LoadAnimDict = F.RequestAnimDict,
    PlayAnim = F.PlayAnim,
    SpawnPed = F.SpawnPed,
    RemovePed = F.RemovePed,
    AttachProp = F.AttachProp,
    SpawnVehicle = F.SpawnVehicle,
    DeleteVehicle = F.DeleteVehicle,
    Plate = F.GetPlate,
    ClosestPlayer = F.GetClosestPlayer,
    ClosestPed = F.GetClosestPed,
    ClosestVehicle = F.GetClosestVehicle,
    ClosestObject = F.GetClosestObject,
    PlayersNear = F.GetPlayersFromCoords,
    Blip = F.CreateBlip,
    RemoveBlip = F.DeleteBlip,
    Coords = F.GetCoords,
}

LXR.Items = {
    Get = function(name) return LXRShared.Items[tostring(name):lower()] end,
    All = function() return LXRShared.Items end,
    Use = function(slotOrItem) TriggerServerEvent('lxr:item:use', slotOrItem) end,
}

LXR.Roles = {
    Job = function(name) return LXRShared.Jobs[name] end,
    Jobs = function() return LXRShared.Jobs end,
    Gang = function(name) return LXRShared.Gangs[name] end,
    Gangs = function() return LXRShared.Gangs end,
}

LXR.Events = {
    On = function(name, fn) return AddEventHandler(name, fn) end,
    OnNet = function(name, fn) return RegisterNetEvent(name, fn) end,
    Emit = function(name, ...) TriggerEvent(name, ...) end,
    EmitServer = function(name, ...) TriggerServerEvent(name, ...) end,
}

LXR.Commands = {
    Run = function(name, args) TriggerServerEvent('lxr:command:call', name, args or {}) end,
}

exports('GetLXR', function() return LXR end)
