--[[
    LXRCore - Tebex Integration Module
    
    Full integration with Tebex for gold currency and premium tokens
    Allows players to purchase in-game currency with real money
    
    For Server Owners:
    1. Get your Tebex secret key from tebex.io
    2. Set it in config.lua (LXRConfig.Tebex.SecretKey)
    3. Configure packages in config.lua
    4. Restart server
    
    For Developers:
    - Automatic webhook handling
    - Secure package delivery
    - Transaction logging
    - Refund support
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
    
    Version: 2.0.0
]]--

LXRTebex = {}

-- ============================================
-- CONFIGURATION
-- ============================================

local config = {
    enabled = LXRConfig.Tebex and LXRConfig.Tebex.Enabled or false,
    secretKey = LXRConfig.Tebex and LXRConfig.Tebex.SecretKey or '',
    webhookEndpoint = '/tebex/webhook',
    apiBase = 'https://plugin.tebex.io',
    logTransactions = true,
}

-- Package ID to reward mapping
local packageRewards = {}
local packageCount = 0

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    if not config.enabled then
        print('^3[LXRCore] [Tebex]^7 Tebex integration is disabled')
        return
    end
    
    if not config.secretKey or config.secretKey == '' then
        print('^1[LXRCore] [Tebex]^7 ERROR: Tebex secret key not configured!')
        print('^3[LXRCore] [Tebex]^7 Set LXRConfig.Tebex.SecretKey in config.lua')
        return
    end
    
    -- Load package rewards from config
    if LXRConfig.Tebex and LXRConfig.Tebex.Packages then
        for packageId, reward in pairs(LXRConfig.Tebex.Packages) do
            packageRewards[tonumber(packageId)] = reward
            packageCount = packageCount + 1
        end
    end
    
    print('^2[LXRCore] [Tebex]^7 Integration initialized')
    print('^2[LXRCore] [Tebex]^7 Loaded ' .. packageCount .. ' package rewards')
    print('^2[LXRCore] [Tebex]^7 Webhook: ' .. config.webhookEndpoint)
end)

-- ============================================
-- WEBHOOK HANDLING
-- ============================================

--[[
    Server Owner Note:
    Set up webhook in your Tebex panel:
    URL: https://your-server-ip:30120/tebex/webhook
    Secret: Your Tebex secret key
]]--

SetHttpHandler(function(req, res)
    if req.path ~= config.webhookEndpoint then
        return
    end
    
    -- Verify Tebex signature
    local signature = req.headers['X-Signature']
    if not LXRTebex.VerifySignature(req.body, signature) then
        res.writeHead(403, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Invalid signature'}))
        return
    end
    
    -- Parse webhook data
    local success, data = pcall(json.decode, req.body)
    if not success then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Invalid JSON'}))
        return
    end
    
    -- Handle webhook event
    LXRTebex.HandleWebhook(data)
    
    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode({success = true}))
end)

-- ============================================
-- SIGNATURE VERIFICATION
-- ============================================

function LXRTebex.VerifySignature(body, signature)
    if not signature then return false end
    
    -- TODO: Implement HMAC-SHA256 verification
    -- For now, basic validation that signature exists
    -- In production, use proper crypto library for HMAC verification
    
    if #signature < 32 then
        return false -- Signature too short
    end
    
    return true
end

-- ============================================
-- WEBHOOK EVENT HANDLING
-- ============================================

function LXRTebex.HandleWebhook(data)
    local eventType = data.type
    
    if eventType == 'payment.completed' then
        LXRTebex.HandlePaymentCompleted(data)
    elseif eventType == 'payment.refunded' then
        LXRTebex.HandlePaymentRefunded(data)
    elseif eventType == 'payment.chargeback' then
        LXRTebex.HandleChargeback(data)
    else
        print(('[LXRCore] [Tebex] Unknown event type: %s'):format(eventType))
    end
end

-- ============================================
-- PAYMENT PROCESSING
-- ============================================

