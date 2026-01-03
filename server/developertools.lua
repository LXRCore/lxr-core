--[[
    LXRCore - Supreme Developer Debug & Monitoring System
    
    Comprehensive debugging and monitoring tools for developers
    Real-time issue tracking, API endpoints, error logging, and performance metrics
    
    Features:
    1. Real-time error tracking
    2. Performance profiling
    3. Database query monitoring
    4. Event flow debugging
    5. Player state inspection
    6. Resource monitoring
    7. API endpoints for external tools
    8. Debug console with commands
    9. Stack trace analysis
    10. Memory leak detection
    
    For Server Owners:
    - Enable debug mode in config.lua
    - Access debug panel at /debug
    - Set log levels (info, warn, error, critical)
    
    For Developers:
    - Use LXRDebug:Log() for enhanced logging
    - Profile functions with LXRDebug:Profile()
    - Inspect player state with /debug:player
    - Monitor events with /debug:events
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
    
    Version: 2.0.0
]]--

LXRDebug = {}
LXRDebug.Logs = {}
LXRDebug.Errors = {}
LXRDebug.Performance = {}
LXRDebug.Events = {}
LXRDebug.Profiling = {}

-- ============================================
-- CONFIGURATION
-- ============================================

local config = {
    enabled = LXRConfig.Debug and LXRConfig.Debug.Enabled or false,
    logLevel = LXRConfig.Debug and LXRConfig.Debug.LogLevel or 'info', -- info, warn, error, critical
    maxLogs = 1000,              -- Maximum logs to keep in memory
    maxErrors = 500,             -- Maximum errors to keep
    profileEnabled = true,       -- Enable function profiling
    eventTracking = true,        -- Track event flow
    apiEnabled = true,           -- Enable API endpoints
    webUI = true,                -- Enable web UI for debugging
    dbQueryLogging = true,       -- Log all database queries
    stackTraceDepth = 10,        -- Stack trace depth for errors
}

-- Log levels
local LOG_LEVELS = {
    debug = 0,
    info = 1,
    warn = 2,
    error = 3,
    critical = 4
}

local currentLogLevel = LOG_LEVELS[config.logLevel] or LOG_LEVELS.info

-- ============================================
-- ENHANCED LOGGING SYSTEM
-- ============================================

--[[
    Developer Note:
    Use this instead of print() for better debugging
    
    Example:
    LXRDebug:Log('info', 'Player joined', {playerId = source, name = name})
    LXRDebug:Log('error', 'Database query failed', {query = query, error = err})
]]--

function LXRDebug:Log(level, message, data)
    if not config.enabled then return end
    
    local levelValue = LOG_LEVELS[level] or LOG_LEVELS.info
    if levelValue < currentLogLevel then return end
    
    local logEntry = {
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        level = level,
        message = message,
        data = data or {},
        resource = GetInvokingResource() or GetCurrentResourceName(),
        trace = debug.traceback('', 2):sub(1, 500)
    }
    
    table.insert(self.Logs, logEntry)
    
    -- Keep only recent logs
    if #self.Logs > config.maxLogs then
        table.remove(self.Logs, 1)
    end
    
    -- Color-coded console output
    local colors = {
        debug = '^8',
        info = '^2',
        warn = '^3',
        error = '^1',
        critical = '^1^7[!!!]^1'
    }
    
    local color = colors[level] or '^7'
    print(('%s[LXRCore] [%s] %s: %s^7'):format(color, level:upper(), logEntry.resource, message))
    
    -- Store in database for persistent logging
    if config.enabled and (level == 'error' or level == 'critical') then
        MySQL.insert('INSERT INTO debug_logs (timestamp, level, message, data, resource, trace) VALUES (?, ?, ?, ?, ?, ?)', {
            logEntry.timestamp,
            level,
            message,
            json.encode(data or {}),
            logEntry.resource,
            logEntry.trace
        })
    end
    
    -- Trigger event for external monitoring tools
    TriggerEvent('LXRCore:Debug:Log', logEntry)
