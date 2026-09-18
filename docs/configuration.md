<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# LXR-CORE — Configuration Reference (`config.lua`)

| Section | Key | Default | Meaning |
|---|---|---|---|
| `Lang` | | `'en'` | locale file in `locales/` (`ka` shipped) |
| `General` | `maxPlayers` | `sv_maxclients` | |
| | `defaultSpawn` | vector4 | fallback spawn |
| | `saveInterval` | `5` | minutes between dirty-player saves |
| | `hidePlayerNames` | `true` | overhead names → `Stranger (id)` |
| | `revealMap` | `true` | |
| | `enablePVP` | `true` | |
| | `paycheck.enabled/intervalMin/account/fromSociety/societyResource/societyExports` | `true / 10 / bank / false / lxr-bank` | society pay uses the two exports on lxr-bank |
| `Notify` | `backend` | `'native'` | `native` (RedM feed) / `ox_lib` / `event` |
| | `duration` | `4000` | ms |
| `Prompts` | `holdMs`, `distance` | `1000`, `1.5` | prompt defaults |
| `Database` | `autoMigrate` | `true` | apply `database/migrations` at boot |
| | `requireReady` | `true` | defer connections until migrated |
| | `slowQueryMs` | `250` | slow-query warning threshold |
| | `relinkImportedRows` | `true` | VORP import re-link |
| | `characterTables` | 5 tables | deleted with the character (missing tables are skipped) |
| `Money` | `MoneyTypes` | 8 accounts | `account = startBalance` |
| | `DontAllowMinus` | cash, gold, bloodmoney | |
| | `MinusLimit` | `-5000` | overdraft floor for other accounts |
| | `MaxBalance` | `1e9` | |
| | `IntegerAccounts` | `{ gold = true }` | |
| | `Decimals` | `2` | |
| | `LogThreshold` | `100000` | large amounts logged as warnings |
| | `Ledger.enabled/flushMs/maxBatch` | `true / 2000 / 200` | |
| | `EnableMoneyItems`, `MoneyItems` | `false` | reserved for RSG-style money items (hook: `LXRCore.Accounts.SyncMoneyItems`) |
| `Player` | `maxCharacters` | `5` | |
| | `maxWeight`, `maxSlots` | `120000`, `41` | core provider limits |
| | `bloodTypes`, `skills`, `xpPerLevel`, `maxLevel` | | |
| | `defaults` | table | applied to every character (missing keys only) |
| `Server` | `closed`, `closedReason` | `false` | only `lxrcore.join` may connect when closed |
| | `whitelist`, `whitelistPermission` | `false`, `whitelisted` | |
| | `checkDuplicateLicense` | `true` | |
| | `requireDiscord` | `false` | |
| | `permissions` | 7 groups | become `lxrcore.<group>` aces |
| `Commands` | `oocColor`, `meRange` | | |
| `Inventory` | `provider` | `'auto'` | or a provider id |
| `Catalog` | `validateOnBoot`, `failOnInvalid`, `year`, `enforceEra`, `contrabandSeizable`, `skills`, `decay`, `defaultStarterKit` | see file | shared-data validation, server year for `era` filtering, item decay, starter kit |
| | `providers` | `lxr-inventory, rsg-inventory, vorp_inventory, internal` | detection order |
| `Compat` | `rsg.enabled` | `true` | RSG events + aces |
| | `vorp.enabled`, `vorp.rolAccount` | `true`, `bloodmoney` | VORP facade |
| | `legacy.enabled` | `true` | QBR / v1-v2 surface |
| `Security` | `callbackRateLimit` | `{ burst = 40, windowMs = 5000 }` | |
| | `callbackTimeoutMs` | `15000` | |
| | `eventRateLimit` | `{ burst = 60, windowMs = 5000 }` | |
| | `clientMetadataWhitelist` | hunger, thirst, cleanliness, stress | |
| | `kickOnExploit`, `logExploits` | `true` | |
| `Performance` | `saveBatchSize`, `saveBatchDelayMs` | `25`, `50` | |
| | `playerDataSyncMs` | `100` | PlayerData push debounce |
| | `metrics` | `true` | |
| `Log` | `level` | `'info'` | `debug/info/warn/error` |
| | `console` | `true` | |
| | `forwardEvent` | `lxr-log:server:CreateLog` | ecosystem log event |
| | `forwardRsgEvent` | `true` | also `rsg-log:server:CreateLog` |
| `Debug` | `enabled`, `printBanner` | `false`, `true` | |

`LXRConfig` is an alias of `Config` for legacy resources; `LXRCore.Config` is
the same table on both sides.