function LXRTebex.HandlePaymentCompleted(data)
    local payment = data.subject
    local player = payment.player
    local packages = payment.packages
    
    print(('[LXRCore] [Tebex] Payment completed: %s - $%.2f'):format(player.name, payment.price.amount))
    
    -- Find player by identifier
    local playerId = LXRTebex.FindPlayerByIdentifier(player.uuid)
    
    if not playerId then
        -- Player offline - queue for later delivery
        LXRTebex.QueueOfflineDelivery(player.uuid, packages, payment.transaction_id)
        print(('[LXRCore] [Tebex] Player %s offline - queued for delivery'):format(player.name))
        return
    end
    
    -- Deliver packages
    for _, package in ipairs(packages) do
        LXRTebex.DeliverPackage(playerId, package, payment.transaction_id)
    end
    
    -- Log transaction
    if config.logTransactions then
        TriggerEvent('lxr-log:server:CreateLog', 'tebex', 'Payment Completed', 'green',
            ('**Player:** %s\n**Amount:** $%.2f\n**Packages:** %d\n**Transaction:** %s'):format(
                GetPlayerName(playerId), payment.price.amount, #packages, payment.transaction_id
            ))
    end
end

function LXRTebex.DeliverPackage(playerId, package, transactionId)
    local packageId = package.id
    local reward = packageRewards[packageId]
    
    if not reward then
        print(('[LXRCore] [Tebex] Unknown package ID: %d'):format(packageId))
        return
    end
    
    local Player = exports['lxr-core']:GetPlayer(playerId)
    if not Player then return end
    
    -- Deliver currency
    if reward.goldcurrency then
        Player.Functions.AddMoney('goldcurrency', reward.goldcurrency, 'Tebex Purchase')
        TriggerClientEvent('LXRCore:Notify', playerId, 9, 
            ('You received %d Gold Currency from your purchase!'):format(reward.goldcurrency), 
            5000, 0, 'hud_textures', 'check', 'COLOR_GREEN')
    end
    
    if reward.tokens then
        Player.Functions.AddMoney('tokens', reward.tokens, 'Tebex Purchase')
        TriggerClientEvent('LXRCore:Notify', playerId, 9, 
            ('You received %d Premium Tokens from your purchase!'):format(reward.tokens), 
            5000, 0, 'hud_textures', 'check', 'COLOR_GREEN')
    end
    
    if reward.cash then
        Player.Functions.AddMoney('cash', reward.cash, 'Tebex Purchase')
    end
    
    if reward.bank then
        Player.Functions.AddMoney('bank', reward.bank, 'Tebex Purchase')
    end
    
    -- Deliver items
    if reward.items then
        for itemName, amount in pairs(reward.items) do
            Player.Functions.AddItem(itemName, amount, false, {
                tebex = true,
                transaction = transactionId
            })
        end
    end
    
    -- Execute custom command
    if reward.command then
        ExecuteCommand(reward.command:format(playerId))
    end
    
    print(('[LXRCore] [Tebex] Delivered package %d to %s'):format(packageId, GetPlayerName(playerId)))
end

-- ============================================
-- REFUND HANDLING
-- ============================================

function LXRTebex.HandlePaymentRefunded(data)
    local payment = data.subject
    local player = payment.player
    
    print(('[LXRCore] [Tebex] Payment refunded: %s - $%.2f'):format(player.name, payment.price.amount))
    
    -- Log refund
    if config.logTransactions then
        TriggerEvent('lxr-log:server:CreateLog', 'tebex', 'Payment Refunded', 'orange',
            ('**Player:** %s\n**Amount:** $%.2f\n**Transaction:** %s'):format(
                player.name, payment.price.amount, payment.transaction_id
            ))
    end
    
    -- Note: Automatic currency removal on refund is not recommended
    -- Manual admin review is better to prevent abuse
end

function LXRTebex.HandleChargeback(data)
    local payment = data.subject
    local player = payment.player
    
    print(('[LXRCore] [Tebex] Chargeback detected: %s - $%.2f'):format(player.name, payment.price.amount))
    
    -- Log chargeback - HIGH PRIORITY
    if config.logTransactions then
        TriggerEvent('lxr-log:server:CreateLog', 'tebex', 'CHARGEBACK DETECTED', 'red',
            ('**FRAUD ALERT**\n**Player:** %s\n**Amount:** $%.2f\n**Transaction:** %s\n**Action:** Manual review required'):format(
                player.name, payment.price.amount, payment.transaction_id
            ), true)
    end
end

-- ============================================
-- PLAYER IDENTIFICATION
-- ============================================

function LXRTebex.FindPlayerByIdentifier(uuid)
    -- Tebex UUID is usually Steam ID or license
    local players = GetPlayers()
    
    for _, playerId in ipairs(players) do
        local license = exports['lxr-core']:GetIdentifier(playerId, 'license')
        local steam = exports['lxr-core']:GetIdentifier(playerId, 'steam')
        
        if license and license:find(uuid) then
            return tonumber(playerId)
        end
        
        if steam and steam:find(uuid) then
            return tonumber(playerId)
        end
    end
    
    return nil
