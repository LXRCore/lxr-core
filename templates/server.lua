-- LXRCore Server-Side Resource Template
-- Replace 'your-resource' with your resource name

local LXRCore = exports['lxr-core']:GetCoreObject()

-- ══════════════════════════════════════════════════════════════
-- CALLBACKS
-- ══════════════════════════════════════════════════════════════

LXRCore.Functions.CreateCallback('your-resource:server:getData', function(source, cb)
    local Player = LXRCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    -- Your logic here
    cb({ success = true })
end)

-- ══════════════════════════════════════════════════════════════
-- EVENTS
-- ══════════════════════════════════════════════════════════════

RegisterNetEvent('your-resource:server:action', function(data)
    local src = source
    local Player = LXRCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Validate input
    if not data or type(data) ~= 'table' then return end

    -- Your logic here
end)

-- ══════════════════════════════════════════════════════════════
-- COMMANDS
-- ══════════════════════════════════════════════════════════════

RegisterCommand('yourcommand', function(source, args, rawCommand)
    local Player = LXRCore.Functions.GetPlayer(source)
    if not Player then return end

    -- Your command logic here
end, false) -- false = no ace permission required

-- ══════════════════════════════════════════════════════════════
-- DATABASE OPERATIONS
-- ══════════════════════════════════════════════════════════════

-- Example: Fetch data
local function fetchPlayerData(citizenId)
    local result = MySQL.query.await('SELECT * FROM your_table WHERE citizenid = ?', { citizenId })
    if not result or #result == 0 then return nil end
    return result[1]
end

-- Example: Save data
local function savePlayerData(citizenId, data)
    MySQL.update('UPDATE your_table SET data = ? WHERE citizenid = ?',
        { json.encode(data), citizenId })
end
