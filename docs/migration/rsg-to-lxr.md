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

## Database Migration

> **⚠️ IMPORTANT:** LXRCore uses **normalized SQL columns** instead of JSON blobs. RSG-Core stores `money`, `charinfo`, `job`, `gang`, and `position` as JSON TEXT columns — LXR-Core stores them as individual typed columns (`cash`, `bank`, `firstname`, `lastname`, `job_name`, `pos_x`, etc.). **A database migration is required.**

### Why?
RSG-Core writes a single `INSERT ... ON DUPLICATE KEY UPDATE` with JSON-encoded fields (money, charinfo, job, gang, position, and others) every save cycle. This causes:
- Lock-wait timeouts under load (all players save simultaneously)
- No dirty-flag tracking (every player writes every cycle)
- Index-unfriendly JSON blobs (can't query by `cash > 100` without `JSON_EXTRACT`)

LXR-Core's normalized columns enable staggered batch saves, dirty-flag tracking, and direct SQL indexing.

### Steps

1. **Back up your database** (critical — do not skip):
   ```bash
   mysqldump -u username -p lxrcore > backup_before_lxr_migration.sql
   ```

2. **Run the migration script**:
   ```bash
   mysql -u username -p lxrcore < database/migrate_rsg_to_lxr.sql
   ```

   This script:
   - Adds normalized columns (`cash`, `bank`, `firstname`, `job_name`, `pos_x`, etc.) if they don't already exist
   - Extracts data from the legacy JSON blob columns (`money`, `charinfo`, `job`, `gang`, `position`) using `JSON_EXTRACT`
   - Is **idempotent** — safe to re-run without data loss
   - Reports row counts for each migration phase

3. **Verify the migration**:
   ```sql
   -- Check that money was extracted correctly
   SELECT citizenid, cash, bank, gold FROM players LIMIT 10;

   -- Check character info
   SELECT citizenid, firstname, lastname, birthdate FROM players LIMIT 10;

   -- Check job data
   SELECT citizenid, job_name, job_label, job_grade_level FROM players LIMIT 10;

   -- Check position data
   SELECT citizenid, pos_x, pos_y, pos_z, pos_heading FROM players LIMIT 10;
   ```

4. **(Optional) Drop legacy JSON columns** once verified:
   ```sql
   ALTER TABLE players DROP COLUMN IF EXISTS money;
   ALTER TABLE players DROP COLUMN IF EXISTS charinfo;
   ALTER TABLE players DROP COLUMN IF EXISTS job;
   ALTER TABLE players DROP COLUMN IF EXISTS gang;
   ALTER TABLE players DROP COLUMN IF EXISTS position;
   ```
   These lines are also provided (commented out) at the end of `migrate_rsg_to_lxr.sql`.

---

## Troubleshooting

### "RSGCore is nil" errors
Your resource is still referencing the old core object. Replace all `RSGCore` references with `LXRCore`.

### Events not firing
Check that event names have been updated from `RSGCore:` to `LXRCore:` prefix.

### Database errors after migration
- Verify the migration script completed without errors.
- Check that normalized columns exist: `DESCRIBE players;`
- If columns have default values instead of actual data, the legacy JSON blobs may have been in an unexpected format. Check with:
  ```sql
  SELECT money, charinfo FROM players LIMIT 1;
  ```
  and verify the JSON is valid (`JSON_VALID(money)` should return `1`).

### Lock-wait timeouts (pre-migration)
This is the primary symptom of running RSG-Core's JSON-blob save pattern. The migration to LXR-Core's normalized columns and staggered saves resolves this.

---

## Need Help?

- **Discord:** https://discord.gg/CrKcWdfd3A
- **GitHub Issues:** https://github.com/LXRCore/lxr-core/issues
