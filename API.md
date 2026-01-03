# LXRCore API Reference

<div align="center">

![LXRCore API](https://via.placeholder.com/600x100/1a1a2e/00d4ff?text=LXRCore+API+Reference)

**Complete Developer API Documentation**

[🏠 Home](README.md) • [📚 Documentation](DOCUMENTATION.md) • [⚡ Performance](PERFORMANCE.md) • [🔒 Security](SECURITY.md)

**Made by iBoss • LXRCore - www.lxrcore.com**

</div>

---

## 📋 Table of Contents

1. [Server Exports](#server-exports)
2. [Client Exports](#client-exports)
3. [Server Events](#server-events)
4. [Client Events](#client-events)
5. [Player Functions](#player-functions)
6. [Bridge System](#bridge-system)
7. [Security Functions](#security-functions)
8. [Performance Functions](#performance-functions)
9. [Database Functions](#database-functions)

---

## 🖥️ Server Exports

### Player Management

#### `GetPlayer(source)`
Get player object by server ID.

```lua
-- Usage
local Player = exports['lxr-core']:GetPlayer(source)

-- Returns
Player = {
    PlayerData = {...},
    Functions = {...}
}
```

#### `GetPlayers()`
Get all online player sources.

```lua
-- Usage
local players = exports['lxr-core']:GetPlayers()

-- Returns
players = {1, 2, 3, 4, ...} -- Array of source IDs
```

#### `GetLXRPlayers()`
Get complete player objects table.

```lua
-- Usage
local allPlayers = exports['lxr-core']:GetLXRPlayers()

-- Returns
allPlayers = {
    [1] = PlayerObject,
    [2] = PlayerObject,
    ...
}
```

#### `GetPlayerByCitizenId(citizenid)`
Get player by unique citizen ID.

```lua
-- Usage
local Player = exports['lxr-core']:GetPlayerByCitizenId('ABC12345')

-- Parameters
-- citizenid: string - Citizen ID (e.g., 'ABC12345')

-- Returns
Player or nil
```

#### `GetIdentifier(source, idtype)`
Get player identifier by type.

```lua
-- Usage
local license = exports['lxr-core']:GetIdentifier(source, 'license')

-- Parameters
-- source: number - Player server ID
-- idtype: string - Type: 'license', 'discord', 'steam', 'xbl', 'live', 'ip'

-- Returns
string - Identifier or nil
```

---

### Job Management

#### `GetPlayersOnDuty(job)`
Get all on-duty players for a job.

```lua
-- Usage
local players, count = exports['lxr-core']:GetPlayersOnDuty('police')

-- Parameters
-- job: string - Job name

-- Returns
players: table - Array of source IDs
count: number - Count of on-duty players
```

#### `GetDutyCount(job)`
Get count of on-duty players only.

```lua
-- Usage
local count = exports['lxr-core']:GetDutyCount('police')

-- Parameters
-- job: string - Job name

-- Returns
number - Count of on-duty players
```

---

### Callback System

#### `CreateCallback(name, cb)`
Register a server callback.

```lua
-- Usage
exports['lxr-core']:CreateCallback('myResource:getData', function(source, cb, arg1, arg2)
    -- Process callback
    local result = ProcessData(arg1, arg2)
    cb(result)
end)

-- Parameters
-- name: string - Unique callback name
-- cb: function - Callback handler function
```

#### `TriggerCallback(name, source, cb, ...)`
Trigger a registered callback.

```lua
-- Usage
exports['lxr-core']:TriggerCallback('myResource:getData', source, function(result)
    print(result)
end, arg1, arg2)

-- Parameters
-- name: string - Callback name
-- source: number - Player source
-- cb: function - Response handler
-- ...: any - Additional arguments
```

---

### Item System

#### `CreateUseableItem(item, cb)`
Make an item useable.

```lua
-- Usage
exports['lxr-core']:CreateUseableItem('bread', function(source, item)
    local Player = exports['lxr-core']:GetPlayer(source)
    -- Item logic here
    Player.Functions.RemoveItem('bread', 1, item.slot)
end)

-- Parameters
-- item: string - Item name
-- cb: function - Use handler function
```

#### `CanUseItem(item)`
Check if item can be used.

```lua
-- Usage
local canUse = exports['lxr-core']:CanUseItem('bread')

-- Parameters
-- item: string - Item name

-- Returns
boolean
```

#### `UseItem(source, item)`
Use an item.

```lua
-- Usage
exports['lxr-core']:UseItem(source, itemData)

-- Parameters
-- source: number - Player source
-- item: table - Item data object
```

---

### Permission System

#### `HasPermission(source, permission)`
Check if player has permission.

```lua
-- Usage
local hasAdmin = exports['lxr-core']:HasPermission(source, 'admin')

-- Parameters
-- source: number - Player source
-- permission: string - Permission name ('god', 'admin', 'mod')

-- Returns
boolean
```

#### `GetPermissions(source)`
Get all player permissions.

```lua
-- Usage
local perms = exports['lxr-core']:GetPermissions(source)

-- Returns
perms = {
    ['admin'] = true,
    ['mod'] = true
}
```

#### `AddPermission(source, permission)`
Add permission to player.

```lua
-- Usage
exports['lxr-core']:AddPermission(source, 'admin')

-- Parameters
-- source: number - Player source
-- permission: string - Permission to add
```

#### `RemovePermission(source, permission)`
Remove permission from player.

```lua
-- Usage
exports['lxr-core']:RemovePermission(source, 'admin')

-- Parameters
-- source: number - Player source
-- permission: string - Permission to remove (nil to remove all)
```

---

### Shared Exports

#### `GetConfig()`
Get framework configuration.

```lua
-- Usage
local config = exports['lxr-core']:GetConfig()

-- Returns
LXRConfig table
```

#### `GetJobs()`
Get all jobs configuration.

```lua
-- Usage
local jobs = exports['lxr-core']:GetJobs()

-- Returns
LXRShared.Jobs table
```

#### `GetGangs()`
Get all gangs configuration.

```lua
-- Usage
local gangs = exports['lxr-core']:GetGangs()

-- Returns
LXRShared.Gangs table
```

#### `GetItems()`
Get all items configuration.

```lua
-- Usage
local items = exports['lxr-core']:GetItems()

-- Returns
LXRShared.Items table
```

#### `GetItem(item)`
Get specific item configuration.

```lua
-- Usage
local itemData = exports['lxr-core']:GetItem('bread')

-- Parameters
-- item: string - Item name

-- Returns
Item configuration table or nil
```

---

## 💻 Client Exports

### Player Data

#### `GetPlayerData(cb)`
Get client player data.

```lua
-- Usage with callback
exports['lxr-core']:GetPlayerData(function(PlayerData)
    print(PlayerData.job.name)
end)

-- Usage without callback
local PlayerData = exports['lxr-core']:GetPlayerData()
```

#### `GetCoords(entity)`
Get entity coordinates with heading.

```lua
-- Usage
local coords = exports['lxr-core']:GetCoords(PlayerPedId())

-- Returns
vector4(x, y, z, heading)
```

#### `HasItem(item)`
Check if player has item (async).

```lua
-- Usage
local hasItem = exports['lxr-core']:HasItem('bread')

-- Parameters
-- item: string - Item name

-- Returns
boolean (Promise-based)
```

---

### Model & Entity Management

#### `LoadModel(model)`
Load model for spawning.

```lua
-- Usage
exports['lxr-core']:LoadModel('a_c_horse_morgan')

-- Parameters
-- model: string or hash - Model name or hash
```

#### `SpawnPed(name, model, x, y, z, w)`
Spawn and register a ped.

```lua
-- Usage
exports['lxr-core']:SpawnPed('shopkeeper', 'a_m_m_sdcowboy_01', x, y, z, heading)

-- Parameters
-- name: string - Unique ped identifier
-- model: string/hash - Ped model
-- x, y, z: number - Coordinates
-- w: number - Heading
```

#### `RemovePed(name)`
Remove registered ped.

```lua
-- Usage
exports['lxr-core']:RemovePed('shopkeeper')

-- Parameters
-- name: string - Ped identifier
```

---

### Performance Utilities

#### `GetEntityPool(poolName)`
Get cached entity pool (optimized).

```lua
-- Usage
local peds = exports['lxr-core']:GetEntityPool('CPed')

-- Parameters
-- poolName: string - 'CPed', 'CVehicle', or 'CObject'

-- Returns
table - Array of entity handles
```

#### `GetDistance(coords1, coords2)`
Calculate distance with caching.

```lua
-- Usage
local distance = exports['lxr-core']:GetDistance(coordsA, coordsB)

-- Parameters
-- coords1, coords2: vector3 - Coordinates

-- Returns
number - Distance
```

#### `GetClosestEntity(entityPool, coords, maxDistance)`
Find closest entity efficiently.

```lua
-- Usage
local entity, distance = exports['lxr-core']:GetClosestEntity('CPed', coords, 10.0)

-- Parameters
-- entityPool: string - Pool name
-- coords: vector3 - Search coordinates (optional, uses player if nil)
-- maxDistance: number - Maximum search distance (optional, default 10.0)

-- Returns
entity: number - Entity handle or nil
distance: number - Distance to entity
```

#### `Debounce(functionName, func, delay)`
Create debounced function.

```lua
-- Usage
local debouncedFunc = exports['lxr-core']:Debounce('myFunc', function()
    -- This only runs after 500ms of no calls
    print('Executed!')
end, 500)

-- Parameters
-- functionName: string - Unique identifier
-- func: function - Function to debounce
-- delay: number - Delay in ms (default 500)
```

#### `Throttle(functionName, func, interval)`
Create throttled function.

```lua
-- Usage
local throttledFunc = exports['lxr-core']:Throttle('myFunc', function()
    -- This runs at most once per second
    print('Executed!')
end, 1000)

-- Parameters
-- functionName: string - Unique identifier
-- func: function - Function to throttle
-- interval: number - Interval in ms (default 1000)
```

---

## 📡 Server Events

### Player Lifecycle

```lua
-- Player loaded and ready
RegisterNetEvent('LXRCore:Server:OnPlayerLoaded')

-- Player disconnected
RegisterNetEvent('LXRCore:Server:OnPlayerUnload')

-- Player data update requested
RegisterNetEvent('LXRCore:UpdatePlayer')
```

### Player Actions

```lua
-- Set player metadata
RegisterNetEvent('LXRCore:Server:SetMetaData')
AddEventHandler('LXRCore:Server:SetMetaData', function(meta, value)
    -- meta: string or table
    -- value: any (if meta is string)
end)

-- Toggle duty status
RegisterNetEvent('LXRCore:ToggleDuty')
```

### Item Management

```lua
-- Use item
RegisterNetEvent('LXRCore:Server:UseItem')
AddEventHandler('LXRCore:Server:UseItem', function(item)
    -- item: table - Item data
end)

-- Add item
RegisterNetEvent('LXRCore:Server:AddItem')
AddEventHandler('LXRCore:Server:AddItem', function(itemName, amount, slot, info)
    -- itemName: string
    -- amount: number
    -- slot: number (optional)
    -- info: table (optional)
end)

-- Remove item
RegisterNetEvent('LXRCore:Server:RemoveItem')
AddEventHandler('LXRCore:Server:RemoveItem', function(itemName, amount, slot)
    -- itemName: string
    -- amount: number
    -- slot: number (optional)
end)
```

### XP System

```lua
-- Give XP
RegisterNetEvent('LXRCore:Player:GiveXp')
AddEventHandler('LXRCore:Player:GiveXp', function(source, skill, amount)
    -- skill: string - Skill name
    -- amount: number - XP amount
end)

-- Remove XP
RegisterNetEvent('LXRCore:Player:RemoveXp')
AddEventHandler('LXRCore:Player:RemoveXp', function(source, skill, amount)
    -- skill: string - Skill name
    -- amount: number - XP amount
end)

-- Set level
RegisterNetEvent('LXRCore:Player:SetLevel')
AddEventHandler('LXRCore:Player:SetLevel', function(source, skill)
    -- skill: string - Skill name
end)
```

### Callback System

```lua
-- Trigger callback
RegisterNetEvent('LXRCore:Server:TriggerCallback')
AddEventHandler('LXRCore:Server:TriggerCallback', function(name, ...)
    -- name: string - Callback name
    -- ...: any - Arguments
end)
```

---

## 📱 Client Events

### Player Lifecycle

```lua
-- Player loaded client-side
RegisterNetEvent('LXRCore:Client:OnPlayerLoaded')

-- Player unloaded client-side
RegisterNetEvent('LXRCore:Client:OnPlayerUnload')

-- Duty status changed
RegisterNetEvent('LXRCore:Client:SetDuty')
AddEventHandler('LXRCore:Client:SetDuty', function(onDuty)
    -- onDuty: boolean
end)
```

### Player Data

```lua
-- Player data updated
RegisterNetEvent('LXRCore:Player:SetPlayerData')
AddEventHandler('LXRCore:Player:SetPlayerData', function(PlayerData)
    -- PlayerData: table - Complete player data
end)
```

### Notifications

```lua
-- Show notification
RegisterNetEvent('LXRCore:Notify')
AddEventHandler('LXRCore:Notify', function(type, message, duration, x, texture, icon, color)
    -- type: number - Notification type
    -- message: string - Message text
    -- duration: number - Display time in ms
    -- x: number - X position
    -- texture: string - Texture dictionary
    -- icon: string - Icon name
    -- color: string - Color name
end)
```

### Teleportation

```lua
-- Teleport to player
RegisterNetEvent('LXRCore:Command:TeleportToPlayer')
AddEventHandler('LXRCore:Command:TeleportToPlayer', function(coords)
    -- coords: vector4
end)

-- Teleport to coordinates
RegisterNetEvent('LXRCore:Command:TeleportToCoords')
AddEventHandler('LXRCore:Command:TeleportToCoords', function(x, y, z)
    -- x, y, z: number
end)

-- Teleport to waypoint
RegisterNetEvent('LXRCore:Command:GoToMarker')
```

### Callback Responses

```lua
-- Callback response
RegisterNetEvent('LXRCore:Client:TriggerCallback')
AddEventHandler('LXRCore:Client:TriggerCallback', function(name, ...)
    -- name: string - Callback name
    -- ...: any - Response data
end)
```

---

## 👤 Player Functions

### Money Management

```lua
Player.Functions.AddMoney(moneytype, amount, reason)
Player.Functions.RemoveMoney(moneytype, amount, reason)
Player.Functions.SetMoney(moneytype, amount, reason)
Player.Functions.GetMoney(moneytype)

-- Example
Player.Functions.AddMoney('cash', 100, 'Quest reward')
```

### Item Management

```lua
Player.Functions.AddItem(itemname, amount, slot, info)
Player.Functions.RemoveItem(itemname, amount, slot)
Player.Functions.ClearInventory(slots)

-- Example
Player.Functions.AddItem('bread', 5, false, {quality = 100})
```

### Job & Gang

```lua
Player.Functions.SetJob(job, grade)
Player.Functions.SetGang(gang, grade)
Player.Functions.SetJobDuty(onduty)

-- Example
Player.Functions.SetJob('police', '2')
```

### XP & Levels

```lua
Player.Functions.AddXp(skill, amount)
Player.Functions.RemoveXp(skill, amount)

-- Example
Player.Functions.AddXp('mining', 50)
```

### Metadata

```lua
Player.Functions.SetMetaData(meta, value)
Player.Functions.SetMetaData(metaTable)

-- Examples
Player.Functions.SetMetaData('hunger', 80)
Player.Functions.SetMetaData({hunger = 80, thirst = 90})
```

### Data Management

```lua
Player.Functions.UpdatePlayerData()
Player.Functions.Save()

-- Example
Player.Functions.Save() -- Save player to database
```

---

## 🌉 Bridge System

### Framework Detection

```lua
-- Check if framework is active
local isVORP = exports['lxr-core']:IsFrameworkActive('vorp')

-- Parameters
-- frameworkName: string - 'vorp', 'rsg', 'redmrp', 'qbr'

-- Returns
boolean
```

### Player Translation

```lua
-- Translate player object to another framework format
local vorpPlayer = exports['lxr-core']:TranslatePlayerObject(source, 'vorp')

-- Parameters
-- source: number - Player source
-- targetFramework: string - Target framework name

-- Returns
Translated player object
```

---

## 🔒 Security Functions

### Validation

```lua
-- Validate source
local isValid = exports['lxr-core']:ValidateSource(source)

-- Validate input type
local isValid = exports['lxr-core']:ValidateInput(input, 'string')

-- Validate citizen ID
local isValid = exports['lxr-core']:ValidateCitizenId(citizenid)

-- Validate item data
local isValid = exports['lxr-core']:ValidateItemData(itemName, amount, slot)

-- Validate money transaction
local isValid = exports['lxr-core']:ValidateMoneyTransaction(moneyType, amount)
```

### Rate Limiting

```lua
-- Check rate limit
local allowed = exports['lxr-core']:CheckRateLimit(source, 'eventName', 10)

-- Parameters
-- source: number - Player source
-- eventName: string - Event identifier
-- customLimit: number - Optional custom limit (default 10)

-- Returns
boolean - True if allowed, false if rate limited
```

### Activity Monitoring

```lua
-- Check suspicious activity
local isOK = exports['lxr-core']:CheckSuspiciousActivity(source, 'rapidMoney', 50000)

-- Parameters
-- source: number - Player source
-- activityType: string - 'rapidMoney' or 'rapidItems'
-- data: number - Amount being added

-- Returns
boolean - True if OK, false if suspicious
```

---

## ⚡ Performance Functions

### Metrics

```lua
-- Track function performance
local trackedFunc = exports['lxr-core']:TrackFunction('myFunction', function()
    -- Your function code
end)

-- Track event trigger
exports['lxr-core']:TrackEvent('eventName')

-- Track database query
exports['lxr-core']:TrackDBQuery('queryType', duration)
```

### Reports

```lua
-- Get current metrics
local metrics = exports['lxr-core']:GetMetrics()

-- Generate performance report
local report = exports['lxr-core']:GenerateReport()

-- Reset metrics
exports['lxr-core']:ResetMetrics()
```

---

## 💾 Database Functions

### Cached Queries

```lua
-- Fetch with cache
local result = exports['lxr-core']:FetchCached(query, params, useCache)

-- Fetch single with cache
local result = exports['lxr-core']:FetchSingleCached(query, params, useCache)

-- Example
local player = exports['lxr-core']:FetchSingleCached(
    'SELECT * FROM players WHERE citizenid = ?',
    {citizenid},
    true
)
```

### Cache Management

```lua
-- Clear cache
local cleared = exports['lxr-core']:ClearCache('players') -- Pattern
local cleared = exports['lxr-core']:ClearCache() -- All

-- Get cache statistics
local stats = exports['lxr-core']:GetCacheStats()

-- Enable/disable cache
exports['lxr-core']:SetCacheEnabled(true)
```

### Batch Operations

```lua
-- Batch insert
exports['lxr-core']:BatchInsert(
    'players',
    {'name', 'citizenid', 'money'},
    {
        {'John', 'ABC123', 100},
        {'Jane', 'XYZ789', 200}
    }
)
```

---

<div align="center">

**Made by iBoss • LXRCore - www.lxrcore.com**

**Launched on [The Land of Wolves RP](https://www.wolves.land)**

[⬆ Back to Top](#lxrcore-api-reference)

</div>
