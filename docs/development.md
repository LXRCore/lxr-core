# 🐺 LXR-CORE — Development & Testing

## Layout

```
lxr-core/
├── fxmanifest.lua            manifest (load order is significant)
├── config.lua                owner control panel
├── shared/                   namespace, locale engine, shared data (items/jobs/gangs/weapons/horses/vehicles)
├── locales/                  en.lua (canonical), ka.lua (1:1 mirror)
├── server/
│   ├── main.lua              core object, metrics, helpers
│   ├── log.lua               structured logging
│   ├── database.lua          oxmysql wrappers + migration runner
│   ├── callbacks.lua         request-id RPC (server side)
│   ├── permissions.lua       ACE model
│   ├── commands.lua          registry + built-ins
│   ├── roles.lua             jobs/gangs builders + registry
│   ├── accounts.lua          economy engine + ledger
│   ├── items.lua             usable items + inventory abstraction (providers)
│   ├── player.lua            login/logout/save/delete + player object
│   ├── events.lua            connection handling + validated net events
│   ├── exports.lua           export surface + world helpers
│   ├── compat/{rsg,vorp,legacy}.lua
│   └── boot.lua              boot sequence (last)
├── client/                   main, callbacks, notify.js/.lua, functions, prompts, drawtext, events, compat/*
├── database/migrations/      0001_core_schema.sql, 0002_ledger.sql
├── database/migrate/         rsg_to_lxr.sql, vorp_to_lxr.sql
├── database/schema.sql       generated snapshot
├── bridges/                  shim resources (rsg-core, vorp_core, qbr-core, vorp_inventory)
├── tests/                    offline suite (lua tests/run.lua)
└── docs/
```

## Running the tests

```bash
lua tests/run.lua            # all suites
lua tests/run.lua accounts   # substring filter
```

`tests/lib/fxshim.lua` emulates the Cfx runtime (coroutine scheduler, events,
exports, state bags, ACE, an in-memory oxmysql that keeps a `players` table).
The real `server/*.lua` files are loaded through it, so the suite exercises
login → save → switch → delete, money rules, inventory logic, callbacks,
permissions, commands, connection deferrals and the compat adapters.

What the suite does **not** cover: natives, NUI, real MySQL, network timing,
client scripts. Those need an in-game session (see `docs/compatibility.md`
for the tested/not-tested matrix).

## Syntax check

```bash
find . -name '*.lua' -not -path './.git/*' -print0 | xargs -0 -n1 luac -p
node --check client/notify.js
```
CI (`.github/workflows/ci.yml`) runs the same plus luacheck.

## Conventions

* Every server-side mutation validates its input; nothing trusts the client.
* Client-originated events are rate-limited (`LXRCore.RateLimit`) and logged through `LXRCore.Log.exploit` when they fail validation.
* No per-frame loops in the core; client work is event / state-bag driven, prompts use an adaptive thread.
* New tables → a migration file + `CORE_MIGRATIONS` entry (never edit an applied migration).
* Player-facing strings → `locales/en.lua` and a matching `locales/ka.lua` key (the locale test fails otherwise).
* Public API additions → `docs/api.md` / `docs/exports.md`; event additions → `docs/events.md`.
* Files carry the LXRCore banner header; config sections use `████` dividers.

## Releasing

1. Bump `version` in `fxmanifest.lua` and add a `CHANGELOG.md` entry.
2. Run the test suite and CI.
3. Regenerate `database/schema.sql` if migrations changed.
4. Tag `vX.Y.Z`.
