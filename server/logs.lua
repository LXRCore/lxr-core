--[[
    LXRCore - Supreme Webhook & Logging System
    
    Comprehensive logging and Discord webhook integration
    Real-time event tracking, audit trails, and notifications
    
    Features:
    1. Discord webhook integration (50+ event types)
    2. Database logging with search/filter
    3. Real-time notifications
    4. Player action tracking
    5. Admin action logging
    6. Economy transaction logs
    7. Inventory change tracking
    8. Security event alerts
    9. Server performance logs
    10. Custom event logging
    11. Log rotation and archival
    12. Advanced filtering and search
    13. Export logs to JSON/CSV
    14. Webhook queue system
    15. Retry mechanism for failed webhooks
    
    For Server Owners:
    - Configure webhooks in config.lua
    - Set log retention periods
    - Choose which events to log
    - Discord notifications for critical events
    
    For Developers:
    - Use LXRLog:Log() for custom events
    - Create custom webhook formats
    - Query logs programmatically
    - Export data for analysis
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
    
    Version: 2.0.0
]]--

LXRLog = {}
LXRLog.WebhookQueue = {}
LXRLog.FailedWebhooks = {}
LXRLog.Statistics = {
    totalLogs = 0,
    totalWebhooks = 0,
    failedWebhooks = 0,
    categories = {}
}

-- ============================================
-- CONFIGURATION
-- ============================================

local config = {
    enabled = LXRConfig.Logging and LXRConfig.Logging.Enabled or true,
    webhooksEnabled = LXRConfig.Logging and LXRConfig.Logging.WebhooksEnabled or true,
    databaseLogging = LXRConfig.Logging and LXRConfig.Logging.DatabaseLogging or true,
    consoleLogging = LXRConfig.Logging and LXRConfig.Logging.ConsoleLogging or true,
    
    -- Webhook settings
    webhookRetries = 3,
    webhookTimeout = 5000,
    webhookQueueMax = 100,
    webhookRateLimit = 5, -- Per second
    
    -- Log retention
    retentionDays = LXRConfig.Logging and LXRConfig.Logging.RetentionDays or 30,
    archiveOldLogs = true,
    
    -- Performance
    batchSize = 50, -- Batch database inserts
    flushInterval = 5000, -- Flush logs every 5 seconds
}

-- Webhook URLs from config
local webhooks = LXRConfig.Webhooks or {}