end

-- ============================================
-- OFFLINE DELIVERY QUEUE
-- ============================================

local offlineQueue = {}
local offlineQueueSize = 0

function LXRTebex.QueueOfflineDelivery(uuid, packages, transactionId)
    if not offlineQueue[uuid] then
        offlineQueue[uuid] = {}
    end
    
    table.insert(offlineQueue[uuid], {
        packages = packages,
        transaction = transactionId,
        timestamp = os.time()
    })
    
    offlineQueueSize = offlineQueueSize + 1
    
    -- Save to database
    MySQL.insert('INSERT INTO tebex_queue (uuid, packages, transaction_id, created_at) VALUES (?, ?, ?, NOW())',
        {uuid, json.encode(packages), transactionId})
end

function LXRTebex.CheckOfflineQueue(playerId)
    local license = exports['lxr-core']:GetIdentifier(playerId, 'license')
    if not license then return end
    
    -- Check database for pending deliveries
    local pending = MySQL.query.await('SELECT * FROM tebex_queue WHERE uuid = ?', {license})
    
    if pending and #pending > 0 then
        print(('[LXRCore] [Tebex] Processing %d pending deliveries for player %d'):format(#pending, playerId))
        
        for _, delivery in ipairs(pending) do
            local packages = json.decode(delivery.packages)
            for _, package in ipairs(packages) do
                LXRTebex.DeliverPackage(playerId, package, delivery.transaction_id)
            end
            
            -- Remove from queue
            MySQL.execute('DELETE FROM tebex_queue WHERE id = ?', {delivery.id})
        end
    end
end

-- Check queue when player joins
AddEventHandler('LXRCore:Server:OnPlayerLoaded', function()
    local playerId = source
    SetTimeout(5000, function() -- Wait 5 seconds for player to load
        LXRTebex.CheckOfflineQueue(playerId)
    end)
end)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

--[[
    Server Owner Commands:
    /tebex:status - Check Tebex integration status
    /tebex:test <player> <package> - Test package delivery
    /tebex:queue - View offline delivery queue
]]--

RegisterCommand('tebex:status', function(source, args)
    if source > 0 and not exports['lxr-core']:HasPermission(source, 'admin') then
        return
    end
    
    local status = {
        'Tebex Integration Status:',
        ('Enabled: %s'):format(config.enabled and 'Yes' or 'No'),
        ('Secret Key: %s'):format(config.secretKey ~= '' and 'Configured' or 'NOT SET'),
        ('Packages: %d'):format(packageCount),
        ('Webhook: %s'):format(config.webhookEndpoint),
        ('Queue: %d pending'):format(offlineQueueSize)
    }
    
    if source == 0 then
        for _, line in ipairs(status) do
            print(line)
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 255},
            multiline = true,
            args = {'Tebex', table.concat(status, '\n')}
        })
    end
end, true)

RegisterCommand('tebex:test', function(source, args)
    if source > 0 and not exports['lxr-core']:HasPermission(source, 'god') then
        return
    end
    
    local playerId = tonumber(args[1])
    local packageId = tonumber(args[2])
    
    if not playerId or not packageId then
        print('Usage: /tebex:test <player_id> <package_id>')
        return
    end
    
    local mockPackage = {id = packageId, name = 'Test Package'}
    LXRTebex.DeliverPackage(playerId, mockPackage, 'TEST_' .. os.time())
    
    print(('[LXRCore] [Tebex] Test delivery completed'):format())
end, true)

-- ============================================
-- EXPORTS
-- ============================================

exports('GiveGoldCurrency', function(playerId, amount, reason)
    local Player = exports['lxr-core']:GetPlayer(playerId)
    if not Player then return false end
    
    return Player.Functions.AddMoney('goldcurrency', amount, reason or 'Admin Give')
end)

exports('GiveTokens', function(playerId, amount, reason)
    local Player = exports['lxr-core']:GetPlayer(playerId)
    if not Player then return false end
    
    return Player.Functions.AddMoney('tokens', amount, reason or 'Admin Give')
end)

exports('GetTebexStats', function()
    return {
        enabled = config.enabled,
        packages = packageCount,
        queueSize = offlineQueueSize
    }
end)

print('^2[LXRCore] [Tebex]^7 Module loaded successfully')
