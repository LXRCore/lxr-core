-- LXRCore Client-Side Performance Utilities
-- Optimizes client-side operations and provides utility functions

LXRClientPerformance = {}

-- Performance: Cached entity pools to reduce native calls
local entityPools = {
    peds = {},
    vehicles = {},
    objects = {},
    lastUpdate = 0,
    updateInterval = 1000  -- Update every 1 second
}

-- Performance: Get cached entity pool
function LXRClientPerformance.GetEntityPool(poolName)
    local currentTime = GetGameTimer()
    
    if currentTime - entityPools.lastUpdate > entityPools.updateInterval then
        -- Update all pools
        entityPools.peds = GetGamePool('CPed')
        entityPools.vehicles = GetGamePool('CVehicle')
        entityPools.objects = GetGamePool('CObject')
        entityPools.lastUpdate = currentTime
    end
    
    if poolName == 'CPed' then
        return entityPools.peds
    elseif poolName == 'CVehicle' then
        return entityPools.vehicles
    elseif poolName == 'CObject' then
        return entityPools.objects
    end
    
    return {}
end
exports('GetEntityPool', LXRClientPerformance.GetEntityPool)

-- Performance: Optimized distance check with caching
local distanceCache = {}
local distanceCacheTTL = 100  -- Cache for 100ms

function LXRClientPerformance.GetDistance(coords1, coords2)
    if not coords1 or not coords2 then return 999999 end
    
    local cacheKey = string.format('%.1f_%.1f_%.1f_%.1f_%.1f_%.1f', 
        coords1.x, coords1.y, coords1.z, coords2.x, coords2.y, coords2.z)
    
    local cached = distanceCache[cacheKey]
    if cached and GetGameTimer() - cached.time < distanceCacheTTL then
        return cached.distance
    end
    
    local distance = #(coords1 - coords2)
    distanceCache[cacheKey] = {
        distance = distance,
        time = GetGameTimer()
    }
    
    return distance
end
exports('GetDistance', LXRClientPerformance.GetDistance)

-- Performance: Optimized closest entity finder
function LXRClientPerformance.GetClosestEntity(entityPool, coords, maxDistance)
    coords = coords or GetEntityCoords(PlayerPedId())
    maxDistance = maxDistance or 10.0
    
    local closestEntity = nil
    local closestDistance = maxDistance
    
    -- Use cached entity pool
    local entities = LXRClientPerformance.GetEntityPool(entityPool)
    
    for _, entity in ipairs(entities) do
        if DoesEntityExist(entity) then
            local entityCoords = GetEntityCoords(entity)
            local distance = #(coords - entityCoords)
            
            if distance < closestDistance then
                closestDistance = distance
                closestEntity = entity
            end
        end
    end
    
    return closestEntity, closestDistance
end
exports('GetClosestEntity', LXRClientPerformance.GetClosestEntity)

-- Performance: Debounced function execution
local debouncedFunctions = {}

function LXRClientPerformance.Debounce(functionName, func, delay)
    delay = delay or 500
    
    return function(...)
        local args = {...}
        
        if debouncedFunctions[functionName] then
            return  -- Still in cooldown
        end
        
        debouncedFunctions[functionName] = true
        func(table.unpack(args))
        
        SetTimeout(delay, function()
            debouncedFunctions[functionName] = nil
        end)
    end
end
exports('Debounce', LXRClientPerformance.Debounce)

-- Performance: Throttled function execution
local throttledFunctions = {}

function LXRClientPerformance.Throttle(functionName, func, interval)
    interval = interval or 1000
    
    if not throttledFunctions[functionName] then
        throttledFunctions[functionName] = {
            lastCall = 0,
            func = func
        }
    end
    
    return function(...)
        local currentTime = GetGameTimer()
        local throttleData = throttledFunctions[functionName]
        
        if currentTime - throttleData.lastCall >= interval then
            throttleData.lastCall = currentTime
            throttleData.func(...)
        end
    end
end
exports('Throttle', LXRClientPerformance.Throttle)

-- Performance: Smart Wait function that adapts based on player state
function LXRClientPerformance.SmartWait(baseWait)
    baseWait = baseWait or 1000
    
    -- Wait longer if player is idle/not in vehicle/not in combat
    local playerPed = PlayerPedId()
    
    if IsPedInAnyVehicle(playerPed, false) then
        return baseWait / 2  -- More responsive in vehicle
    elseif IsPedInMeleeCombat(playerPed) or IsPedShooting(playerPed) then
        return baseWait / 4  -- Very responsive in combat
    elseif GetEntitySpeed(playerPed) < 0.5 then
        return baseWait * 2  -- Less frequent when idle
    end
    
    return baseWait
end
exports('SmartWait', LXRClientPerformance.SmartWait)

-- Performance: Clear old distance cache entries periodically
CreateThread(function()
    while true do
        Wait(30000)  -- Clean every 30 seconds
        
        local currentTime = GetGameTimer()
        local cleaned = 0
        
        for key, data in pairs(distanceCache) do
            if currentTime - data.time > 5000 then  -- Remove entries older than 5 seconds
                distanceCache[key] = nil
                cleaned = cleaned + 1
            end
        end
        
        if cleaned > 0 then
            print(('[LXRCore] [Client Performance] Cleaned %d distance cache entries'):format(cleaned))
        end
    end
end)

-- Performance: FPS monitoring and auto-optimization
local fpsHistory = {}
local fpsHistorySize = 30

CreateThread(function()
    while true do
        Wait(1000)
        
        local fps = GetFrameTime() * 1000  -- Convert to ms
        table.insert(fpsHistory, fps)
        
        if #fpsHistory > fpsHistorySize then
            table.remove(fpsHistory, 1)
        end
        
        -- Calculate average FPS
        local avgFps = 0
        for _, frametime in ipairs(fpsHistory) do
            avgFps = avgFps + frametime
        end
        avgFps = avgFps / #fpsHistory
        
        -- Auto-adjust entity pool update interval based on FPS
        if avgFps > 30 then  -- Good FPS
            entityPools.updateInterval = 500  -- Update more frequently
        elseif avgFps > 20 then  -- Moderate FPS
            entityPools.updateInterval = 1000
        else  -- Low FPS
            entityPools.updateInterval = 2000  -- Update less frequently to save resources
        end
    end
end)

-- Export performance stats
function LXRClientPerformance.GetStats()
    local avgFrametime = 0
    for _, frametime in ipairs(fpsHistory) do
        avgFrametime = avgFrametime + frametime
    end
    avgFrametime = #fpsHistory > 0 and (avgFrametime / #fpsHistory) or 0
    
    return {
        averageFrametime = string.format('%.2fms', avgFrametime),
        entityPoolInterval = entityPools.updateInterval,
        cachedDistances = 0,
        throttledFunctions = 0
    }
end
exports('GetStats', LXRClientPerformance.GetStats)