-- Log categories with colors and icons
local categories = {
    -- Player Events
    player_connect = {color = 3066993, icon = '🔵', name = 'Player Connect'},
    player_disconnect = {color = 15158332, icon = '🔴', name = 'Player Disconnect'},
    player_spawn = {color = 3447003, icon = '⚪', name = 'Player Spawn'},
    player_death = {color = 10038562, icon = '💀', name = 'Player Death'},
    player_revive = {color = 3066993, icon = '💚', name = 'Player Revive'},
    
    -- Economy Events
    money_add = {color = 3066993, icon = '💰', name = 'Money Added'},
    money_remove = {color = 15158332, icon = '💸', name = 'Money Removed'},
    money_transfer = {color = 3447003, icon = '💵', name = 'Money Transfer'},
    bank_deposit = {color = 3066993, icon = '🏦', name = 'Bank Deposit'},
    bank_withdraw = {color = 15105570, icon = '🏧', name = 'Bank Withdrawal'},
    
    -- Inventory Events
    item_add = {color = 3066993, icon = '📦', name = 'Item Added'},
    item_remove = {color = 15158332, icon = '🗑️', name = 'Item Removed'},
    item_use = {color = 3447003, icon = '🎯', name = 'Item Used'},
    item_trade = {color = 10181046, icon = '🤝', name = 'Item Trade'},
    item_drop = {color = 15105570, icon = '⬇️', name = 'Item Dropped'},
    item_pickup = {color = 3066993, icon = '⬆️', name = 'Item Pickup'},
    
    -- Vehicle Events
    vehicle_spawn = {color = 3066993, icon = '🚗', name = 'Vehicle Spawn'},
    vehicle_delete = {color = 15158332, icon = '🗑️', name = 'Vehicle Delete'},
    vehicle_purchase = {color = 3447003, icon = '🛒', name = 'Vehicle Purchase'},
    vehicle_sell = {color = 15105570, icon = '💵', name = 'Vehicle Sell'},
    
    -- Job Events
    job_change = {color = 3447003, icon = '💼', name = 'Job Change'},
    job_promotion = {color = 3066993, icon = '⬆️', name = 'Job Promotion'},
    job_demotion = {color = 15158332, icon = '⬇️', name = 'Job Demotion'},
    duty_toggle = {color = 10181046, icon = '⏰', name = 'Duty Toggle'},
    paycheck = {color = 3066993, icon = '💰', name = 'Paycheck'},
    
    -- Gang Events
    gang_join = {color = 15158332, icon = '🔫', name = 'Gang Join'},
    gang_leave = {color = 3447003, icon = '🚪', name = 'Gang Leave'},
    gang_promotion = {color = 15158332, icon = '⬆️', name = 'Gang Promotion'},
    
    -- Admin Events
    admin_command = {color = 15844367, icon = '⚙️', name = 'Admin Command'},
    admin_kick = {color = 15158332, icon = '👢', name = 'Admin Kick'},
    admin_ban = {color = 10038562, icon = '🔨', name = 'Admin Ban'},
    admin_unban = {color = 3066993, icon = '🔓', name = 'Admin Unban'},
    admin_teleport = {color = 10181046, icon = '🌀', name = 'Admin Teleport'},
    admin_revive = {color = 3066993, icon = '💚', name = 'Admin Revive'},
    admin_givemoney = {color = 3066993, icon = '💰', name = 'Admin Give Money'},
    admin_giveitem = {color = 3066993, icon = '📦', name = 'Admin Give Item'},
    
    -- Security Events
    anticheat = {color = 15158332, icon = '🛡️', name = 'Anti-Cheat Detection'},
    antidupe = {color = 15158332, icon = '⚠️', name = 'Anti-Dupe Detection'},
    suspicious = {color = 15105570, icon = '👁️', name = 'Suspicious Activity'},
    exploit = {color = 10038562, icon = '⚠️', name = 'Exploit Attempt'},
    security_violation = {color = 10038562, icon = '🚨', name = 'Security Violation'},
    
    -- System Events
    server_start = {color = 3066993, icon = '🟢', name = 'Server Start'},
    server_stop = {color = 15158332, icon = '🔴', name = 'Server Stop'},
    resource_start = {color = 3066993, icon = '▶️', name = 'Resource Start'},
    resource_stop = {color = 15158332, icon = '⏹️', name = 'Resource Stop'},
    database_error = {color = 15158332, icon = '❌', name = 'Database Error'},
    performance_warning = {color = 15105570, icon = '⚠️', name = 'Performance Warning'},
    
    -- Custom/Generic
    custom = {color = 10181046, icon = '📝', name = 'Custom Event'},
    info = {color = 3447003, icon = 'ℹ️', name = 'Information'},
    success = {color = 3066993, icon = '✅', name = 'Success'},
    warning = {color = 15105570, icon = '⚠️', name = 'Warning'},
    error = {color = 15158332, icon = '❌', name = 'Error'},
    critical = {color = 10038562, icon = '🚨', name = 'Critical'},
}

-- ============================================
-- MAIN LOGGING FUNCTION
-- ============================================

--[[
    Server Owner Note:
    Central logging function that handles all logging operations
    
    Example:
    LXRLog:Log('player_connect', 'Player Connected', {
        player = GetPlayerName(source),
        steamid = steamId,
        license = license
    })
]]--

function LXRLog:Log(category, title, data, source)
    if not config.enabled then return end
    
    local logEntry = {
        id = LXRLog.Statistics.totalLogs + 1,
        timestamp = os.time(),
        datetime = os.date('%Y-%m-%d %H:%M:%S'),
        category = category,
        title = title,
        data = data or {},
        source = source or 'server',
        resource = GetInvokingResource() or GetCurrentResourceName(),
    }
    
    -- Update statistics
    LXRLog.Statistics.totalLogs = LXRLog.Statistics.totalLogs + 1
    LXRLog.Statistics.categories[category] = (LXRLog.Statistics.categories[category] or 0) + 1
    
    -- Console logging
    if config.consoleLogging then
        self:ConsoleLog(logEntry)
    end
    
    -- Database logging
    if config.databaseLogging then
        self:DatabaseLog(logEntry)
    end
    
    -- Webhook logging
    if config.webhooksEnabled then
        self:WebhookLog(logEntry)
    end
    
    -- Trigger event for custom handlers
    TriggerEvent('LXRCore:Server:Log', logEntry)
    
    return logEntry.id
