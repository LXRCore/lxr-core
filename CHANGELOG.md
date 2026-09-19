# Changelog — lxr-core

All notable changes to this resource are documented here. Versions follow
semantic versioning; the `lxr_core_api` manifest field tracks API level.

## 3.0.0 — 2026-09-19
* Catalog: armadillo shell, javelina hide, iguana skin, lion pelt, turtle shell; songbird / condor / vulture / crane / seabird / quail feathers, bat wing, gila venom gland (priced).
* Catalog: `bottle_empty`; spirits give it back when drunk (`use.gives`).
* Console commands work: source 0 holds every permission (`Perms.Has` / `Perms.Group`), `LXRCore.Notify(0, …)` prints to the console and `EmitClient` never calls the native with no player (`revive 1` from the txAdmin console threw "Argument at index 1 was null").
* Catalogue animations `canteen` and `eat_canned`; the canteen item drinks with `canteen`.
* Cross-resource callbacks run in their own thread: prompt callbacks and server→client callback answers may now yield (an RPC, a Wait) — called straight from the loop they threw "Execution of function reference in script host failed / error object is not a string" (the tailor door, the revive). `LXRCore.Functions.Door` / `LXR.UI.Door`: one helper for every walk-up door — the lxr-interact card when it runs, the native prompt otherwise.
* LXRCore v3 release line: every resource ships as 3.0.0 from here (the entries below are the road to it).

## 3.0.2 — 2026-09-19
* Fix: notifications through lxr-nui showed as an empty black bar — the toast was handed `opts.text` (the legacy field) instead of `opts.title`; the description is passed too.
* RDR3 natives only: `SetNetworkIdCanMigrate` (GTA V) → `SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES` on vehicle spawn; `GetDisplayNameFromVehicleModel` (GTA V) → label from the model's text key or nil; the VORP compat `Utils.ScreenResolution` uses `GET_SCREEN_RESOLUTION`.
* `tools/native_check.py` (workspace): every client/shared native call is checked against the RedM runtime's own Lua global list — GTA V-only natives no longer reach a live server.

## 3.0.1 — 2026-09-19
* `Player(src).state.isLoggedIn` flips on `lxr:player:spawned` (the character stands in the world), not on login; `hasCharacter` marks the login. The HUD no longer paints over the creator's spawn page.
* Client: `LXRCore.Notify(msg, kind)` is the same name as on the server (alias of `LXRCore.Functions.Notify`) — a dozen client scripts already called it.
* Boot banner and brand table carry the framework Discord.

## [3.1.0] — 2026-09-17

### Added
- **1899 price ledger** (`shared/prices.lua`): every item, horse breed and vehicle priced at real 1899 US retail; wages in `shared/jobs.lua` are one working day at 1899 rates; starting cash $5.
- `/me` renderer switch (`Config.Commands.meRenderer`) for lxr-me.
- **Shared catalog** (`shared/catalog.lua`): LXRCore's own data model with category profiles, rarities, named animations/props, towns/states, and an offline + boot validator (`LXRShared.Catalog.Validate`, `Config.Catalog`).
- 579 era-accurate items (1899–1907): currency, food, graded meat/fish (quality in `info`, not three copies), drink, spirits, tobacco, period medicine, herbs, hunting by-products, materials, tools, fishing, horse care & tack, documents/keys, valuables, collectibles, contraband, 33 ammunition types, 61 weapons, throwables.
- 61 weapons with ammo classes, stats, era, maker, dual-wield, degrade and a gunsmith component vocabulary (`LXRShared.WeaponComponents`, `LXRShared.AmmoClasses`).
- 26 horse breeds / 120 coats with 1–10 stats, tiers, temperaments, town availability and wild flags (`LXRShared.HorseBreeds`, `LXRShared.HorsesForTown`).
- 60 wagons, coaches, carts and boats with seats, draft, storage, job restrictions (`LXRShared.WagonsForShop`).
- 55 jobs with permission ladders (`grade.perms`: duty/hire/fire/promote/stash/armory/society/till/vehicles/manage), societies, towns, uniforms; 18 gangs/families/factions with permissions, rivals, allies, activities, and `LXRShared.GangTemplate` for player-made gangs.
- Eight starter kits chosen at character creation (`LXRShared.StarterKits`).
- `LXRCore.Brand` (shared/main.lua) replaces `Config.ServerInfo`; player-facing name/discord come from `sv_projectName` / `lxr_discord` convars.
- Item use gates: `use.whileDead`, `use.whileCuffed`, per-item cooldown + `Config.Security.itemUseCooldownMs`.

### Changed
- `Roles.BuildJob/BuildGang` include `grade.perms`.
- Test suite: 81 tests (catalog integrity, lookups, perms).

## [3.0.0] — 2026-09-17

Complete rewrite. v2.x was a fork-based core with bolted-on modules; v3 is an
independent implementation with a documented, tested core.

### Added
- Core object with two faces: RSG-shaped (`Functions`, `Player`, `Players`, `Shared`, `Config`, `Commands`) and native modules (`Accounts`, `Roles`, `Perms`, `Callback`, `Items`, `Inventory`, `DB`, `Log`, `Metrics`).
- Migration runner (`database/migrations/*.sql`, tracked in `lxr_migrations`); external resources register migrations with `LXRCore.DB.RegisterMigration`.
- Money ledger (`lxr_ledger`) with batched writes; `Accounts.Transfer` atomic transfers; hard caps, integer accounts, overdraft floors.
- Request-id callbacks in both directions with timeouts, rate limiting and `Await` variants; legacy name-keyed protocol still answered.
- Dirty-tracked, batched periodic saves; synchronous save on drop / logout / resource stop.
- Race-safe login / character switch; ownership checks kick spoofed citizen ids.
- Inventory abstraction with providers: core (built-in), lxr-inventory (legacy), rsg-inventory, vorp_inventory.
- Compatibility adapters: RSG events + aces, VORP `GetCore()` facade, legacy LXR / QBR export surface; shim resources under `bridges/`.
- VORP import re-link (steam-keyed rows are re-keyed to the license on first login).
- Structured logging with ecosystem forwarding (`lxr-log:server:CreateLog`, `rsg-log:server:CreateLog`).
- Metrics counters/timings (`/lxr:metrics`).
- Unified notifications (native RedM feed via `client/notify.js`, ox_lib or custom event).
- Adaptive prompt system (0.00 ms idle).
- Offline test suite (`lua tests/run.lua`, 69 tests) and CI workflow.
- Georgian locale (`locales/ka.lua`) mirrored 1:1 with English.

### Changed
- `Config` replaces `LXRConfig` (alias kept). Section layout follows the LXRCore brand standard.
- Client-settable metadata is whitelisted (`Config.Security.clientMetadataWhitelist`).
- Permissions use `lxrcore.<group>` aces; `rsgcore.<group>` principals are aliased.

### Removed
- `server/anticheat.lua`, `antidupe.lua`, `tebex.lua`, `developertools.lua`, `performance.lua`, `protection.lua`, `security.lua`, `logs.lua`, `bridge.lua`, `client/anticheat.lua`, `client/performance.lua`, the NUI page, 12 transient-state log tables, `dev_myths`, `player_contacts`.
- Client-triggerable item / XP events (`LXRCore:Server:AddItem`, `LXRCore:Player:GiveXp`, …) — they now log an exploit attempt and do nothing.

### Migration
- v2 → v3: drop-in for the `players` / `bans` tables; missing columns are added at boot. See `docs/migration.md`.
- RSG → LXR: `database/migrate/rsg_to_lxr.sql`. VORP → LXR: `database/migrate/vorp_to_lxr.sql`.
