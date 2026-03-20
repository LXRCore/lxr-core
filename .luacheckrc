-- LXRCore Luacheck Configuration

std = "lua51+lua52+lua53"

-- Globals provided by the FXServer/RedM runtime
globals = {
    "LXRCore",
    "LXRConfig",
    "LXRFramework",
    "LXRShared",
    "Lang",
    "MySQL",
    "exports",
    "source",
    "Citizen",
    "CreateThread",
    "Wait",
    "RegisterNetEvent",
    "AddEventHandler",
    "TriggerEvent",
    "TriggerServerEvent",
    "TriggerClientEvent",
    "RegisterServerEvent",
    "RegisterCommand",
    "GetPlayerIdentifiers",
    "GetNumPlayerIdentifiers",
    "GetPlayerName",
    "GetPlayers",
    "DropPlayer",
    "GetCurrentResourceName",
    "GetResourceState",
    "GetResourceMetadata",
    "PlayerPedId",
    "GetEntityCoords",
    "GetEntityHeading",
    "DoesEntityExist",
    "SetEntityCoords",
    "NetworkGetEntityFromNetworkId",
    "NetworkGetNetworkIdFromEntity",
    "RequestModel",
    "HasModelLoaded",
    "IsModelValid",
    "vector2",
    "vector3",
    "vector4",
    "print",
    "json",
}

-- Read-only globals
read_globals = {
    "table",
    "string",
    "math",
    "os",
    "io",
    "pairs",
    "ipairs",
    "type",
    "tonumber",
    "tostring",
    "pcall",
    "xpcall",
    "error",
    "assert",
    "select",
    "unpack",
    "rawget",
    "rawset",
    "setmetatable",
    "getmetatable",
    "next",
    "require",
    "collectgarbage",
    "coroutine",
    "debug",
    "load",
    "loadstring",
    "dofile",
}

-- Ignore certain warnings
ignore = {
    "211",  -- Unused local variable
    "212",  -- Unused argument
    "213",  -- Unused loop variable
    "311",  -- Value assigned to local variable is unused
    "631",  -- Line too long
}

-- Exclude generated/vendor files
exclude_files = {
    "node_modules/",
    ".git/",
}

-- Max line length
max_line_length = 200