end

-- ============================================
-- CONSOLE LOGGING
-- ============================================

function LXRLog:ConsoleLog(logEntry)
    local cat = categories[logEntry.category] or categories.custom
    local color = '^2' -- Default green
    
    if cat.color then
        if cat.color > 10000000 then
            color = '^1' -- Red
        elseif cat.color > 5000000 then
            color = '^3' -- Yellow
        end
    end
    
    print(('%s[LXRCore] [Log] %s %s: %s^7'):format(
        color,
        cat.icon,
        cat.name,
        logEntry.title
    ))
end

-- ============================================
-- DATABASE LOGGING
-- ============================================

local logBuffer = {}

function LXRLog:DatabaseLog(logEntry)
    table.insert(logBuffer, {
        timestamp = logEntry.timestamp,
        datetime = logEntry.datetime,
        category = logEntry.category,
        title = logEntry.title,
        data = json.encode(logEntry.data),
        source = tostring(logEntry.source),
        resource = logEntry.resource,
    })
    
    -- Flush if buffer is full
    if #logBuffer >= config.batchSize then
        self:FlushLogBuffer()
    end
end

function LXRLog:FlushLogBuffer()
    if #logBuffer == 0 then return end
    
    local values = {}
    for _, log in ipairs(logBuffer) do
        table.insert(values, {
            log.timestamp,
            log.datetime,
            log.category,
            log.title,
            log.data,
            log.source,
            log.resource
        })
    end
    
    MySQL.insert('INSERT INTO logs (timestamp, datetime, category, title, data, source, resource) VALUES (?, ?, ?, ?, ?, ?, ?)', values)
    
    logBuffer = {}
end

-- ============================================
-- WEBHOOK LOGGING
-- ============================================

function LXRLog:WebhookLog(logEntry)
    local cat = categories[logEntry.category] or categories.custom
    local webhookUrl = webhooks[logEntry.category] or webhooks.default
    
    if not webhookUrl or webhookUrl == '' then return end
    
    -- Create Discord embed
    local embed = {
        {
            title = cat.icon .. ' ' .. logEntry.title,
            description = self:FormatDataForWebhook(logEntry.data),
            color = cat.color,
            timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
            footer = {
                text = 'LXRCore v2.0.0 • ' .. logEntry.resource,
                icon_url = 'https://www.lxrcore.com/logo.png'
            },
            fields = self:CreateWebhookFields(logEntry)
        }
    }
    
    -- Add to webhook queue
    table.insert(LXRLog.WebhookQueue, {
        url = webhookUrl,
        payload = {
            username = 'LXRCore Logs',
            avatar_url = 'https://www.lxrcore.com/logo.png',
            embeds = embed
        },
        retries = 0,
        timestamp = os.time()
    })
    
    -- Process queue if not too large
    if #LXRLog.WebhookQueue < config.webhookQueueMax then
        self:ProcessWebhookQueue()
    end
end

function LXRLog:FormatDataForWebhook(data)
    local lines = {}
    
    for key, value in pairs(data) do
        if type(value) == 'table' then
            value = json.encode(value)
        end
        table.insert(lines, ('**%s:** %s'):format(key, tostring(value)))
    end
    
    return table.concat(lines, '\n')
end

function LXRLog:CreateWebhookFields(logEntry)
    local fields = {}
    
    -- Add source field if player
    if tonumber(logEntry.source) then
        local playerName = GetPlayerName(logEntry.source)
        if playerName then
            table.insert(fields, {
                name = '👤 Player',
                value = playerName .. ' (' .. logEntry.source .. ')',
                inline = true
            })
        end
    end
    
    -- Add timestamp
    table.insert(fields, {
        name = '🕐 Time',
        value = logEntry.datetime,
        inline = true
    })
    
    -- Add category
    table.insert(fields, {
        name = '📁 Category',
        value = logEntry.category,
        inline = true
    })
    
    return fields
end

