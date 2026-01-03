# LXRCore Complete Documentation

<div align="center">

![LXRCore](https://via.placeholder.com/600x100/1a1a2e/16c784?text=LXRCore+Documentation)

**Complete Setup & Configuration Guide**

[🏠 Home](../README.md) • [⚡ Performance](PERFORMANCE.md) • [🔒 Security](SECURITY.md)

**Launched on [The Land of Wolves RP](https://www.wolves.land)**  
**Official Website: [www.lxrcore.com](https://www.lxrcore.com)**

</div>

---

## 📋 Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Framework Bridge](#framework-bridge)
5. [Event System](#event-system)
6. [Exports & Functions](#exports--functions)
7. [Player Management](#player-management)
8. [Item System](#item-system)
9. [Job System](#job-system)
10. [Gang System](#gang-system)
11. [Admin Commands](#admin-commands)
12. [Troubleshooting](#troubleshooting)

---

## 🎯 Introduction

### What Makes LXRCore Different?

LXRCore is designed for **server owners** and **developers** who want:

✅ **Maximum Performance** - 70% faster than traditional frameworks  
✅ **Total Security** - Built-in anti-cheat and rate limiting  
✅ **Easy Installation** - Works standalone or with existing frameworks  
✅ **Professional Support** - Tested on The Land of Wolves RP  

### Key Capabilities

- **Standalone Operation**: Works independently, no other framework required
- **Auto-Bridge Mode**: Automatically compatible with VORP, RSG-Core, RedM-RP scripts
- **Branded Events**: All events use `LXRCore:` prefix for consistency
- **Performance Monitoring**: Built-in real-time metrics and reporting

---

## 📦 Installation

### For Server Owners

#### Prerequisites
- RedM Server (latest build)
- MySQL or MariaDB database
- oxmysql resource

#### Step 1: Download LXRCore
```bash
cd resources
git clone https://github.com/LXRCore/lxr-core.git
```

#### Step 2: Import Database
```bash
mysql -u your_username -p your_database < lxr-core/lxrcore.sql
```

#### Step 3: Configure server.cfg
```cfg
# Database Configuration
set mysql_connection_string "mysql://username:password@localhost/database"

# LXRCore Configuration
ensure oxmysql
ensure lxr-core

# Optional: Add your existing resources below
# LXRCore will automatically bridge with them!
```

#### Step 4: Edit Config
Open `lxr-core/config.lua` and adjust:
```lua
LXRConfig.MaxPlayers = 48              -- Your server player limit
LXRConfig.UpdateInterval = 5           -- Save player data every X minutes
LXRConfig.EnablePVP = true             -- Enable/disable PVP
LXRConfig.Discord = "your_discord_link"
```

#### Step 5: Start Server
```bash
./run.sh
```

You should see:
```
========================================
     LXRCore Framework v2.0.0
========================================
  Launched on The Land of Wolves RP
  Website: www.lxrcore.com
========================================
[LXRCore] Running in standalone mode - Full LXRCore features available
[LXRCore] Bridge system initialized successfully!
```

### For Developers

#### Prerequisites
- Basic Lua knowledge
- Understanding of RedM natives
- Text editor or IDE (VS Code recommended)

#### Quick Start
```lua
-- Get player data
local Player = exports['lxr-core']:GetPlayer(source)

-- Add money
Player.Functions.AddMoney('cash', 100, 'Reward')

-- Add item
Player.Functions.AddItem('weapon_revolver', 1, false, {ammo = 100})

-- Trigger callback
exports['lxr-core']:TriggerCallback('LXRCore:HasItem', source, function(hasItem)
    print(hasItem)
end, 'bread')
```

---

## ⚙️ Configuration

### config.lua Reference

#### Server Settings
```lua
-- Maximum players allowed on the server
-- Server Owner: Set this to match your server.cfg sv_maxclients
LXRConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48)

-- Default spawn location when player first joins
-- Server Owner: Change this to your preferred spawn point
LXRConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)

-- How often to save player data (in minutes)
-- Server Owner: Lower = more frequent saves but more database load
LXRConfig.UpdateInterval = 5

-- Enable/disable PVP on the server
-- Server Owner: Set to false for PVE-only servers
LXRConfig.EnablePVP = true

-- Your Discord invite link
LXRConfig.Discord = ""

-- Close server to public (only admins can join)
LXRConfig.ServerClosed = false
LXRConfig.ServerClosedReason = "Server Closed"

-- Use connectqueue resource for queue system
LXRConfig.UseConnectQueue = true

-- Permission groups (add more as needed)
LXRConfig.Permissions = {'god', 'admin', 'mod'}
```

#### Money Configuration
```lua
-- Money types and starting amounts
-- Server Owner: Add custom money types here (like gold, tokens, etc)
LXRConfig.Money.MoneyTypes = {
    ['cash'] = 2,      -- Starting cash amount
    ['bank'] = 40      -- Starting bank amount
}

-- Money types that cannot go negative
-- Server Owner: Prevents players from having negative cash
LXRConfig.Money.DontAllowMinus = {'cash'}

-- Paycheck interval (minutes)
LXRConfig.Money.PayCheckTimeOut = 10

-- Paychecks come from society accounts (requires lxr-bossmenu)
LXRConfig.Money.PayCheckSociety = false
```

#### Player Settings
```lua
-- Reveal entire map on first join
LXRConfig.Player.RevealMap = true

-- Maximum carrying weight (in grams)
-- Server Owner: 120000 = 120kg
LXRConfig.Player.MaxWeight = 120000

-- Maximum inventory slots
LXRConfig.Player.MaxInvSlots = 41

-- Available blood types
LXRConfig.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"
}
```

---

## 🌉 Framework Bridge

### Understanding Bridge Mode

LXRCore's **Bridge System** allows it to work with existing framework scripts automatically.

#### How It Works

1. **Detection**: On startup, LXRCore detects installed frameworks
2. **Bridging**: Automatically creates event bridges
3. **Translation**: Converts between framework formats
4. **Compatibility**: Old scripts work without modification

#### Supported Frameworks

| Framework | Detection Resource | Compatibility |
|-----------|-------------------|---------------|
| VORP | `vorp_core` | ✅ Full |
| RSG-Core | `rsg-core` | ✅ Full |
| RedM-RP | `redmrp` | ✅ Full |
| QBR-Core | `qbr-core` | ✅ Full |

#### Server Owner Benefits

- ✅ **No script conversion needed** - Use any framework script
- ✅ **Gradual migration** - Move to LXRCore at your own pace
- ✅ **Mix & match** - Run VORP and RSG scripts together
- ✅ **Performance boost** - LXRCore optimizations apply to all scripts

#### Example: Using VORP Scripts

```lua
-- Old VORP script still works:
TriggerEvent('vorp:addMoney', source, 0, 'cash', 100)

-- LXRCore automatically translates to:
TriggerEvent('LXRCore:Server:AddMoney', source, 'cash', 100)
```

---

## 🎮 Event System

### All LXRCore Events (Branded)

All events are prefixed with `LXRCore:` for professional consistency.

#### Server Events

```lua
-- Player lifecycle events
RegisterNetEvent('LXRCore:Server:OnPlayerLoaded')
RegisterNetEvent('LXRCore:Server:OnPlayerUnload')
RegisterNetEvent('LXRCore:UpdatePlayer')

-- Player actions
RegisterNetEvent('LXRCore:Server:SetMetaData')
RegisterNetEvent('LXRCore:ToggleDuty')

-- Item management
RegisterNetEvent('LXRCore:Server:UseItem')
RegisterNetEvent('LXRCore:Server:AddItem')
RegisterNetEvent('LXRCore:Server:RemoveItem')

-- XP system
RegisterNetEvent('LXRCore:Player:GiveXp')
RegisterNetEvent('LXRCore:Player:RemoveXp')
RegisterNetEvent('LXRCore:Player:SetLevel')

-- Callback system
RegisterNetEvent('LXRCore:Server:TriggerCallback')
```

#### Client Events

```lua
-- Player lifecycle
RegisterNetEvent('LXRCore:Client:OnPlayerLoaded')
RegisterNetEvent('LXRCore:Client:OnPlayerUnload')
RegisterNetEvent('LXRCore:Client:SetDuty')

-- Teleportation
RegisterNetEvent('LXRCore:Command:TeleportToPlayer')
RegisterNetEvent('LXRCore:Command:TeleportToCoords')
RegisterNetEvent('LXRCore:Command:GoToMarker')

-- Notifications
RegisterNetEvent('LXRCore:Notify')

-- Player data updates
RegisterNetEvent('LXRCore:Player:SetPlayerData')

-- Callback responses
RegisterNetEvent('LXRCore:Client:TriggerCallback')
```

### Event Usage Examples

#### For Developers

```lua
-- Server-side: Give player money
TriggerEvent('LXRCore:Server:AddMoney', source, 'cash', 500, 'Quest Reward')

-- Server-side: Add item to player
TriggerEvent('LXRCore:Server:AddItem', source, 'bread', 5, false, {quality = 100})

-- Client-side: Show notification
TriggerEvent('LXRCore:Notify', 9, 'Welcome to the server!', 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')

-- Server-side: Use callback
exports['lxr-core']:CreateCallback('myResource:checkMoney', function(source, cb, amount)
    local Player = exports['lxr-core']:GetPlayer(source)
    local hasMoney = Player.Functions.GetMoney('cash') >= amount
    cb(hasMoney)
end)
```

---

## 📤 Exports & Functions

### Server Exports

#### Player Functions

```lua
-- Get single player by source
local Player = exports['lxr-core']:GetPlayer(source)

-- Get all online players
local players = exports['lxr-core']:GetPlayers()

-- Get all player objects
local allPlayers = exports['lxr-core']:GetLXRPlayers()

-- Get player by CitizenID
local Player = exports['lxr-core']:GetPlayerByCitizenId(citizenid)

-- Get player identifier
local license = exports['lxr-core']:GetIdentifier(source, 'license')
```

#### Job Functions

```lua
-- Get on-duty players for a job
local players, count = exports['lxr-core']:GetPlayersOnDuty('police')

-- Get duty count only
local count = exports['lxr-core']:GetDutyCount('police')
```

#### Item Functions

```lua
-- Create useable item
exports['lxr-core']:CreateUseableItem('bread', function(source, item)
    local Player = exports['lxr-core']:GetPlayer(source)
    -- Item use logic here
    Player.Functions.RemoveItem('bread', 1)
end)

-- Check if item is useable
local canUse = exports['lxr-core']:CanUseItem('bread')

-- Use item
exports['lxr-core']:UseItem(source, itemData)
```

#### Callback Functions

```lua
-- Create callback
exports['lxr-core']:CreateCallback('myCallback', function(source, cb, arg1, arg2)
    -- Process callback
    cb(result)
end)

-- Trigger callback
exports['lxr-core']:TriggerCallback('myCallback', source, function(result)
    print(result)
end, arg1, arg2)
```

#### Permission Functions

```lua
-- Check permission
local hasPermission = exports['lxr-core']:HasPermission(source, 'admin')

-- Get all permissions
local perms = exports['lxr-core']:GetPermissions(source)

-- Add permission
exports['lxr-core']:AddPermission(source, 'admin')

-- Remove permission
exports['lxr-core']:RemovePermission(source, 'admin')
```

### Client Exports

```lua
-- Get player data
local PlayerData = exports['lxr-core']:GetPlayerData()

-- Get entity coords with heading
local coords = exports['lxr-core']:GetCoords(entity)

-- Check if player has item
local hasItem = exports['lxr-core']:HasItem('bread')

-- Load model
exports['lxr-core']:LoadModel('a_c_horse_morgan_flaxenchestnut')

-- Spawn ped
exports['lxr-core']:SpawnPed('myPed', 'a_m_m_sdcowboy_01', x, y, z, heading)

-- Remove ped
exports['lxr-core']:RemovePed('myPed')
```

---

## 👤 Player Management

### Player Object Structure

```lua
Player = {
    PlayerData = {
        source = 1,                  -- Player server ID
        citizenid = "ABC12345",      -- Unique citizen ID
        license = "license:xxxxx",   -- Rockstar license
        name = "John Doe",           -- Character name
        money = {
            cash = 100,
            bank = 500
        },
        job = {
            name = "unemployed",
            label = "Unemployed",
            payment = 10,
            onduty = false,
            grade = {
                name = "Freelancer",
                level = 0
            }
        },
        gang = {
            name = "none",
            label = "No Gang",
            grade = {
                name = "none",
                level = 0
            }
        },
        charinfo = {
            firstname = "John",
            lastname = "Doe",
            birthdate = "01/01/1850",
            gender = 0,
            nationality = "American"
        },
        metadata = {
            health = 200,
            armor = 0,
            hunger = 100,
            thirst = 100,
            stress = 0,
            isdead = false,
            inlaststand = false,
            ishandcuffed = false,
            tracker = false,
            injail = 0,
            jailitems = {},
            status = {},
            phone = {},
            fitbit = {},
            commandbinds = {},
            bloodtype = "O+",
            dealerrep = 0,
            craftingrep = 0,
            attachmentcraftingrep = 0,
            currentapartment = nil,
            jobrep = {
                ["tow"] = 0,
                ["trucker"] = 0,
                ["taxi"] = 0,
                ["hotdog"] = 0
            },
            callsign = "NO CALLSIGN",
            fingerprint = "XX000XX0X0XX",
            walletid = "000-0000",
            criminalrecord = {
                ["hasRecord"] = false,
                ["date"] = nil
            },
            licences = {
                ["driver"] = true,
                ["business"] = false,
                ["weapon"] = false
            },
            inside = {
                house = nil,
                apartment = {
                    apartmentType = nil,
                    apartmentId = nil,
                }
            },
            phonedata = {
                SerialNumber = "XXXXX",
                InstalledApps = {},
            },
            xp = {},
            levels = {}
        },
        position = vector4(x, y, z, heading),
        items = {}
    },
    Functions = {} -- Player functions (see below)
}
```

### Player Functions

#### Money Management

```lua
-- Add money
Player.Functions.AddMoney(moneytype, amount, reason)
-- Example: Player.Functions.AddMoney('cash', 100, 'Job Payment')

-- Remove money
Player.Functions.RemoveMoney(moneytype, amount, reason)
-- Example: Player.Functions.RemoveMoney('bank', 50, 'Purchase')

-- Set money
Player.Functions.SetMoney(moneytype, amount, reason)
-- Example: Player.Functions.SetMoney('cash', 1000, 'Admin Give')

-- Get money
local cash = Player.Functions.GetMoney('cash')
```

#### Item Management

```lua
-- Add item
Player.Functions.AddItem(itemname, amount, slot, info)
-- Example: Player.Functions.AddItem('bread', 5, false, {quality = 100})

-- Remove item
Player.Functions.RemoveItem(itemname, amount, slot)
-- Example: Player.Functions.RemoveItem('bread', 1, 5)

-- Clear specific inventory slot
Player.Functions.ClearInventory(slots)
-- Example: Player.Functions.ClearInventory({1, 2, 3})
```

#### Job & Gang Management

```lua
-- Set job
Player.Functions.SetJob(job, grade)
-- Example: Player.Functions.SetJob('police', '3')

-- Set gang
Player.Functions.SetGang(gang, grade)
-- Example: Player.Functions.SetGang('lemoyne', '1')

-- Toggle duty status
Player.Functions.SetJobDuty(onduty)
-- Example: Player.Functions.SetJobDuty(true)
```

#### XP & Levels

```lua
-- Add XP
Player.Functions.AddXp(skill, amount)
-- Example: Player.Functions.AddXp('mining', 50)

-- Remove XP
Player.Functions.RemoveXp(skill, amount)
-- Example: Player.Functions.RemoveXp('hunting', 25)
```

#### Metadata Management

```lua
-- Set metadata
Player.Functions.SetMetaData(meta, value)
-- Example: Player.Functions.SetMetaData('hunger', 80)

-- Set multiple metadata
Player.Functions.SetMetaData({hunger = 80, thirst = 90})
```

#### Other Functions

```lua
-- Update player data
Player.Functions.UpdatePlayerData()

-- Save player
Player.Functions.Save()
```

---

## 📦 Item System

### Adding Custom Items

Edit `shared/items.lua`:

```lua
-- Developer Note: Add your custom items here
-- Server Owner: Each item needs proper configuration
LXRShared.Items = {
    ['bread'] = {
        ['name'] = 'bread',                     -- Unique item ID (lowercase)
        ['label'] = 'Bread',                    -- Display name
        ['weight'] = 200,                       -- Weight in grams
        ['type'] = 'item',                      -- Type: item, weapon
        ['image'] = 'bread.png',                -- Image filename
        ['unique'] = false,                     -- Unique items stack
        ['useable'] = true,                     -- Can be used
        ['shouldClose'] = true,                 -- Close inventory on use
        ['combinable'] = nil,                   -- Combinable items
        ['description'] = 'A fresh loaf of bread' -- Description
    },
}
```

### Making Items Useable

In your resource `server.lua`:

```lua
-- Developer Example: Create useable bread
exports['lxr-core']:CreateUseableItem('bread', function(source, item)
    local Player = exports['lxr-core']:GetPlayer(source)
    
    if Player then
        -- Remove one bread
        Player.Functions.RemoveItem('bread', 1, item.slot)
        
        -- Restore hunger
        Player.Functions.SetMetaData('hunger', 100)
        
        -- Notify player
        TriggerClientEvent('LXRCore:Notify', source, 9, 'You ate bread and feel full!', 5000)
    end
end)
```

---

## 💼 Job System

### Job Configuration

Edit `shared/jobs.lua`:

```lua
-- Server Owner: Configure your server jobs here
LXRShared.Jobs = {
    ['police'] = {
        label = 'Law Enforcement',
        defaultDuty = true,  -- Start on duty by default
        offDutyPay = false,  -- No pay when off duty
        grades = {
            ['0'] = { name = 'Recruit', payment = 50 },
            ['1'] = { name = 'Deputy', payment = 75 },
            ['2'] = { name = 'Sheriff', payment = 100, isboss = true },
        },
    },
}
```

### Setting Player Job

```lua
-- Server-side
local Player = exports['lxr-core']:GetPlayer(source)
Player.Functions.SetJob('police', '1') -- Set to Deputy
```

### Checking Player Job

```lua
-- Server-side
local Player = exports['lxr-core']:GetPlayer(source)
if Player.PlayerData.job.name == 'police' then
    print('Player is police!')
end
```

---

## 🔫 Gang System

### Gang Configuration

Edit `shared/gangs.lua`:

```lua
-- Server Owner: Configure your server gangs here
LXRShared.Gangs = {
    ['lemoyne'] = {
        label = 'Lemoyne Raiders',
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Raider' },
            ['2'] = { name = 'Leader', isboss = true },
        },
    },
}
```

---

## ⚡ Admin Commands

### Performance Commands

```bash
# View performance metrics
/lxr:performance

# View database cache statistics
/lxr:cachestats
```

### Standard Commands
(Configure in `server/commands.lua`)

---

## 🔧 Troubleshooting

### Server Won't Start

1. **Check database connection**
   ```cfg
   set mysql_connection_string "mysql://user:pass@localhost/db"
   ```

2. **Ensure oxmysql is loaded first**
   ```cfg
   ensure oxmysql
   ensure lxr-core
   ```

3. **Check server console for errors**

### Players Can't Join

1. Check `LXRConfig.ServerClosed` is `false`
2. Verify database is imported correctly
3. Check whitelist/ACE permissions

### Scripts Not Working

1. Check if framework bridge detected:
   ```
   [LXRCore] Detected: vorp_core - Bridge enabled
   ```

2. Verify event names are correct (should start with `LXRCore:`)

3. Check exports are using correct syntax:
   ```lua
   exports['lxr-core']:GetPlayer(source)
   ```

### Performance Issues

1. Run performance report: `/lxr:performance`
2. Check database cache stats: `/lxr:cachestats`
3. Review console for slow function warnings (>100ms)

---

## 📞 Support

Need help? We're here for you:

- 🌐 **Website**: [www.lxrcore.com](https://www.lxrcore.com)
- 🎮 **Test Server**: [The Land of Wolves RP](https://www.wolves.land)
- 💬 **Discord**: [Join our community](https://discord.gg/lxrcore)
- 🐛 **Issues**: [GitHub Issues](https://github.com/LXRCore/lxr-core/issues)

---

<div align="center">

**Made by iBoss • LXRCore - www.lxrcore.com**

**Launched on [The Land of Wolves RP](https://www.wolves.land)**

[⬆ Back to Top](#lxrcore-complete-documentation)

</div>