end

-- ============================================
-- ERROR TRACKING
-- ============================================

--[[
    Server Owner Note:
    Automatically tracks all Lua errors and provides detailed information
    including stack traces, affected resources, and player context
]]--

function LXRDebug:TrackError(errorMsg, stackTrace, source)
    if not config.enabled then return end
    
    local errorEntry = {
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        error = errorMsg,
        stack = stackTrace or debug.traceback(),
        source = source,
        resource = GetInvokingResource() or GetCurrentResourceName(),
        players = #GetPlayers(),
        serverUptime = os.time() - (LXRCore.ServerStartTime or os.time()),
    }
    
    table.insert(self.Errors, errorEntry)
    
    -- Keep only recent errors
    if #self.Errors > config.maxErrors then
        table.remove(self.Errors, 1)
    end
    
    -- Log critical errors
    self:Log('error', 'Lua Error Tracked', {
        error = errorMsg,
        resource = errorEntry.resource
    })
    
    -- Notify admins
    if source then
        for _, admin in ipairs(GetPlayers()) do
            if exports['lxr-core']:HasPermission(admin, 'admin') then
                TriggerClientEvent('chat:addMessage', admin, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {'[Debug]', ('Error in %s: %s'):format(errorEntry.resource, errorMsg:sub(1, 100))}
                })
            end
        end
    end
end

-- Catch all Lua errors
if config.enabled then
    local originalError = error
    error = function(msg, level)
        LXRDebug:TrackError(msg, debug.traceback(), nil)
        return originalError(msg, level or 1)
    end
end

-- ============================================
-- FUNCTION PROFILING
-- ============================================

--[[
    Developer Note:
    Profile any function to measure execution time and call frequency
    
    Example:
    local ProfiledFunction = LXRDebug:Profile('MyFunction', function(arg1, arg2)
        -- Your code here
    end)
]]--

function LXRDebug:Profile(name, func)
    if not config.enabled or not config.profileEnabled then
        return func
    end
    
    return function(...)
        local startTime = GetGameTimer()
        local results = {func(...)}
        local endTime = GetGameTimer()
        local duration = endTime - startTime
        
        -- Track profiling data
        if not self.Profiling[name] then
            self.Profiling[name] = {
                calls = 0,
                totalTime = 0,
                avgTime = 0,
                minTime = 999999,
                maxTime = 0,
                lastCall = 0
            }
        end
        
        local prof = self.Profiling[name]
        prof.calls = prof.calls + 1
        prof.totalTime = prof.totalTime + duration
        prof.avgTime = prof.totalTime / prof.calls
        prof.minTime = math.min(prof.minTime, duration)
        prof.maxTime = math.max(prof.maxTime, duration)
        prof.lastCall = os.time()
        
        -- Warn on slow execution
        if duration > 100 then
            self:Log('warn', 'Slow Function Execution', {
                function = name,
                duration = duration .. 'ms',
                calls = prof.calls
            })
        end
        
        return table.unpack(results)
    end
end

-- ============================================
-- EVENT FLOW TRACKING
-- ============================================

--[[
    Developer Note:
    Track event flow to debug event-based logic
    Shows which events are triggered, when, and by whom
]]--

function LXRDebug:TrackEvent(eventName, source, args)
    if not config.enabled or not config.eventTracking then return end
    
    local eventEntry = {
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        event = eventName,
        source = source,
        args = args,
        resource = GetInvokingResource() or GetCurrentResourceName()
    }
    
    table.insert(self.Events, eventEntry)
    
    -- Keep only recent events (last 500)
    if #self.Events > 500 then
        table.remove(self.Events, 1)
    end
end