function LXRLog:ProcessWebhookQueue()
    if #LXRLog.WebhookQueue == 0 then return end
    
    local webhook = table.remove(LXRLog.WebhookQueue, 1)
    
    PerformHttpRequest(webhook.url, function(statusCode, responseText, headers)
        if statusCode == 200 or statusCode == 204 then
            LXRLog.Statistics.totalWebhooks = LXRLog.Statistics.totalWebhooks + 1
        else
            -- Retry failed webhooks
            webhook.retries = webhook.retries + 1
            if webhook.retries < config.webhookRetries then
                table.insert(LXRLog.WebhookQueue, webhook)
            else
                table.insert(LXRLog.FailedWebhooks, webhook)
                LXRLog.Statistics.failedWebhooks = LXRLog.Statistics.failedWebhooks + 1
                print('^1[LXRCore] [Log] Webhook failed after ' .. config.webhookRetries .. ' retries^7')
            end
        end
    end, 'POST', json.encode(webhook.payload), {['Content-Type'] = 'application/json'})
end

-- ============================================
-- LOG QUERIES
-- ============================================

--[[
    Developer Note:
    Query logs with filters for analysis and debugging
]]--

function LXRLog:Query(filters)
    filters = filters or {}
    
    local query = 'SELECT * FROM logs WHERE 1=1'
    local params = {}
    
    if filters.category then
        query = query .. ' AND category = ?'
        table.insert(params, filters.category)
    end
    
    if filters.source then
        query = query .. ' AND source = ?'
        table.insert(params, filters.source)
    end
    
    if filters.resource then
        query = query .. ' AND resource = ?'
        table.insert(params, filters.resource)
    end
    
    if filters.startDate then
        query = query .. ' AND datetime >= ?'
        table.insert(params, filters.startDate)
    end
    
    if filters.endDate then
        query = query .. ' AND datetime <= ?'
        table.insert(params, filters.endDate)
    end
    
    if filters.search then
        query = query .. ' AND (title LIKE ? OR data LIKE ?)'
        local searchTerm = '%' .. filters.search .. '%'
        table.insert(params, searchTerm)
        table.insert(params, searchTerm)
    end
    
    query = query .. ' ORDER BY timestamp DESC'
    
    if filters.limit then
        query = query .. ' LIMIT ?'
        table.insert(params, filters.limit)
    else
        query = query .. ' LIMIT 100'
    end
    
    return MySQL.query.await(query, params)
end

-- ============================================
-- LOG EXPORT
-- ============================================

function LXRLog:Export(filters, format)
    format = format or 'json'
    local logs = self:Query(filters)
    
    if format == 'json' then
        return json.encode(logs, {indent = true})
    elseif format == 'csv' then
        local csv = 'ID,Timestamp,Category,Title,Source,Resource\n'
        for _, log in ipairs(logs) do
            csv = csv .. ('%d,"%s","%s","%s","%s","%s"\n'):format(
                log.id,
                log.datetime,
                log.category,
                log.title,
                log.source,
                log.resource
            )
        end
        return csv
    end
end

-- ============================================
-- LOG CLEANUP
-- ============================================

function LXRLog:CleanupOldLogs()
    if not config.retentionDays then return end
    
    local cutoffDate = os.date('%Y-%m-%d %H:%M:%S', os.time() - (config.retentionDays * 24 * 60 * 60))
    
    if config.archiveOldLogs then
        -- Archive before deletion
        local oldLogs = MySQL.query.await('SELECT * FROM logs WHERE datetime < ?', {cutoffDate})
        if #oldLogs > 0 then
            local archived = json.encode(oldLogs)
            -- Save to file
            SaveResourceFile(GetCurrentResourceName(), 'logs/archive_' .. os.date('%Y%m%d') .. '.json', archived, -1)
        end
    end
    
    -- Delete old logs
    MySQL.query('DELETE FROM logs WHERE datetime < ?', {cutoffDate})
    
    print(('[LXRCore] [Log] Cleaned up logs older than %d days'):format(config.retentionDays))
end

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function LXRLog:GetPlayerIdentifiers(source)
    local identifiers = {}
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        local idType = id:match('(%w+):')
        if idType then
            identifiers[idType] = id
        end
    end
    return identifiers
end

