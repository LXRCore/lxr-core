<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# LXR-CORE — Installation

## Requirements

| Requirement | Version | Why |
|---|---|---|
| FXServer (RedM) | build 7290 or newer | declared in `fxmanifest.lua` |
| OneSync | on (infinity) | state bags, routing buckets, server-side entities |
| oxmysql | current release | database access (`@oxmysql/lib/MySQL.lua`) |
| MariaDB 10.6+ / MySQL 8 | | `JSON_*` functions used by the migration scripts |

Optional: `ox_lib` (only if RSG resources you run need it), `progressbar`
(client progress bars), an inventory resource (`lxr-inventory`, `rsg-inventory`
or `vorp_inventory` — without one the core provider keeps items headless).

## Fresh install (txAdmin recipe)

Use the LXRCore recipe (`txAdminRecipe` repository). It downloads this
resource, oxmysql and the official resources, imports `database/schema.sql`,
places `server.cfg` and orders the `ensure` lines correctly.

## Manual install

1. `resources/[framework]/lxr-core` ← this repository (folder name must be `lxr-core`).
2. `resources/[standalone]/oxmysql` ← oxmysql release zip.
3. Database: nothing to import by hand — the core applies
   `database/migrations/*.sql` at first start (`Config.Database.autoMigrate`).
   For a manual import use `database/schema.sql`.
4. `server.cfg`:

```cfg
set onesync on
set mysql_connection_string "mysql://user:pass@127.0.0.1/lxrcore?charset=utf8mb4"

ensure oxmysql
ensure lxr-core
# optional bridges (only when the real resource is NOT installed)
# ensure rsg-core
# ensure vorp_core
# ensure qbr-core
# ensure vorp_inventory

# permissions
add_principal identifier.license:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX lxrcore.god
```

5. Start the server. The console shows the LXRCore banner followed by
   `ready in <n>ms`. Before that line no player can load a character.

## Start order

```
oxmysql → lxr-core → lxr-nui → lxr-mapcolor → lxr-interact → lxr-inventory → lxr-clothing → lxr-creator → lxr-barber → the rest (txAdminRecipe/docs/BOOT-ORDER.md)
```
`lxr-core` re-detects the inventory provider when an inventory resource starts
later, so a wrong order degrades to the core provider instead of failing.

## Upgrading from lxr-core v1 / v2

* Replace the folder; keep your database. Missing `players` columns
  (`weight`, `slots`, `outlawstatus`, `created_at`) are added at boot.
* Move your `LXRConfig` values into `config.lua` sections (`LXRConfig` still
  aliases `Config`, so old references keep resolving).
* The v2 `logs`, `anticheat_logs`, `tebex_*`, `query_cache`, … tables are not
  used any more and can be dropped after you archive them.
* Resources that triggered `LXRCore:Server:AddItem` / `LXRCore:Player:GiveXp`
  from the client must move that logic server-side (those events are now
  rejected and logged).

## Verifying an install

* `/lxr:metrics` (admin) prints counters and DB timings.
* `LXRCore:Server:Ready` fires once boot is done; `GlobalState.LXRCoreReady == true`.
* `exports['lxr-core']:IsReady()` / `IsDatabaseReady()` from any resource.
