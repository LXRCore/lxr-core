# Changelog — lxr-core

All notable changes to this resource are documented here. Versions follow
semantic versioning; the `lxr_core_api` manifest field tracks API level.

## [3.0.0] — 2026-09-17

Complete rewrite. v2.x was a QBR-Core fork with bolted-on modules; v3 is an
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
