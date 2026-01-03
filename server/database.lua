-- LXRCore Database Optimization Layer
-- Provides optimized database operations with query caching and performance tracking

LXRDatabase = {}

-- Query cache configuration
local queryCache = {
    enabled = true,
    maxAge = 30000,      -- Cache for 30 seconds
    data = {},
    hits = 0,
    misses = 0
}

-- Performance: Generate cache key from query and params
local function generateCacheKey(query, params)
    local key = query
    if params then
        if type(params) == 'table' then
            for _, param in ipairs(params) do
                key = key .. '_' .. tostring(param)
            end
        else
            key = key .. '_' .. tostring(params)
        end
    end
    return key
end

-- Performance: Check if cached data is still valid
local function isCacheValid(cacheEntry)
    if not cacheEntry then return false end
    return GetGameTimer() - cacheEntry.timestamp < queryCache.maxAge
end

-- Performance: Cached query execution
function LXRDatabase.FetchCached(query, params, useCache)
    useCache = useCache ~= false and queryCache.enabled
    
    if useCache then
        local cacheKey = generateCacheKey(query, params)
        local cached = queryCache.data[cacheKey]
        
        if cached and isCacheValid(cached) then
            queryCache.hits = queryCache.hits + 1
            return cached.data
        end
        
        queryCache.misses = queryCache.misses + 1
    end
    
    local startTime = GetGameTimer()
    local result = MySQL.query.await(query, params)
    local duration = GetGameTimer() - startTime
    
    -- Track performance
    exports['lxr-core']:TrackDBQuery('fetch', duration)
    
    if useCache then
        local cacheKey = generateCacheKey(query, params)
        queryCache.data[cacheKey] = {
            data = result,
            timestamp = GetGameTimer()
        }
    end
    
    return result
end
exports('FetchCached', LXRDatabase.FetchCached)

-- Performance: Optimized single row fetch with caching
function LXRDatabase.FetchSingleCached(query, params, useCache)
    useCache = useCache ~= false and queryCache.enabled
    
    if useCache then
        local cacheKey = generateCacheKey(query, params)
        local cached = queryCache.data[cacheKey]
        
        if cached and isCacheValid(cached) then
            queryCache.hits = queryCache.hits + 1
            return cached.data
        end
        
        queryCache.misses = queryCache.misses + 1
    end
    
    local startTime = GetGameTimer()
    local result = MySQL.single.await(query, params)
    local duration = GetGameTimer() - startTime
    
    -- Track performance
    exports['lxr-core']:TrackDBQuery('fetchSingle', duration)
    
    if useCache then
        local cacheKey = generateCacheKey(query, params)
        queryCache.data[cacheKey] = {
            data = result,
            timestamp = GetGameTimer()
        }
    end
    
    return result
end
exports('FetchSingleCached', LXRDatabase.FetchSingleCached)

-- Performance: Batch insert optimization
function LXRDatabase.BatchInsert(table, columns, values)
    if not values or #values == 0 then return false end
    
    local columnStr = table.concat(columns, ', ')
    local valuePlaceholders = '(' .. string.rep('?, ', #columns - 1) .. '?)'
    local allPlaceholders = {}
    local allParams = {}
    
    for i, row in ipairs(values) do
        table.insert(allPlaceholders, valuePlaceholders)
        for _, value in ipairs(row) do
            table.insert(allParams, value)
        end
    end
    
    local query = string.format('INSERT INTO %s (%s) VALUES %s', 
        table, columnStr, table.concat(allPlaceholders, ', '))
    
    local startTime = GetGameTimer()
    local result = MySQL.insert.await(query, allParams)
    local duration = GetGameTimer() - startTime
    
    exports['lxr-core']:TrackDBQuery('batchInsert', duration)
    
    return result
end
exports('BatchInsert', LXRDatabase.BatchInsert)

-- Performance: Clear cache for specific query pattern
function LXRDatabase.ClearCache(pattern)
    if pattern then
        local cleared = 0
        for key, _ in pairs(queryCache.data) do
            if string.find(key, pattern) then
                queryCache.data[key] = nil
                cleared = cleared + 1
            end
        end
        return cleared
    else
        -- Clear all cache
        local count = 0
        for _ in pairs(queryCache.data) do count = count + 1 end
        queryCache.data = {}
        return count
    end
end
exports('ClearCache', LXRDatabase.ClearCache)

-- Performance: Get cache statistics
function LXRDatabase.GetCacheStats()
    local totalRequests = queryCache.hits + queryCache.misses
    local hitRate = totalRequests > 0 and (queryCache.hits / totalRequests * 100) or 0
    
    -- Count cached queries
    local cachedCount = 0
    for _ in pairs(queryCache.data) do
        cachedCount = cachedCount + 1
    end
    
    return {
        enabled = queryCache.enabled,
        hits = queryCache.hits,
        misses = queryCache.misses,
        hitRate = string.format('%.2f%%', hitRate),
        cachedQueries = cachedCount
    }
end
exports('GetCacheStats', LXRDatabase.GetCacheStats)

-- Performance: Periodic cache cleanup
CreateThread(function()
    while true do
        Wait(60000) -- Clean up every minute
        
        local currentTime = GetGameTimer()
        local cleaned = 0
        
        for key, entry in pairs(queryCache.data) do
            if currentTime - entry.timestamp >= queryCache.maxAge then
                queryCache.data[key] = nil
                cleaned = cleaned + 1
            end
        end
        
        if cleaned > 0 then
            print(('[LXRCore] [Database] Cleaned %d expired cache entries'):format(cleaned))
        end
    end
end)

-- Performance: Toggle cache
function LXRDatabase.SetCacheEnabled(enabled)
    queryCache.enabled = enabled
    if not enabled then
        queryCache.data = {}
    end
end
exports('SetCacheEnabled', LXRDatabase.SetCacheEnabled)

-- Admin command to view cache stats
RegisterCommand('lxr:cachestats', function(source, args)
    local Player = source > 0 and GetPlayer(source) or nil
    if source > 0 and Player and not HasPermission(source, 'admin') then
        return
    end
    
    local stats = LXRDatabase.GetCacheStats()
    local message = string.format(
        'Cache Stats:\nEnabled: %s\nHits: %d\nMisses: %d\nHit Rate: %s\nCached Queries: %d',
        tostring(stats.enabled), stats.hits, stats.misses, stats.hitRate, stats.cachedQueries
    )
    
    if source == 0 then
        print(message)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 255},
            multiline = true,
            args = {'Database', message}
        })
    end
end, true)
