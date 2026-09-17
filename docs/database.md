<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# LXR-CORE — Database

## Tables owned by lxr-core

| Table | Purpose | Migration |
|---|---|---|
| `players` | one row per character; RSG/QBR-compatible columns (`citizenid` PK, `license`, JSON text columns, `inventory`, `weight`, `slots`, `outlawstatus`) | `0001_core_schema` |
| `bans` | license / discord / ip bans with unix `expire` (`2147483647` = permanent) | `0001_core_schema` |
| `lxr_ledger` | every account mutation (`add`, `remove`, `set`, `transfer_in/out`) with balance after, reason, resource, counterparty | `0002_ledger` |
| `lxr_migrations` | applied migration names + checksums | created by the runner |

No other tables are created. Resources own their tables and register them:

```lua
LXRCore.DB.RegisterMigration('lxr-stables', '0001_horses', [[
CREATE TABLE IF NOT EXISTS player_horses (...);
]])
LXRCore.Player.RegisterCharacterTable('player_horses')   -- deleted with the character
```

## Migration runner

* Files: `database/migrations/NNNN_name.sql`, listed in `server/database.lua` (`CORE_MIGRATIONS`).
* Each file is split into statements (comments and quoted `;` handled), executed in order, then recorded with an FNV-1a checksum.
* Already applied → skipped. Applied but file changed → warning, never re-run. Failure → boot halts and no player can connect (`Config.Database.requireReady`).
* External migrations registered before boot run after the core ones; registered later run immediately.
* Only write **idempotent** statements (`CREATE TABLE IF NOT EXISTS`, conditional column checks through `LXRCore.DB.ColumnExists`). Never `DROP` / `TRUNCATE` in a migration.

## Save pipeline

* `players` is written with one `INSERT … ON DUPLICATE KEY UPDATE` per character.
* Periodic saves (`Config.General.saveInterval`) only touch players flagged `_dirty` and are spread in batches (`Config.Performance.saveBatch*`).
* Logout, character switch, drop and resource stop save **synchronously**.
* Position is read from the ped at save time; inventory is delegated to the active provider (`players.inventory` for the core provider).

## JSON column shapes

```
money     {"cash":25,"bank":0,"gold":0,...}
charinfo  {"firstname":"John","lastname":"Marston","birthdate":"1870-01-01","gender":0,"nationality":"USA","account":"US03LXR..."}
job       {"name":"vallaw","label":"...","type":"leo","onduty":false,"isboss":false,"payment":25,"grade":{"name":"Deputy","level":1,"payment":25,"isboss":false}}
gang      {"name":"none","label":"No Gang","isboss":false,"grade":{"name":"Unaffiliated","level":0,"isboss":false}}
position  {"x":0,"y":0,"z":0,"w":0}
metadata  {"health":600,"hunger":100,...,"xp":{"main":0},"levels":{"main":0},"rep":{}}
inventory [{"name":"bread","amount":2,"info":{},"type":"item","slot":1}]
```

## Ledger queries you will actually use

```sql
-- last 50 movements of a character
SELECT created_at, operation, account, amount, balance_after, reason, resource
FROM lxr_ledger WHERE citizenid = 'ABC12345' ORDER BY id DESC LIMIT 50;

-- who received the most cash today
SELECT citizenid, SUM(amount) total FROM lxr_ledger
WHERE account = 'cash' AND operation IN ('add','transfer_in') AND created_at >= CURDATE()
GROUP BY citizenid ORDER BY total DESC LIMIT 20;
```
