# Migration Guide: RSG-Core → LXRCore

This guide helps you migrate resources and server configurations from RSG-Core to LXRCore.

---

## Overview

LXRCore shares a similar API structure with RSG-Core, making migration straightforward for most resources. The primary differences are in naming conventions and some function signatures.

---

## API Mapping

### Getting the Core Object

```lua
-- RSG-Core
local RSGCore = exports['rsg-core']:GetCoreObject()

-- LXRCore
local LXRCore = exports['lxr-core']:GetCoreObject()
```

### Player Functions

```lua
-- RSG-Core
local Player = RSGCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 100, 'reason')
Player.Functions.RemoveMoney('cash', 50, 'reason')
Player.PlayerData.citizenid

-- LXRCore
local Player = LXRCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 100, 'reason')
Player.Functions.RemoveMoney('cash', 50, 'reason')
Player.PlayerData.citizenid
```

### Server Callbacks

```lua
-- RSG-Core
RSGCore.Functions.CreateCallback('callbackName', function(source, cb, ...)
    cb(result)
end)

-- LXRCore
LXRCore.Functions.CreateCallback('callbackName', function(source, cb, ...)
    cb(result)
end)
```

### Client Callbacks

```lua
-- RSG-Core (client)
RSGCore.Functions.TriggerCallback('callbackName', function(result)
    -- handle result
end, arg1, arg2)

-- LXRCore (client)
LXRCore.Functions.TriggerCallback('callbackName', function(result)
    -- handle result
end, arg1, arg2)
```

### Notifications

```lua
-- RSG-Core
TriggerClientEvent('RSGCore:Notify', source, 'Message', 'success')

-- LXRCore
TriggerClientEvent('LXRCore:Notify', source, 'Message', 'success')
```

### Events

| RSG-Core Event | LXRCore Event |
|----------------|---------------|
| `RSGCore:Client:OnPlayerLoaded` | `LXRCore:Client:OnPlayerLoaded` |
| `RSGCore:Server:OnPlayerLoaded` | `LXRCore:Server:OnPlayerLoaded` |
| `RSGCore:Server:PlayerDropped` | `LXRCore:Server:PlayerDropped` |
| `RSGCore:Client:OnPlayerUnload` | `LXRCore:Client:OnPlayerUnload` |

---

## Step-by-Step Migration

### 1. Replace Core Object References

Find and replace in your resource files:

| Find | Replace |
|------|---------|
| `rsg-core` | `lxr-core` |
| `RSGCore` | `LXRCore` |
| `RSGCore:` (in events) | `LXRCore:` |

### 2. Update fxmanifest.lua

```lua
-- Before
dependencies { 'rsg-core' }

-- After
dependencies { 'lxr-core' }
```

### 3. Update server.cfg

```cfg
# Before
ensure rsg-core

# After
ensure lxr-core
```

### 4. Test Each System

After migration, test these systems in order:

1. Player loading and character creation
2. Money operations (add, remove, set)
3. Inventory operations
4. Job assignment and management
5. Server callbacks
6. Notifications

---

## Known Differences

| Feature | RSG-Core | LXRCore | Notes |
|---------|----------|---------|-------|
| Core object | `RSGCore` | `LXRCore` | Direct rename |
| Event prefix | `RSGCore:` | `LXRCore:` | Direct rename |
| Export resource | `rsg-core` | `lxr-core` | Direct rename |
| Currency types | Standard | Extended (15+) | LXR has more currency types |
| Framework bridge | No | Yes | LXR can detect and bridge with RSG |
| Anti-cheat | Basic | Integrated | LXR has built-in anti-cheat |

---

## Using the Bridge (Alternative)

Instead of full migration, you can use LXRCore's framework bridge to run RSG-Core resources alongside LXRCore:

```lua
-- In config.lua, set framework detection
LXRConfig.Framework = {
    primary = 'lxr-core',
    fallback = 'rsg-core',
    autoDetect = true
}
```

The bridge system will automatically translate API calls between frameworks. See [frameworks.md](../frameworks.md) for details.

---

## Troubleshooting

### "RSGCore is nil" errors
Your resource is still referencing the old core object. Replace all `RSGCore` references with `LXRCore`.

### Events not firing
Check that event names have been updated from `RSGCore:` to `LXRCore:` prefix.

### Database errors
LXRCore uses the same database schema as RSG-Core for player data. No database migration should be needed for basic player tables.

---

## Need Help?

- **Discord:** https://discord.gg/CrKcWdfd3A
- **GitHub Issues:** https://github.com/LXRCore/lxr-core/issues
