# 🐺 LXR-CORE — Migration Guides

Every path below: **back up first**, run the pre-flight `SELECT`s, then the
script, then the post-check. Nothing in these scripts deletes data.

## Old LXRCore (v1 / v2) → v3

Drop-in for the database. Start v3 once; boot adds the missing `players`
columns and creates `lxr_ledger` / `lxr_migrations`. Then:

| v2 thing | v3 replacement |
|---|---|
| `LXRConfig.*` | `Config.*` (alias kept) |
| `exports['lxr-core']:GetPlayer(src)` | unchanged |
| `LXRCore:Server:AddItem/RemoveItem` from the client | `Player.Functions.AddItem/RemoveItem` on the server |
| `LXRCore:Player:GiveXp/RemoveXp` from the client | `Player.Functions.AddXp/RemoveXp` or `exports['lxr-core']:AddXp(src, skill, n)` |
| `server/anticheat.lua`, `antidupe.lua`, `tebex.lua` | separate resources (`lxr-anticheat`, …) |
| `logs`, `anticheat_logs`, `tebex_*`, `query_cache`, `webhook_queue`, … tables | archive and drop |

## RSG-Core → LXRCore

`database/migrate/rsg_to_lxr.sql`. RSG and LXRCore share the `players` /
`bans` layout; the script adds missing columns and the ledger tables. Other RSG
tables (`playerskins`, `player_horses`, `inventories`, …) are untouched and
keep working with their RSG resources through the adapter.

Server config: keep `add_principal … rsgcore.admin` lines — they inherit
`lxrcore.admin`. Replace `ensure rsg-core` with `ensure lxr-core` and, if you
still run RSG resources, add `ensure rsg-core` pointing at
`bridges/rsg-core`.

## VORP → LXRCore

`database/migrate/vorp_to_lxr.sql` converts `characters` into `players`
(one row per VORP character, citizen id `VORP000123`). Because VORP keys by
steam id, imported rows carry the steam id in `players.license`; the core
re-links them to the real Rockstar license on the player's first login
(`Config.Database.relinkImportedRows`). Multicharacter lists them by steam id
until then.

Items are **not** converted by the SQL script (VORP stores one row per stack
in `character_inventories` with item ids from `items`). Convert them with a
one-off Lua pass after the import, using the core provider:

```lua
-- run once from a temporary server resource, then remove it
LXRCore.DB.OnReady(function()
    local rows = LXRCore.DB.Query([[SELECT ci.character_id, i.item AS name, ci.amount
        FROM character_inventories ci JOIN items i ON i.id = ci.item_crafted_id
        WHERE ci.inventory_type = 'default']])
    for _, r in ipairs(rows or {}) do
        local off = LXRCore.Player.GetOfflinePlayer(('VORP%06d'):format(r.character_id))
        if off and LXRShared.Items[r.name] then
            off.Functions.AddItem(r.name, r.amount)
            off.Functions.Save()
        end
    end
end)
```
Item names must exist in `shared/items.lua` (`LXRShared.Items`); unknown names
are skipped and should be added first.

Not migrated: skins/comps (kept in `metadata.vorp` for an appearance resource
to pick up), weapons/ammo, multijobs, VORP groups (map to ACE principals in
`server.cfg`).

## QBR → LXRCore

Identical schema; run `database/migrate/rsg_to_lxr.sql` (same column set).
QBR resources keep working through `bridges/qbr-core`.

## Rollback

All scripts are additive. To roll back, restore the backup taken before the
migration; `lxr_ledger` / `lxr_migrations` can simply be dropped.