function LXRLog:GetPlayerInfo(source)
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return nil end
    
    return {
        citizenid = Player.PlayerData.citizenid,
        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        job = Player.PlayerData.job.name,
        gang = Player.PlayerData.gang.name,
        identifiers = self:GetPlayerIdentifiers(source)
    }
end

-- ============================================
-- THREADS
-- ============================================

-- Flush log buffer periodically
CreateThread(function()
    while true do
        Wait(config.flushInterval)
        LXRLog:FlushLogBuffer()
    end
end)

-- Process webhook queue
CreateThread(function()
    while true do
        Wait(1000 / config.webhookRateLimit) -- Rate limiting
        if #LXRLog.WebhookQueue > 0 then
            LXRLog:ProcessWebhookQueue()
        end
    end
end)

-- Daily log cleanup
CreateThread(function()
    while true do
        Wait(24 * 60 * 60 * 1000) -- 24 hours
        LXRLog:CleanupOldLogs()
    end
end)

-- ============================================
-- COMMANDS
-- ============================================

RegisterCommand('logs:stats', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        print('^2[LXRCore] [Log] Statistics:^7')
        print('  Total Logs: ' .. LXRLog.Statistics.totalLogs)
        print('  Total Webhooks: ' .. LXRLog.Statistics.totalWebhooks)
        print('  Failed Webhooks: ' .. LXRLog.Statistics.failedWebhooks)
        print('  Queue Size: ' .. #LXRLog.WebhookQueue)
        print('  Buffer Size: ' .. #logBuffer)
        
        print('\n^2Category Breakdown:^7')
        for cat, count in pairs(LXRLog.Statistics.categories) do
            print(('  %s: %d'):format(cat, count))
        end
    end
end, false)

RegisterCommand('logs:query', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        local category = args[1]
        local limit = tonumber(args[2]) or 10
        
        local logs = LXRLog:Query({category = category, limit = limit})
        print(('^2[LXRCore] [Log] Last %d logs for category "%s":^7'):format(limit, category or 'all'))
        
        for i, log in ipairs(logs) do
            print(('  [%s] %s - %s'):format(log.datetime, log.category, log.title))
        end
    end
end, false)

RegisterCommand('logs:export', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'god') then
        local format = args[1] or 'json'
        local category = args[2]
        
        local exported = LXRLog:Export({category = category, limit = 1000}, format)
        local filename = 'logs/export_' .. os.date('%Y%m%d_%H%M%S') .. '.' .. format
        
        SaveResourceFile(GetCurrentResourceName(), filename, exported, -1)
        print(('^2[LXRCore] [Log] Exported logs to %s^7'):format(filename))
    end
end, false)

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    Wait(1000)
    
    print('^2========================================^7')
    print('^2  LXRCore Webhook & Logging System^7')
    print('^2========================================^7')
    print('^2  Enabled: ' .. tostring(config.enabled) .. '^7')
    print('^2  Webhooks: ' .. tostring(config.webhooksEnabled) .. '^7')
    print('^2  Database: ' .. tostring(config.databaseLogging) .. '^7')
    print('^2  Categories: ' .. (function()
        local count = 0
        for _ in pairs(categories) do count = count + 1 end
        return count
    end)() .. '^7')
    print('^2========================================^7')
    
    -- Log system start
    LXRLog:Log('server_start', 'Server Started', {
        framework = 'LXRCore v2.0.0',
        players = #GetPlayers(),
        maxPlayers = GetConvarInt('sv_maxclients', 32)
    })
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('Log', function(category, title, data, source)
    return LXRLog:Log(category, title, data, source)
end)

exports('QueryLogs', function(filters)
    return LXRLog:Query(filters)
end)

exports('ExportLogs', function(filters, format)
    return LXRLog:Export(filters, format)
end)

exports('GetLogStats', function()
    return LXRLog.Statistics
end)

--[[
    Server Owner Reference:
    
    Configure webhooks in config.lua:
    LXRConfig.Webhooks = {
        default = 'https://discord.com/api/webhooks/...',
        player_connect = 'https://discord.com/api/webhooks/...',
        admin_command = 'https://discord.com/api/webhooks/...',
        anticheat = 'https://discord.com/api/webhooks/...',
    }
    
    Usage Examples:
    exports['lxr-core']:Log('player_connect', 'Player Joined', {
        player = name,
        steamid = steamId
    }, source)
]]--
