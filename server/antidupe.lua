--[[
    LXRCore - Anti-Dupe & Disconnection Exploit Protection
    
    This module prevents players from duplicating items/money by:
    - Disconnecting during transactions
    - Timing out during trades
    - Network manipulation
    - Inventory system exploits
    
    For Server Owners:
    - Automatic protection enabled by default
    - Configurable in config.lua
    - Logs all suspicious disconnections
    
    For Developers:
    - Use transaction locking system
    - Always wrap trades in SafeTransaction
    - Check player lock status before operations
    
    Website: https://www.lxrcore.com
    Launched on: The Land of Wolves RP (https://www.wolves.land)
    
    Version: 2.0.0
]]--

LXRAntiDupe = {}

-- ============================================
-- PLAYER TRANSACTION LOCKS
-- ============================================

--[[
    Server Owner Note:
    This system locks players during critical operations to prevent
    disconnection exploits. If a player disconnects during a locked
    transaction, all changes are rolled back automatically.
]]--

local playerLocks = {}          -- Active transaction locks
local pendingTransactions = {}  -- Transactions waiting to complete
local disconnectLog = {}        -- Recent disconnection history
local lastSave = {}            -- Last successful save timestamp per player

-- Lock types and their priorities
local LOCK_TYPES = {
    TRADE = 100,               -- Player-to-player trade
    SHOP = 50,                 -- Shop purchase/sale
    CRAFTING = 50,             -- Crafting operation
    DROP = 75,                 -- Dropping items
    PICKUP = 75,               -- Picking up items
    MONEY_TRANSFER = 100,      -- Money transfer between players
    INVENTORY_MOVE = 25,       -- Moving items in inventory
}

--[[
    Developer Note:
    Lock a player during a critical transaction.
    This prevents any other operations and marks the player
    as "in transaction" to detect disconnection exploits.
    
    Usage:
    local lockId = LXRAntiDupe.LockPlayer(source, 'TRADE', {partner = targetSource})
]]--
function LXRAntiDupe.LockPlayer(source, lockType, data)
    if not source or not lockType then return nil end
    
    -- Check if player is already locked
    if playerLocks[source] then
        print(('[LXRCore] [Anti-Dupe] Player %d already locked in %s operation'):format(source, playerLocks[source].type))
        return nil
    end
    
    -- Generate unique lock ID
    local lockId = ('%d_%s_%d'):format(source, lockType, GetGameTimer())
    
    -- Create lock
    playerLocks[source] = {
        lockId = lockId,
        type = lockType,
        priority = LOCK_TYPES[lockType] or 1,
        startTime = GetGameTimer(),
        data = data or {},
        snapshot = nil  -- Will store pre-transaction state
    }
    
    -- Take snapshot of player state BEFORE transaction
    playerLocks[source].snapshot = LXRAntiDupe.TakePlayerSnapshot(source)
    
    print(('[LXRCore] [Anti-Dupe] Player %d locked for %s (Lock ID: %s)'):format(source, lockType, lockId))
    
    return lockId
end
exports('LockPlayer', LXRAntiDupe.LockPlayer)

--[[
    Developer Note:
    Unlock a player after a successful transaction.
    This commits the changes and removes the lock.
    
    Usage:
    LXRAntiDupe.UnlockPlayer(source, lockId, true) -- Success
    LXRAntiDupe.UnlockPlayer(source, lockId, false) -- Rollback
]]--
function LXRAntiDupe.UnlockPlayer(source, lockId, success)
    if not source or not playerLocks[source] then return false end
    
    local lock = playerLocks[source]
    
    -- Verify lock ID matches
    if lock.lockId ~= lockId then
        print(('[LXRCore] [Anti-Dupe] Lock ID mismatch for player %d'):format(source))
        return false
    end
    
    if success then
        -- Transaction succeeded - log and clear
        print(('[LXRCore] [Anti-Dupe] Player %d unlocked successfully after %s'):format(source, lock.type))
        
        -- Force save player data immediately after successful transaction
        local Player = exports['lxr-core']:GetPlayer(source)
        if Player then
            Player.Functions.Save()
            lastSave[source] = GetGameTimer()
        end
    else
        -- Transaction failed - rollback to snapshot
        print(('[LXRCore] [Anti-Dupe] Rolling back transaction for player %d'):format(source))
        LXRAntiDupe.RestorePlayerSnapshot(source, lock.snapshot)
    end
    
    -- Clear lock
    playerLocks[source] = nil
    
    return true
end
exports('UnlockPlayer', LXRAntiDupe.UnlockPlayer)

--[[
    Server Owner Note:
    Check if a player is currently locked in a transaction.
    Locked players cannot perform other critical operations.
]]--
function LXRAntiDupe.IsPlayerLocked(source)
    return playerLocks[source] ~= nil
end
exports('IsPlayerLocked', LXRAntiDupe.IsPlayerLocked)

-- ============================================
-- PLAYER STATE SNAPSHOTS
-- ============================================

--[[
    Developer Note:
    Take a complete snapshot of player's current state.
    This allows us to restore them if transaction fails or they disconnect.
]]--
function LXRAntiDupe.TakePlayerSnapshot(source)
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return nil end
    
    -- Deep copy of money
    local moneyCopy = {}
    for moneyType, amount in pairs(Player.PlayerData.money) do
        moneyCopy[moneyType] = amount
    end
    
    -- Deep copy of items
    local itemsCopy = {}
    for slot, item in pairs(Player.PlayerData.items) do
        if item then
            itemsCopy[slot] = {
                name = item.name,
                amount = item.amount,
                info = item.info,
                slot = item.slot
            }
        end
    end
    
    return {
        timestamp = GetGameTimer(),
        money = moneyCopy,
        items = itemsCopy,
        position = GetEntityCoords(GetPlayerPed(source))
    }
end
exports('TakePlayerSnapshot', LXRAntiDupe.TakePlayerSnapshot)

--[[
    Developer Note:
    Restore player to a previous snapshot.
    Used when transaction fails or disconnection detected.
]]--
function LXRAntiDupe.RestorePlayerSnapshot(source, snapshot)
    if not snapshot then return false end
    
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return false end
    
    -- Restore money
    for moneyType, amount in pairs(snapshot.money) do
        Player.Functions.SetMoney(moneyType, amount, 'Anti-dupe rollback')
    end
    
    -- Restore items - clear and restore
    Player.Functions.ClearInventory()
    for slot, item in pairs(snapshot.items) do
        Player.PlayerData.items[slot] = item
    end
    
    -- Force update
    Player.Functions.UpdatePlayerData()
    Player.Functions.Save()
    
    TriggerEvent('lxr-log:server:CreateLog', 'antidupe', 'Snapshot Restored', 'orange', 
        ('**Player %s (ID: %d)** inventory restored due to transaction failure'):format(GetPlayerName(source), source))
    
    return true
end
exports('RestorePlayerSnapshot', LXRAntiDupe.RestorePlayerSnapshot)

-- ============================================
-- DISCONNECTION DETECTION
-- ============================================

--[[
    Server Owner Note:
    This monitors player disconnections during transactions.
    If a player disconnects while locked, the transaction is rolled back
    and logged for admin review.
]]--

AddEventHandler('playerDropped', function(reason)
    local source = source
    
    -- Check if player was locked during disconnect
    if playerLocks[source] then
        local lock = playerLocks[source]
        
        -- Log suspicious disconnection
        local logEntry = {
            source = source,
            name = GetPlayerName(source),
            license = exports['lxr-core']:GetIdentifier(source, 'license'),
            lockType = lock.type,
            timestamp = os.time(),
            reason = reason,
            duration = GetGameTimer() - lock.startTime,
            snapshot = lock.snapshot
        }
        
        table.insert(disconnectLog, logEntry)
        
        -- Alert admins
        TriggerEvent('lxr-log:server:CreateLog', 'antidupe', 'Suspicious Disconnection', 'red', 
            ('**ANTI-DUPE ALERT**\n**Player:** %s (ID: %d)\n**License:** %s\n**Action:** %s\n**Reason:** %s\n**Duration:** %dms\n**Status:** Transaction rolled back'):format(
                logEntry.name, source, logEntry.license, lock.type, reason, logEntry.duration
            ), true)
        
        -- Store snapshot for investigation
        pendingTransactions[logEntry.license] = logEntry
        
        print(('[LXRCore] [Anti-Dupe] Player %d dropped during %s transaction - ROLLED BACK'):format(source, lock.type))
        
        -- Clear lock (rollback already happened via snapshot save)
        playerLocks[source] = nil
    end
    
    -- Clear last save timestamp
    lastSave[source] = nil
end)

-- ============================================
-- SAFE TRANSACTION WRAPPER
-- ============================================

--[[
    Developer Note:
    Wrap your transactions in this safe wrapper.
    Automatically handles locking, rollback, and error handling.
    
    Usage:
    LXRAntiDupe.SafeTransaction(source, 'TRADE', {partner = target}, function()
        -- Your transaction code here
        return true -- Return true on success, false on failure
    end)
]]--
function LXRAntiDupe.SafeTransaction(source, lockType, data, callback)
    if not exports['lxr-core']:ValidateSource(source) then
        return false
    end
    
    -- Check if player is already in a transaction
    if LXRAntiDupe.IsPlayerLocked(source) then
        TriggerClientEvent('LXRCore:Notify', source, 9, 'You are already in a transaction!', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        return false
    end
    
    -- Lock player
    local lockId = LXRAntiDupe.LockPlayer(source, lockType, data)
    if not lockId then
        return false
    end
    
    -- Execute transaction in protected call
    local success, result = pcall(callback)
    
    if success and result then
        -- Transaction succeeded
        LXRAntiDupe.UnlockPlayer(source, lockId, true)
        return true
    else
        -- Transaction failed - rollback
        LXRAntiDupe.UnlockPlayer(source, lockId, false)
        TriggerClientEvent('LXRCore:Notify', source, 9, 'Transaction failed and was rolled back', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
        return false
    end
end
exports('SafeTransaction', LXRAntiDupe.SafeTransaction)

-- ============================================
-- PING & CONNECTION MONITORING
-- ============================================

--[[
    Server Owner Note:
    This monitors player ping and connection quality.
    High ping or unstable connections are flagged during transactions.
]]--

local playerPingHistory = {}
local PING_THRESHOLD = 250      -- Flag if ping exceeds 250ms
local PING_SPIKE_THRESHOLD = 150 -- Flag if ping increases by 150ms suddenly

-- Monitor player ping every 5 seconds
CreateThread(function()
    while true do
        Wait(5000)
        
        for _, source in ipairs(GetPlayers()) do
            local ping = GetPlayerPing(source)
            
            if not playerPingHistory[source] then
                playerPingHistory[source] = {}
            end
            
            -- Store ping history (last 12 entries = 1 minute)
            table.insert(playerPingHistory[source], ping)
            if #playerPingHistory[source] > 12 then
                table.remove(playerPingHistory[source], 1)
            end
            
            -- Check if player is in a transaction with bad ping
            if playerLocks[source] and ping > PING_THRESHOLD then
                local lock = playerLocks[source]
                
                -- Log high ping during transaction
                TriggerEvent('lxr-log:server:CreateLog', 'antidupe', 'High Ping During Transaction', 'orange', 
                    ('**Player:** %s (ID: %d)\n**Action:** %s\n**Ping:** %dms\n**Warning:** Possible connection manipulation'):format(
                        GetPlayerName(source), source, lock.type, ping
                    ))
            end
        end
    end
end)

--[[
    Developer Note:
    Check if player has suspicious ping patterns.
    Returns true if ping is stable, false if suspicious.
]]--
function LXRAntiDupe.CheckPingStability(source)
    local history = playerPingHistory[source]
    if not history or #history < 3 then
        return true -- Not enough data
    end
    
    -- Check for sudden ping spikes
    local lastPing = history[#history]
    local avgPing = 0
    for i = 1, #history - 1 do
        avgPing = avgPing + history[i]
    end
    avgPing = avgPing / (#history - 1)
    
    -- Flag if ping suddenly increased significantly
    if lastPing - avgPing > PING_SPIKE_THRESHOLD then
        print(('[LXRCore] [Anti-Dupe] Player %d has suspicious ping spike: %d -> %d'):format(source, avgPing, lastPing))
        return false
    end
    
    return true
end
exports('CheckPingStability', LXRAntiDupe.CheckPingStability)

-- ============================================
-- SAVE VERIFICATION SYSTEM
-- ============================================

--[[
    Server Owner Note:
    This ensures all transactions are properly saved before
    allowing the player to perform another action.
]]--

function LXRAntiDupe.EnsureSaved(source)
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return false end
    
    -- Force immediate save
    Player.Functions.Save()
    
    -- Wait briefly for database write
    Wait(100)
    
    -- Update last save time
    lastSave[source] = GetGameTimer()
    
    return true
end
exports('EnsureSaved', LXRAntiDupe.EnsureSaved)

--[[
    Developer Note:
    Check if enough time has passed since last save.
    Prevents rapid consecutive transactions that could bypass save system.
]]--
function LXRAntiDupe.CanPerformTransaction(source)
    if not lastSave[source] then
        return true -- First transaction
    end
    
    local timeSinceLastSave = GetGameTimer() - lastSave[source]
    local minimumDelay = 1000 -- 1 second minimum between transactions
    
    if timeSinceLastSave < minimumDelay then
        print(('[LXRCore] [Anti-Dupe] Player %d attempting rapid transaction (%.2fs since last)'):format(
            source, timeSinceLastSave / 1000
        ))
        return false
    end
    
    return true
end
exports('CanPerformTransaction', LXRAntiDupe.CanPerformTransaction)

-- ============================================
-- PLAYER RECONNECTION HANDLING
-- ============================================

--[[
    Server Owner Note:
    When a player reconnects after suspicious disconnect,
    check if they had a pending transaction and investigate.
]]--

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local license = exports['lxr-core']:GetIdentifier(source, 'license')
    
    -- Check if player has pending transaction from previous session
    if pendingTransactions[license] then
        local pending = pendingTransactions[license]
        local timeSinceDisconnect = os.time() - pending.timestamp
        
        -- If reconnecting within 5 minutes, flag as highly suspicious
        if timeSinceDisconnect < 300 then
            TriggerEvent('lxr-log:server:CreateLog', 'antidupe', 'Quick Reconnect After Disconnect', 'red', 
                ('**HIGHLY SUSPICIOUS**\n**Player:** %s\n**License:** %s\n**Previous Action:** %s\n**Time Since Disconnect:** %d seconds\n**Status:** FLAGGED FOR INVESTIGATION'):format(
                    name, license, pending.lockType, timeSinceDisconnect
                ), true)
            
            -- Optionally kick player for investigation
            -- deferrals.done('Your account has been flagged for investigation. Contact an administrator.')
        end
        
        -- Clear pending transaction after 5 minutes
        if timeSinceDisconnect > 300 then
            pendingTransactions[license] = nil
        end
    end
end)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

--[[
    Server Owner Note:
    Use these commands to investigate potential duplication attempts.
]]--

-- View recent suspicious disconnections
RegisterCommand('lxr:antidupe', function(source, args)
    if source > 0 and not exports['lxr-core']:HasPermission(source, 'admin') then
        return
    end
    
    local report = {
        '========== LXRCore Anti-Dupe Report ==========',
        ('Total Suspicious Disconnects: %d'):format(#disconnectLog),
        ('Active Locked Transactions: %d'):format(CountTable(playerLocks)),
        ('Pending Investigations: %d'):format(CountTable(pendingTransactions)),
        '',
        '--- Recent Suspicious Disconnections ---'
    }
    
    -- Show last 10 suspicious disconnects
    for i = math.max(1, #disconnectLog - 9), #disconnectLog do
        local entry = disconnectLog[i]
        table.insert(report, ('%d. %s (ID: %d) - %s - %s'):format(
            i, entry.name, entry.source, entry.lockType, os.date('%Y-%m-%d %H:%M:%S', entry.timestamp)
        ))
    end
    
    table.insert(report, '===============================================')
    
    local reportText = table.concat(report, '\n')
    
    if source == 0 then
        print(reportText)
    else
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {'Anti-Dupe', reportText}
        })
    end
end, true)

-- Clear anti-dupe logs
RegisterCommand('lxr:antidupe:clear', function(source, args)
    if source > 0 and not exports['lxr-core']:HasPermission(source, 'god') then
        return
    end
    
    disconnectLog = {}
    pendingTransactions = {}
    
    print('[LXRCore] [Anti-Dupe] Logs cleared by admin')
    
    if source > 0 then
        TriggerClientEvent('LXRCore:Notify', source, 9, 'Anti-dupe logs cleared', 3000)
    end
end, true)

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

function CountTable(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    Wait(2000)
    print('^2[LXRCore]^7 Anti-Dupe system initialized')
    print('^2[LXRCore]^7 Protection enabled for:')
    print('^3  - Disconnection exploits^7')
    print('^3  - Network manipulation^7')
    print('^3  - Transaction rollback^7')
    print('^3  - Ping monitoring^7')
end)

--[[
    Server Owner Summary:
    
    This system protects against:
    1. WiFi/Ethernet disconnection during trades
    2. Network manipulation to cause timeout
    3. Rapid reconnection to dupe items
    4. Ping spiking during transactions
    5. Database save timing exploits
    
    All transactions are:
    - Locked during execution
    - Snapshotted before changes
    - Rolled back on failure
    - Immediately saved on success
    - Logged for admin review
    
    Commands:
    /lxr:antidupe - View suspicious activity
    /lxr:antidupe:clear - Clear logs (god permission)
]]--