-- Hook into event system
if config.enabled and config.eventTracking then
    local originalTriggerEvent = TriggerEvent
    TriggerEvent = function(eventName, ...)
        LXRDebug:TrackEvent(eventName, nil, {...})
        return originalTriggerEvent(eventName, ...)
    end
    
    local originalTriggerClientEvent = TriggerClientEvent
    TriggerClientEvent = function(eventName, source, ...)
        LXRDebug:TrackEvent(eventName, source, {...})
        return originalTriggerClientEvent(eventName, source, ...)
    end
end

-- ============================================
-- DATABASE QUERY MONITORING
-- ============================================

local queryStats = {
    total = 0,
    totalTime = 0,
    slow = {},
    failed = {},
}

function LXRDebug:TrackQuery(query, duration, success, error)
    if not config.enabled or not config.dbQueryLogging then return end
    
    queryStats.total = queryStats.total + 1
    queryStats.totalTime = queryStats.totalTime + duration
    
    if not success then
        table.insert(queryStats.failed, {
            query = query:sub(1, 200),
            error = error,
            timestamp = os.date('%Y-%m-%d %H:%M:%S')
        })
        
        self:Log('error', 'Database Query Failed', {
            query = query:sub(1, 200),
            error = error
        })
    elseif duration > 100 then
        table.insert(queryStats.slow, {
            query = query:sub(1, 200),
            duration = duration,
            timestamp = os.date('%Y-%m-%d %H:%M:%S')
        })
        
        self:Log('warn', 'Slow Database Query', {
            query = query:sub(1, 200),
            duration = duration .. 'ms'
        })
    end
end

-- ============================================
-- PLAYER STATE INSPECTION
-- ============================================

function LXRDebug:GetPlayerState(source)
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return nil end
    
    return {
        citizenid = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        job = Player.PlayerData.job.name,
        grade = Player.PlayerData.job.grade.level,
        gang = Player.PlayerData.gang.name,
        money = Player.PlayerData.money,
        position = GetEntityCoords(GetPlayerPed(source)),
        health = GetEntityHealth(GetPlayerPed(source)),
        identifiers = GetPlayerIdentifiers(source),
        ping = GetPlayerPing(source),
        connected = GetPlayerLastMsg(source),
    }
end

-- ============================================
-- RESOURCE MONITORING
-- ============================================

function LXRDebug:GetResourceStats()
    local resources = {}
    local numResources = GetNumResources()
    
    for i = 0, numResources - 1 do
        local resName = GetResourceByFindIndex(i)
        local state = GetResourceState(resName)
        
        if state == 'started' then
            resources[resName] = {
                state = state,
                memory = GetResourceMemory(resName, false),
                path = GetResourcePath(resName),
                -- Add more stats as needed
            }
        end
    end
    
    return resources
end

-- ============================================
-- API ENDPOINTS
-- ============================================

--[[
    Server Owner Note:
    API endpoints for external monitoring tools
    Access at: http://your-server:30120/debug/*
    
    Endpoints:
    - /debug/status - Server status
    - /debug/logs - Recent logs
    - /debug/errors - Recent errors
    - /debug/performance - Performance metrics
    - /debug/players - Player list and states
    - /debug/resources - Resource stats
]]--

if config.enabled and config.apiEnabled then
    -- Status endpoint
    SetHttpHandler(function(req, res)
        if req.path == '/debug/status' then
            res.writeHead(200, {['Content-Type'] = 'application/json'})
            res.send(json.encode({
                status = 'online',
                uptime = os.time() - (LXRCore.ServerStartTime or os.time()),
                players = #GetPlayers(),
                maxPlayers = GetConvarInt('sv_maxclients', 32),
                version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
                framework = 'LXRCore v2.0.0'
            }))
            return
        end
        
        -- Logs endpoint
        if req.path == '/debug/logs' then
            res.writeHead(200, {['Content-Type'] = 'application/json'})
            res.send(json.encode(LXRDebug.Logs))
            return
        end
        
        -- Errors endpoint
        if req.path == '/debug/errors' then
            res.writeHead(200, {['Content-Type'] = 'application/json'})
            res.send(json.encode(LXRDebug.Errors))
            return
        end
        
        -- Performance endpoint
        if req.path == '/debug/performance' then
            res.writeHead(200, {['Content-Type'] = 'application/json'})
            res.send(json.encode({
                profiling = LXRDebug.Profiling,
                queries = queryStats,
                memory = collectgarbage('count')
            }))
            return
        end
        
        -- Players endpoint
        if req.path == '/debug/players' then
            local players = {}
            for _, playerId in ipairs(GetPlayers()) do
                players[playerId] = LXRDebug:GetPlayerState(playerId)
            end
            res.writeHead(200, {['Content-Type'] = 'application/json'})
            res.send(json.encode(players))
            return
        end
        
        -- Resources endpoint
        if req.path == '/debug/resources' then
            res.writeHead(200, {['Content-Type'] = 'application/json'})
            res.send(json.encode(LXRDebug:GetResourceStats()))
            return
        end
    end)
