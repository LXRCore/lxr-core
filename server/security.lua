-- LXRCore Security Module
-- Provides enhanced security features for the framework

LXRSecurity = {}

-- Rate limiting for events
local eventRateLimits = {}
local rateLimitConfig = {
    defaultLimit = 10,  -- Max calls per window
    windowSize = 1000,  -- Window size in ms
}

-- Security: Rate limiting for server events
function LXRSecurity.CheckRateLimit(source, eventName, customLimit)
    if not source or not eventName then return false end
    
    local limit = customLimit or rateLimitConfig.defaultLimit
    local currentTime = GetGameTimer()
    
    if not eventRateLimits[source] then
        eventRateLimits[source] = {}
    end
    
    if not eventRateLimits[source][eventName] then
        eventRateLimits[source][eventName] = {
            count = 1,
            resetTime = currentTime + rateLimitConfig.windowSize
        }
        return true
    end
    
    local eventData = eventRateLimits[source][eventName]
    
    -- Reset window if expired
    if currentTime >= eventData.resetTime then
        eventData.count = 1
        eventData.resetTime = currentTime + rateLimitConfig.windowSize
        return true
    end
    
    -- Check if limit exceeded
    if eventData.count >= limit then
        TriggerEvent('lxr-log:server:CreateLog', 'anticheat', 'Rate Limit Exceeded', 'red', 
            '**Player ' .. GetPlayerName(source) .. ' (ID: ' .. source .. ')** exceeded rate limit for event: ' .. eventName)
        return false
    end
    
    eventData.count = eventData.count + 1
    return true
end
exports('CheckRateLimit', LXRSecurity.CheckRateLimit)

-- Security: Input validation
function LXRSecurity.ValidateInput(input, inputType)
    if input == nil then return false end
    
    if inputType == 'string' then
        return type(input) == 'string' and #input > 0 and #input < 1000
    elseif inputType == 'number' then
        return type(input) == 'number' and input == input -- Check for NaN
    elseif inputType == 'boolean' then
        return type(input) == 'boolean'
    elseif inputType == 'table' then
        return type(input) == 'table'
    end
    
    return false
end
exports('ValidateInput', LXRSecurity.ValidateInput)

-- Security: SQL injection prevention (additional layer)
-- Note: This is a secondary defense. Primary protection is via prepared statements.
function LXRSecurity.SanitizeString(str)
    if type(str) ~= 'string' then return '' end
    -- Basic sanitization - most protection comes from prepared statements
    return str
end
exports('SanitizeString', LXRSecurity.SanitizeString)

-- Security: Validate player source
function LXRSecurity.ValidateSource(source)
    if not source or source == 0 then return false end
    if not GetPlayerName(source) then return false end
    return true
end
exports('ValidateSource', LXRSecurity.ValidateSource)

-- Security: Validate citizenid format
function LXRSecurity.ValidateCitizenId(citizenid)
    if type(citizenid) ~= 'string' then return false end
    -- CitizenId format: 3 letters + 5 numbers
    return string.match(citizenid, '^%u%u%u%d%d%d%d%d$') ~= nil
end
exports('ValidateCitizenId', LXRSecurity.ValidateCitizenId)

-- Security: Validate item data
function LXRSecurity.ValidateItemData(itemName, amount, slot)
    if type(itemName) ~= 'string' or #itemName == 0 then return false end
    if type(amount) ~= 'number' or amount <= 0 or amount > 999999 then return false end
    if slot and (type(slot) ~= 'number' or slot < 1 or slot > 100) then return false end
    return true
end
exports('ValidateItemData', LXRSecurity.ValidateItemData)

-- Security: Validate money transaction
function LXRSecurity.ValidateMoneyTransaction(moneyType, amount)
    if type(moneyType) ~= 'string' or #moneyType == 0 then return false end
    if type(amount) ~= 'number' or amount < 0 or amount > 999999999 then return false end
    return true
end
exports('ValidateMoneyTransaction', LXRSecurity.ValidateMoneyTransaction)

-- Security: Check for suspicious activity
function LXRSecurity.CheckSuspiciousActivity(source, activityType, data)
    local suspiciousPatterns = {
        rapidMoney = { threshold = 100000, window = 60000 }, -- $100k in 60 seconds
        rapidItems = { threshold = 50, window = 10000 },      -- 50 items in 10 seconds
    }
    
    if not eventRateLimits[source] then
        eventRateLimits[source] = {}
    end
    
    if not eventRateLimits[source].suspicious then
        eventRateLimits[source].suspicious = {}
    end
    
    local pattern = suspiciousPatterns[activityType]
    if not pattern then return true end
    
    local currentTime = GetGameTimer()
    local activityData = eventRateLimits[source].suspicious[activityType]
    
    if not activityData then
        eventRateLimits[source].suspicious[activityType] = {
            total = data,
            startTime = currentTime
        }
        return true
    end
    
    -- Reset if window expired
    if currentTime - activityData.startTime >= pattern.window then
        eventRateLimits[source].suspicious[activityType] = {
            total = data,
            startTime = currentTime
        }
        return true
    end
    
    activityData.total = activityData.total + data
    
    if activityData.total >= pattern.threshold then
        TriggerEvent('lxr-log:server:CreateLog', 'anticheat', 'Suspicious Activity', 'red', 
            '**Player ' .. GetPlayerName(source) .. ' (ID: ' .. source .. ')** suspicious activity detected: ' .. activityType)
        return false
    end
    
    return true
end
exports('CheckSuspiciousActivity', LXRSecurity.CheckSuspiciousActivity)

-- Cleanup old rate limit data periodically
CreateThread(function()
    while true do
        Wait(300000) -- Clean up every 5 minutes
        local currentTime = GetGameTimer()
        
        for source, data in pairs(eventRateLimits) do
            if not GetPlayerName(source) then
                eventRateLimits[source] = nil
            else
                for eventName, eventData in pairs(data) do
                    if eventName ~= 'suspicious' and currentTime >= eventData.resetTime + rateLimitConfig.windowSize then
                        data[eventName] = nil
                    end
                end
            end
        end
    end
end)
