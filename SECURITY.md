# LXRCore Security Guide

<div align="center">

![LXRCore Security](https://via.placeholder.com/600x100/1a1a2e/ff4444?text=LXRCore+Security+Guide)

**Military-Grade Security for RedM Servers**

[🏠 Home](README.md) • [📚 Documentation](DOCUMENTATION.md) • [⚡ Performance](PERFORMANCE.md)

**Made by iBoss • LXRCore - www.lxrcore.com**

**Launched on [The Land of Wolves RP](https://www.wolves.land)**

</div>

---

## 🔒 Security Overview

LXRCore includes enterprise-grade security features designed to protect your RedM server from exploits, cheaters, and malicious attacks. Every security feature is battle-tested on The Land of Wolves RP with 48+ concurrent players.

---

## 🛡️ Built-In Security Features

### 1. Rate Limiting System

**What It Does:**
Prevents players from spamming events to crash your server or exploit bugs.

**How It Works:**
- Tracks every event per player
- Limits events to 10 calls per second by default
- Automatically blocks excessive requests
- Logs violations for admin review

**Configuration:**
```lua
-- In server/security.lua (lines 8-11)
local rateLimitConfig = {
    defaultLimit = 10,   -- Max calls per window
    windowSize = 1000,   -- Window size in ms
}
```

**For Server Owners:**
- Default settings work for 99% of servers
- Increase limits if you have custom scripts with heavy event usage
- Check logs regularly for rate limit violations

**Example Protection:**
```lua
-- Player tries to spam add money event
-- LXRCore automatically blocks after 10 attempts in 1 second
-- Admin gets notified in logs
```

---

### 2. Input Validation

**What It Does:**
Validates all data sent from clients to prevent crashes and exploits.

**Protected Data Types:**
- ✅ Strings (length and content checks)
- ✅ Numbers (NaN and infinity protection)
- ✅ Booleans (type verification)
- ✅ Tables (structure validation)

**Protected Operations:**
- Money transactions
- Item operations
- Player data updates
- Callback triggers

**For Developers:**
```lua
-- LXRCore automatically validates inputs
-- Example: Adding money
TriggerEvent('LXRCore:Server:AddMoney', source, 'cash', 100)

-- Internally validates:
-- - Is source valid?
-- - Is 'cash' a string?
-- - Is 100 a valid number?
-- - Is amount within acceptable range?
```

---

### 3. Anti-Cheat System

**What It Monitors:**
- Rapid money gains (>$100k in 60 seconds)
- Rapid item acquisition (>50 items in 10 seconds)
- Suspicious player behavior patterns

**How It Works:**
```lua
-- Automatic monitoring in player functions
-- When player adds money:
1. Check rate of money gain
2. Compare against thresholds
3. Log suspicious activity
4. Optional: Auto-ban on severe violations
```

**Thresholds:**
```lua
-- In server/security.lua
local suspiciousPatterns = {
    rapidMoney = { 
        threshold = 100000,  -- $100k
        window = 60000       -- in 60 seconds
    },
    rapidItems = { 
        threshold = 50,      -- 50 items
        window = 10000       -- in 10 seconds
    },
}
```

**For Server Owners:**
- Review anti-cheat logs daily
- Adjust thresholds for your economy
- Set up Discord webhooks for alerts

---

### 4. SQL Injection Protection

**What It Does:**
Prevents SQL injection attacks that could compromise your database.

**Protection Layers:**
1. **Prepared Statements**: All queries use parameterized statements
2. **Input Sanitization**: Secondary validation layer
3. **Type Checking**: Ensures data types match expectations

**Developer Note:**
```lua
-- SECURE: Using prepared statements
MySQL.query.await('SELECT * FROM players WHERE citizenid = ?', {citizenid})

-- NEVER DO THIS:
-- MySQL.query.await('SELECT * FROM players WHERE citizenid = ' .. citizenid)
```

---

### 5. Event Security

**Protected Events:**
All critical LXRCore events include:
- Source validation
- Rate limiting
- Input validation
- Suspicious activity detection

**Secured Events List:**
```lua
'LXRCore:Server:UseItem'          -- Rate limit: 5/sec
'LXRCore:Server:AddItem'          -- Rate limit: 20/sec + anti-cheat
'LXRCore:Server:RemoveItem'       -- Rate limit: 20/sec
'LXRCore:Server:TriggerCallback'  -- Rate limit: 30/sec
'LXRCore:UpdatePlayer'            -- Rate limit: Default
```

---

## 🔐 Security Best Practices

### For Server Owners

#### 1. Regular Monitoring
```bash
# Check performance and security logs
/lxr:performance

# Monitor database cache
/lxr:cachestats

# Review server console regularly
```

#### 2. ACE Permissions
```cfg
# In server.cfg - Protect admin commands
add_ace group.admin command.lxr:performance allow
add_ace group.admin command.lxr:cachestats allow

# Add admins
add_principal identifier.license:xxxxx group.admin
```

#### 3. Database Security
```cfg
# Use strong database passwords
set mysql_connection_string "mysql://user:STRONG_PASSWORD@localhost/db"

# Restrict database access
# Only allow localhost connections
```

#### 4. Backup Strategy
- Daily automated backups
- Store backups off-server
- Test restore procedures monthly

#### 5. Update Regularly
```bash
# Keep LXRCore updated
cd resources/lxr-core
git pull origin main
```

---

### For Developers

#### 1. Always Validate Inputs
```lua
-- BAD: No validation
RegisterNetEvent('myScript:giveMoney')
AddEventHandler('myScript:giveMoney', function(amount)
    local Player = exports['lxr-core']:GetPlayer(source)
    Player.Functions.AddMoney('cash', amount)
end)

-- GOOD: With validation
RegisterNetEvent('myScript:giveMoney')
AddEventHandler('myScript:giveMoney', function(amount)
    -- Validate source
    if not exports['lxr-core']:ValidateSource(source) then return end
    
    -- Rate limit
    if not exports['lxr-core']:CheckRateLimit(source, 'giveMoney', 5) then return end
    
    -- Validate amount
    if type(amount) ~= 'number' or amount < 0 or amount > 1000 then return end
    
    local Player = exports['lxr-core']:GetPlayer(source)
    Player.Functions.AddMoney('cash', amount, 'Script reward')
end)
```

#### 2. Use Server-Side Validation
```lua
-- BAD: Client determines everything
RegisterNetEvent('myScript:buyItem')
AddEventHandler('myScript:buyItem', function(item, price)
    -- Client could send fake price!
    local Player = exports['lxr-core']:GetPlayer(source)
    Player.Functions.RemoveMoney('cash', price)
    Player.Functions.AddItem(item, 1)
end)

-- GOOD: Server validates everything
local itemPrices = {
    ['bread'] = 5,
    ['water'] = 3,
}

RegisterNetEvent('myScript:buyItem')
AddEventHandler('myScript:buyItem', function(item)
    local Player = exports['lxr-core']:GetPlayer(source)
    local price = itemPrices[item]
    
    if not price then return end
    if Player.Functions.GetMoney('cash') < price then return end
    
    Player.Functions.RemoveMoney('cash', price, 'Purchase: ' .. item)
    Player.Functions.AddItem(item, 1)
end)
```

#### 3. Log Important Actions
```lua
-- Log for audit trail
Player.Functions.AddMoney('cash', 10000, 'Admin give - by John')

-- Logs include:
-- - Who received money
-- - How much
-- - Why (reason)
-- - When (timestamp)
-- - Admin who gave it
```

---

## 🚨 Incident Response

### Detecting Exploits

#### Signs of Exploitation:
1. **Rapid wealth gain** - Players suddenly have millions
2. **Inventory overflow** - Players with hundreds of rare items
3. **Rate limit violations** - Console shows blocked events
4. **Database anomalies** - Unusual query patterns

#### What To Do:

1. **Immediate Action:**
   ```bash
   # Check player data
   /lxr:performance
   
   # Review recent money transactions
   # Check database logs
   ```

2. **Investigation:**
   - Review server console logs
   - Check anti-cheat logs in database
   - Interview suspected players
   - Review script logs

3. **Response:**
   ```lua
   -- Remove exploited items/money
   local Player = exports['lxr-core']:GetPlayer(source)
   Player.Functions.SetMoney('cash', 0, 'Exploit removal')
   Player.Functions.ClearInventory()
   
   -- Ban if necessary
   -- Add to bans table
   ```

---

## 📊 Security Monitoring

### Admin Commands

```bash
# View performance (includes security metrics)
/lxr:performance

# View database cache stats
/lxr:cachestats
```

### Log Files

LXRCore logs security events to:
- Server console (real-time)
- lxr-log system (if installed)
- Database audit tables

### What Gets Logged:

✅ Rate limit violations
✅ Suspicious activity detections
✅ Large money transactions (>$100k)
✅ All admin actions
✅ Failed validation attempts

---

## 🔧 Security Configuration

### Adjusting Rate Limits

In `server/security.lua`:

```lua
-- For high-traffic servers (100+ players)
local rateLimitConfig = {
    defaultLimit = 20,   -- Increase from 10
    windowSize = 1000,
}

-- For roleplay-heavy servers (strict control)
local rateLimitConfig = {
    defaultLimit = 5,    -- Decrease from 10
    windowSize = 1000,
}
```

### Adjusting Anti-Cheat Thresholds

```lua
-- For economy-rich servers
local suspiciousPatterns = {
    rapidMoney = { 
        threshold = 500000,  -- Increase from 100k
        window = 60000
    },
}

-- For strict economy servers
local suspiciousPatterns = {
    rapidMoney = { 
        threshold = 50000,   -- Decrease from 100k
        window = 60000
    },
}
```

---

## 🎓 Security Checklist

### Initial Setup
- [ ] Strong database password
- [ ] ACE permissions configured
- [ ] Admin accounts secured
- [ ] Backup system in place
- [ ] Security logs reviewed

### Weekly Tasks
- [ ] Review security logs
- [ ] Check for rate limit violations
- [ ] Monitor player wealth distribution
- [ ] Update LXRCore if needed
- [ ] Test backup restoration

### Monthly Tasks
- [ ] Full security audit
- [ ] Review admin permissions
- [ ] Update all resources
- [ ] Performance review
- [ ] Player data cleanup

---

## 📞 Reporting Security Issues

Found a security vulnerability? Please report responsibly:

1. **DO NOT** post publicly on GitHub
2. **DO** email security concerns to: security@lxrcore.com
3. Include detailed reproduction steps
4. We respond within 24 hours
5. Credit given for responsible disclosure

---

## 🏆 Security Achievements

LXRCore has been tested against:

✅ Item duplication exploits
✅ Money duplication exploits
✅ SQL injection attempts
✅ Event spam attacks
✅ Database overflow attacks
✅ Client-side manipulation
✅ Permission bypass attempts

**Result:** Zero successful exploits in production on The Land of Wolves RP

---

<div align="center">

**Made by iBoss • LXRCore - www.lxrcore.com**

**Launched on [The Land of Wolves RP](https://www.wolves.land)**

[⬆ Back to Top](#lxrcore-security-guide)

</div>
