-- LXRCore Performance Monitor
-- Tracks and reports performance metrics

LXRPerformance = {}

-- Performance metrics storage
local metrics = {
    eventCounts = {},
    functionTimes = {},
    dbQueries = {},
    playerUpdates = 0,
    lastReset = GetGameTimer()
}

-- Configuration
local config = {
    reportInterval = 300000,  -- Report every 5 minutes
    logThreshold = 100,       -- Log functions taking more than 100ms
    enableLogging = true
}

-- Performance: Track function execution time
function LXRPerformance.TrackFunction(functionName, func)
    return function(...)
        local startTime = GetGameTimer()
        local results = {func(...)}
        local endTime = GetGameTimer()
        local duration = endTime - startTime
        
        if not metrics.functionTimes[functionName] then
            metrics.functionTimes[functionName] = {
                totalTime = 0,
                callCount = 0,
                maxTime = 0,
                minTime = 999999
            }
        end
        
        local funcMetrics = metrics.functionTimes[functionName]
        funcMetrics.totalTime = funcMetrics.totalTime + duration
        funcMetrics.callCount = funcMetrics.callCount + 1
        funcMetrics.maxTime = math.max(funcMetrics.maxTime, duration)
        funcMetrics.minTime = math.min(funcMetrics.minTime, duration)
        
        -- Log slow functions
        if config.enableLogging and duration > config.logThreshold then
            print(('[LXRCore] [Performance Warning] Function %s took %dms'):format(functionName, duration))
        end
        
        return table.unpack(results)
    end
end
exports('TrackFunction', LXRPerformance.TrackFunction)

-- Performance: Track event triggers
function LXRPerformance.TrackEvent(eventName)
    if not metrics.eventCounts[eventName] then
        metrics.eventCounts[eventName] = 0
    end
    metrics.eventCounts[eventName] = metrics.eventCounts[eventName] + 1
end
exports('TrackEvent', LXRPerformance.TrackEvent)

-- Performance: Track database queries
function LXRPerformance.TrackDBQuery(queryType, duration)
    if not metrics.dbQueries[queryType] then
        metrics.dbQueries[queryType] = {
            count = 0,
            totalTime = 0,
            avgTime = 0
        }
    end
    
    local query = metrics.dbQueries[queryType]
    query.count = query.count + 1
    query.totalTime = query.totalTime + duration
    query.avgTime = query.totalTime / query.count
end
exports('TrackDBQuery', LXRPerformance.TrackDBQuery)

-- Performance: Get current metrics
function LXRPerformance.GetMetrics()
    local currentTime = GetGameTimer()
    local uptime = currentTime - metrics.lastReset
    
    return {
        uptime = uptime,
        events = metrics.eventCounts,
        functions = metrics.functionTimes,
        dbQueries = metrics.dbQueries,
        playerUpdates = metrics.playerUpdates,
        playerCount = #GetPlayers()
    }
end
exports('GetMetrics', LXRPerformance.GetMetrics)

-- Performance: Reset metrics
function LXRPerformance.ResetMetrics()
    metrics = {
        eventCounts = {},
        functionTimes = {},
        dbQueries = {},
        playerUpdates = 0,
        lastReset = GetGameTimer()
    }
end
exports('ResetMetrics', LXRPerformance.ResetMetrics)

-- Performance: Generate report
function LXRPerformance.GenerateReport()
    local currentMetrics = LXRPerformance.GetMetrics()
    local report = {
        '========== LXRCore Performance Report ==========',
        ('Uptime: %.2f minutes'):format(currentMetrics.uptime / 60000),
        ('Active Players: %d'):format(currentMetrics.playerCount),
        ('Player Updates: %d'):format(currentMetrics.playerUpdates),
        '',
        '--- Top 10 Most Called Functions ---'
    }
    
    -- Sort functions by call count
    local sortedFunctions = {}
    for name, data in pairs(currentMetrics.functions) do
        table.insert(sortedFunctions, {
            name = name,
            callCount = data.callCount,
            avgTime = data.totalTime / data.callCount,
            maxTime = data.maxTime
        })
    end
    
    table.sort(sortedFunctions, function(a, b) return a.callCount > b.callCount end)
    
    for i = 1, math.min(10, #sortedFunctions) do
        local func = sortedFunctions[i]
        table.insert(report, ('%d. %s - Calls: %d, Avg: %.2fms, Max: %.2fms'):format(
            i, func.name, func.callCount, func.avgTime, func.maxTime
        ))
    end
    
    table.insert(report, '')
    table.insert(report, '--- Top 10 Most Triggered Events ---')
    
    -- Sort events by count
    local sortedEvents = {}
    for name, count in pairs(currentMetrics.events) do
        table.insert(sortedEvents, {name = name, count = count})
    end
    
    table.sort(sortedEvents, function(a, b) return a.count > b.count end)
    
    for i = 1, math.min(10, #sortedEvents) do
        local event = sortedEvents[i]
        table.insert(report, ('%d. %s - Count: %d'):format(i, event.name, event.count))
    end
    
    table.insert(report, '')
    table.insert(report, '--- Database Query Statistics ---')
    
    for queryType, data in pairs(currentMetrics.dbQueries) do
        table.insert(report, ('%s - Count: %d, Avg: %.2fms'):format(
            queryType, data.count, data.avgTime
        ))
    end
    
    table.insert(report, '===============================================')
    
    return table.concat(report, '\n')
end
exports('GenerateReport', LXRPerformance.GenerateReport)

-- Performance: Auto-reporting thread
CreateThread(function()
    while true do
        Wait(config.reportInterval)
        
        if config.enableLogging then
            local report = LXRPerformance.GenerateReport()
            print(report)
            
            -- Optionally log to file or database
            TriggerEvent('lxr-log:server:CreateLog', 'performance', 'Performance Report', 'blue', report)
        end
    end
end)

-- Admin command to get performance report
RegisterCommand('lxr:performance', function(source, args)
    if source > 0 and not exports['lxr-core']:HasPermission(source, 'admin') then
        return
    end
    
    local report = LXRPerformance.GenerateReport()
    
    if source == 0 then
        print(report)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 255},
            multiline = true,
            args = {'Performance', report}
        })
    end
end, true)

-- Track player updates
RegisterNetEvent('LXRCore:UpdatePlayer', function()
    metrics.playerUpdates = metrics.playerUpdates + 1
end)
