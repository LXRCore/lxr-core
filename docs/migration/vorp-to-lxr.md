# Migration Guide: VORP → LXRCore

This guide helps you migrate resources and server configurations from VORP Core to LXRCore.

---

## Overview

VORP Core and LXRCore have different API structures. Migration requires more changes than RSG-Core migration because the frameworks use different patterns for player management, inventory, and events.

---

## API Mapping

### Getting the Core Object

```lua
-- VORP
local VORPcore = exports.vorp_core:GetCore()

-- LXRCore
local LXRCore = exports['lxr-core']:GetCoreObject()
```

### Player Functions

```lua
-- VORP
local user = VORPcore.getUser(source)
local character = user.getUsedCharacter

character.addCurrency(0, 100)   -- cash
character.addCurrency(1, 100)   -- gold
character.removeCurrency(0, 50) -- cash

-- LXRCore
local Player = LXRCore.Functions.GetPlayer(source)

Player.Functions.AddMoney('cash', 100, 'reason')
Player.Functions.AddMoney('gold', 100, 'reason')
Player.Functions.RemoveMoney('cash', 50, 'reason')
```

### Inventory

```lua
-- VORP (uses vorp_inventory exports)
exports.vorp_inventory:addItem(source, 'item_name', 1)
exports.vorp_inventory:getItemCount(source, 'item_name')
exports.vorp_inventory:subItem(source, 'item_name', 1)

-- LXRCore (uses core or lxr-inventory)
Player.Functions.AddItem('item_name', 1)
Player.Functions.GetItemByName('item_name')
Player.Functions.RemoveItem('item_name', 1)
```

### Callbacks

```lua
-- VORP (typically uses custom callback systems or direct events)
TriggerServerEvent('vorp:action', data)

-- LXRCore
LXRCore.Functions.TriggerCallback('lxr-core:server:action', function(result)
    -- handle result
end, data)
```

### Notifications

```lua
-- VORP
TriggerEvent('vorp:TipBottom', 'Message', 5000)
-- or
VORPcore.NotifyRightTip(source, 'Message', 5000)

-- LXRCore
TriggerEvent('LXRCore:Notify', 'Message', 'success', 5000)
```

---

## Currency Mapping

| VORP Currency ID | LXRCore Currency Name | Description |
|-----------------|----------------------|-------------|
| 0 | `cash` | Dollar/Cash |
| 1 | `gold` | Gold bars |
| 2 | `rol` | Role tokens |
| - | `bank` | Bank balance (LXR-specific) |
| - | `coins` | Coins (LXR-specific) |

---

## Event Mapping

| VORP Event | LXRCore Event |
|------------|---------------|
| `vorp:SelectedCharacter` | `LXRCore:Client:OnPlayerLoaded` |
| `vorp:playerSpawn` | `LXRCore:Client:OnPlayerLoaded` |
| Player disconnect (custom) | `LXRCore:Server:PlayerDropped` |

---

## Step-by-Step Migration

### 1. Replace Core Object References

This is NOT a simple find-and-replace like RSG-Core. You need to:

1. Replace `VORPcore.getUser(source)` calls with `LXRCore.Functions.GetPlayer(source)`
2. Replace `.getUsedCharacter` chain with direct Player object usage
3. Replace `.addCurrency(id, amount)` with `.AddMoney(name, amount, reason)`
4. Replace VORP inventory exports with LXRCore player functions

### 2. Update fxmanifest.lua

```lua
-- Before
dependencies { 'vorp_core' }

-- After
dependencies { 'lxr-core' }
```

### 3. Update server.cfg

```cfg
# Before
ensure vorp_core

# After
ensure oxmysql
ensure lxr-core
```

### 4. Database Migration

VORP and LXRCore use different database schemas. You will need to:

1. Export player data from VORP tables
2. Transform data to match LXRCore schema
3. Import into LXRCore tables

> **Note:** Automated migration scripts are planned but not yet available. Manual data migration is required.

### 5. Test Each System

After migration, test these systems in order:

1. Player loading and character selection
2. Money operations (cash, gold, bank)
3. Inventory operations (add, remove, check)
4. Job assignment
5. Notifications
6. Custom events

---

## Known Differences

| Feature | VORP | LXRCore | Notes |
|---------|------|---------|-------|
| Core access | `exports.vorp_core:GetCore()` | `exports['lxr-core']:GetCoreObject()` | Different pattern |
| Player object | `user.getUsedCharacter` | `Player.PlayerData` / `Player.Functions` | Different structure |
| Currency | Numeric IDs (0, 1, 2) | Named strings ('cash', 'gold') | Need to map |
| Inventory | Separate resource (vorp_inventory) | Built-in or lxr-inventory | Different system |
| Callbacks | Custom/event-based | `CreateCallback` / `TriggerCallback` | Different pattern |
| Database | Custom schema | QBCore-based schema | Migration needed |

---

## Using the Bridge (Alternative)

LXRCore includes a framework bridge that can translate some VORP API calls. However, due to the significant API differences, full bridge compatibility is limited.

```lua
-- The bridge provides partial compatibility
-- Check docs/frameworks.md for supported bridge functions
LXRConfig.Framework = {
    primary = 'lxr-core',
    fallback = 'vorp_core',
    autoDetect = true
}
```

> **Important:** The VORP bridge covers basic player and money operations but may not support all VORP-specific features. Full resource rewrite is recommended for complex resources.

---

## Troubleshooting

### "VORPcore is nil" errors
Your resource still references the old core. Replace all VORP API calls with LXRCore equivalents.

### Currency amounts not transferring
VORP uses numeric currency IDs while LXRCore uses string names. Ensure you map correctly (0 → 'cash', 1 → 'gold').

### Inventory not working
If using VORP inventory, you need to switch to lxr-inventory or use the built-in inventory functions on the Player object.

---

## Need Help?

- **Discord:** https://discord.gg/CrKcWdfd3A
- **GitHub Issues:** https://github.com/LXRCore/lxr-core/issues