end

-- ============================================
-- DEBUG COMMANDS
-- ============================================

RegisterCommand('debug:status', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        print('^2[LXRCore] [Debug] System Status:^7')
        print('  Debug Mode: ' .. tostring(config.enabled))
        print('  Log Level: ' .. config.logLevel)
        print('  Total Logs: ' .. #LXRDebug.Logs)
        print('  Total Errors: ' .. #LXRDebug.Errors)
        print('  Tracked Events: ' .. #LXRDebug.Events)
        print('  Profiled Functions: ' .. (function()
            local count = 0
            for _ in pairs(LXRDebug.Profiling) do count = count + 1 end
            return count
        end)())
        print('  DB Queries: ' .. queryStats.total .. ' (Slow: ' .. #queryStats.slow .. ', Failed: ' .. #queryStats.failed .. ')')
    end
end, false)

RegisterCommand('debug:player', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        local targetId = tonumber(args[1])
        if targetId then
            local state = LXRDebug:GetPlayerState(targetId)
            if state then
                print(('^2[LXRCore] [Debug] Player %d State:^7'):format(targetId))
                print('  Citizen ID: ' .. state.citizenid)
                print('  Name: ' .. state.name)
                print('  Job: ' .. state.job .. ' (Grade ' .. state.grade .. ')')
                print('  Gang: ' .. state.gang)
                print('  Money: $' .. state.money.cash .. ' | Bank: $' .. state.money.bank)
                print('  Position: ' .. tostring(state.position))
                print('  Health: ' .. state.health)
                print('  Ping: ' .. state.ping .. 'ms')
            else
                print('^3[LXRCore] [Debug] Player not found^7')
            end
        else
            print('^3[LXRCore] [Debug] Usage: /debug:player <player_id>^7')
        end
    end
end, false)

RegisterCommand('debug:performance', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        print('^2[LXRCore] [Debug] Performance Metrics:^7')
        print('  Memory Usage: ' .. math.floor(collectgarbage('count')) .. 'KB')
        print('  Server Uptime: ' .. math.floor((os.time() - (LXRCore.ServerStartTime or os.time())) / 60) .. ' minutes')
        print('  Database Queries: ' .. queryStats.total)
        print('  Avg Query Time: ' .. (queryStats.total > 0 and math.floor(queryStats.totalTime / queryStats.total) or 0) .. 'ms')
        print('  Slow Queries: ' .. #queryStats.slow)
        print('  Failed Queries: ' .. #queryStats.failed)
        
        print('\n^2Top 5 Slowest Functions:^7')
        local sortedFunctions = {}
        for name, data in pairs(LXRDebug.Profiling) do
            table.insert(sortedFunctions, {name = name, data = data})
        end
        table.sort(sortedFunctions, function(a, b)
            return a.data.avgTime > b.data.avgTime
        end)
        
        for i = 1, math.min(5, #sortedFunctions) do
            local func = sortedFunctions[i]
            print(('  %d. %s - Avg: %.2fms, Calls: %d, Max: %.2fms'):format(
                i,
                func.name,
                func.data.avgTime,
                func.data.calls,
                func.data.maxTime
            ))
        end
    end
end, false)

RegisterCommand('debug:events', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        local count = tonumber(args[1]) or 10
        print(('^2[LXRCore] [Debug] Last %d Events:^7'):format(count))
        
        local startIdx = math.max(1, #LXRDebug.Events - count + 1)
        for i = startIdx, #LXRDebug.Events do
            local evt = LXRDebug.Events[i]
            print(('  [%s] %s (Source: %s, Resource: %s)'):format(
                evt.timestamp,
                evt.event,
                tostring(evt.source or 'server'),
                evt.resource
            ))
        end
    end
end, false)

RegisterCommand('debug:errors', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        local count = tonumber(args[1]) or 5
        print(('^2[LXRCore] [Debug] Last %d Errors:^7'):format(count))
        
        local startIdx = math.max(1, #LXRDebug.Errors - count + 1)
        for i = startIdx, #LXRDebug.Errors do
            local err = LXRDebug.Errors[i]
            print(('  [%s] %s'):format(err.timestamp, err.error:sub(1, 100)))
            print(('    Resource: %s, Players: %d'):format(err.resource, err.players))
        end
    end
end, false)

RegisterCommand('debug:clear', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'god') then
        LXRDebug.Logs = {}
        LXRDebug.Errors = {}
        LXRDebug.Events = {}
        LXRDebug.Profiling = {}
        queryStats = {total = 0, totalTime = 0, slow = {}, failed = {}}
        print('^2[LXRCore] [Debug] All debug data cleared^7')
    end
end, false)

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    if config.enabled then
        print('^2========================================^7')
        print('^2  LXRCore Developer Debug System^7')
        print('^2========================================^7')
        print('^2  Debug Mode: ENABLED^7')
        print('^2  Log Level: ' .. config.logLevel .. '^7')
        print('^2  API Endpoints: ' .. (config.apiEnabled and 'ENABLED' or 'DISABLED') .. '^7')
        print('^2  Profiling: ' .. (config.profileEnabled and 'ENABLED' or 'DISABLED') .. '^7')
        print('^2========================================^7')
        print('^3  Commands:^7')
        print('    /debug:status - System status')
        print('    /debug:player <id> - Player state')
        print('    /debug:performance - Performance metrics')
        print('    /debug:events [count] - Recent events')
        print('    /debug:errors [count] - Recent errors')
        print('    /debug:clear - Clear all debug data')
        print('^2========================================^7')
        
        LXRDebug:Log('info', 'Debug System Initialized', {
            logLevel = config.logLevel,
            apiEnabled = config.apiEnabled,
            profileEnabled = config.profileEnabled
        })
    else
        print('^3[LXRCore] [Debug] Debug mode is disabled (enable in config.lua)^7')
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('DebugLog', function(level, message, data)
    return LXRDebug:Log(level, message, data)
end)

exports('ProfileFunction', function(name, func)
    return LXRDebug:Profile(name, func)
end)

exports('GetDebugLogs', function()
    return LXRDebug.Logs
end)

exports('GetDebugErrors', function()
    return LXRDebug.Errors
end)

exports('GetPerformanceStats', function()
    return {
        profiling = LXRDebug.Profiling,
        queries = queryStats,
        memory = collectgarbage('count')
    }
end)

--[[
    Developer Reference:
    
    Usage Examples:
    
    1. Enhanced Logging:
    exports['lxr-core']:DebugLog('info', 'Player spawned vehicle', {playerId = source, vehicle = veh})
    
    2. Function Profiling:
    local MyFunction = exports['lxr-core']:ProfileFunction('MyFunction', function(arg1)
        -- Your code here
    end)
    
    3. API Access:
    curl http://localhost:30120/debug/status
    curl http://localhost:30120/debug/errors
    
    4. Real-time Monitoring:
    /debug:status - Quick overview
    /debug:performance - Performance metrics
    /debug:events 20 - Last 20 events
]]--
