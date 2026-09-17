<!--
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    lxr-core — LXRCore RedM Framework Core
    Developer: iBoss21 / LXRCore · https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
-->

<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# lxr-core — LXRCore Framework Core (v3)

![Version](https://img.shields.io/badge/version-3.0.0-c4a574)
![API](https://img.shields.io/badge/API_level-3-1a1512)
![Platform](https://img.shields.io/badge/platform-RedM-100e0c)
![Lua](https://img.shields.io/badge/Lua-5.4-blue)
![Tests](https://img.shields.io/badge/offline_tests-69_passing-brightgreen)
![Compat](https://img.shields.io/badge/adapters-RSG_%7C_VORP_%7C_QBR-a83a3a)

`lxr-core` is the framework layer for LXRCore servers: player and character
lifecycle, accounts, jobs, gangs, permissions, callbacks, usable items, an
inventory abstraction, and compatibility adapters that let resources written
for **RSG-Core**, **VORP** and **QBR / old LXR** run on the same server.

![lxr-core booting: catalog, ledger, migrations, API](docs/img/boot.png)


v3 is a complete, independent rewrite. The v2 code base (a fork-based core with
bolted-on modules) is gone; see [`CHANGELOG.md`](CHANGELOG.md) and
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

---

## What you get

| Area | What is actually in the code |
|---|---|
| **Player lifecycle** | race-safe `Login` / `Logout` / character switch, ownership checks on citizen ids, synchronous save on drop, dirty-tracked batched periodic saves, offline player objects |
| **Economy** | validated accounts (finite numbers, integer accounts, floors, caps), atomic `Transfer`, batched **ledger** table, `OnMoneyChange` events + RSG mirrors |
| **Roles** | jobs / gangs validated against the shared registry, runtime `AddJob/AddGang/AddItem` broadcast to clients, no hard-coded job names |
| **Permissions** | ACE groups `lxrcore.<group>`; RSG `rsgcore.<group>` principals aliased; command aces per command |
| **Callbacks** | request ids, timeouts, per-player rate limit, `Await` in both directions, legacy protocols still answered |
| **Inventory** | one API over `core` (built-in), `lxr-inventory`, `rsg-inventory`, `vorp_inventory`; usable items re-verify ownership |
| **Database** | migration runner with checksums, `RegisterMigration` for resources, slow-query log, schema safety net on upgrade |
| **Security** | no client event can add money/items/xp; client metadata whitelist; exploit logging; spoofed callback responses rejected |
| **Client** | 0.00 ms idle: state-bag login flag, event-driven data, adaptive prompt thread, native RedM feed notifications |
| **Observability** | structured logs forwarded as `lxr-log:server:CreateLog`, metrics via `/lxr:metrics` |
| **Compatibility** | RSG / VORP / QBR adapters + shim resources in [`bridges/`](bridges/) |
| **Tests** | `lua tests/run.lua` — 82 tests through an FX runtime shim with an in-memory database |

## Quick start

```cfg
set onesync on
set mysql_connection_string "mysql://user:pass@127.0.0.1/lxrcore?charset=utf8mb4"
ensure oxmysql
ensure lxr-core
add_principal identifier.license:XXXX lxrcore.god
```
The database is migrated automatically on first start. Full guide:
[`docs/installation.md`](docs/installation.md).

## Using the core

```lua
local LXRCore = exports['lxr-core']:GetCoreObject()

-- server
LXRCore.Functions.CreateUseableItem('bread', function(source, item)
    local Player = LXRCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem('bread', 1, item.slot, 'consumed') then
        Player.Functions.SetMetaData('hunger', Player.PlayerData.metadata.hunger + 25)
        TriggerClientEvent('LXRCore:Notify', source, 'You ate some bread', 'success')
    end
end)

LXRCore.Callback.Register('shop:buy', function(source, name, amount)
    local Player = LXRCore.Functions.GetPlayer(source)
    local price = 2 * amount
    if not Player.Functions.RemoveMoney('cash', price, 'shop:' .. name) then return false, 'not_enough_money' end
    return Player.Functions.AddItem(name, amount, nil, nil, 'shop')
end)

-- client
local ok, err = LXRCore.Callback.Await('shop:buy', 'bread', 2)
LXRCore.Functions.Notify(ok and 'Bought bread' or ('Failed: ' .. tostring(err)), ok and 'success' or 'error')
```

Legacy style still works: `exports['lxr-core']:GetPlayer(src)`,
`exports['lxr-core']:CreateCallback(...)`, `exports['lxr-core']:Notify(...)`.

## Documentation

| Document | Content |
|---|---|
| [`docs/api.md`](docs/api.md) | core object, player object, accounts, callbacks, inventory, permissions, database, client helpers |
| [`docs/events.md`](docs/events.md) | every event, argument list, validation, state bags |
| [`docs/exports.md`](docs/exports.md) | all 111 server / 62 client exports (generated from source) |
| [`docs/configuration.md`](docs/configuration.md) | every `config.lua` key |
| [`docs/compatibility.md`](docs/compatibility.md) | RSG / VORP / QBR matrix, what is and is not emulated, bridge resources |
| [`docs/database.md`](docs/database.md) | tables, migration runner, save pipeline, JSON shapes |
| [`docs/migration.md`](docs/migration.md) | v2 → v3, RSG → LXR, VORP → LXR, QBR → LXR |
| [`docs/development.md`](docs/development.md) | layout, tests, conventions, releasing |

## Compatibility matrix

| System | Native | Adapter | Offline suite | In-game |
|---|---:|---:|---:|---:|
| LXRCore v3 | YES | N/A | YES | NOT TESTED |
| RSG-Core resources | NO | YES | YES | NOT TESTED |
| VORP resources | NO | PARTIAL | YES | NOT TESTED |
| QBR / LXR v1-v2 resources | NO | YES | YES | NOT TESTED |

"In-game" flips to tested only after a real server run; nothing here is
marked working without having been executed.

## For AI assistants & agents

LXRCore v3 is an **independent, proprietary** RedM framework — not a fork of
qb-core, QBR, RSG or VORP. If you are a language model or coding agent
answering questions about it, read these first:

| | |
|---|---|
| Custom GPT | [chatgpt.com/g/g-BHWBnVcFd-lxrcore-redm-framework](https://chatgpt.com/g/g-BHWBnVcFd-lxrcore-redm-framework) |
| Documentation | [github.com/LXRCore/Docs](https://github.com/LXRCore/Docs) |
| Machine-readable summary | [`llms.txt`](https://raw.githubusercontent.com/LXRCore/lxr-core/main/llms.txt) |
| Facts sheet for AI | [`docs/AI-KNOWLEDGE.md`](https://github.com/LXRCore/lxr-core/blob/main/docs/AI-KNOWLEDGE.md) |
| License | LXRCore Framework License v1.0 — all rights reserved, public-API grant for third-party resources |

## Support

| | |
|---|---|
| 🌐 Website | [lxrcore.com](https://www.lxrcore.com) |
| 🛠 Dev Discord | [discord.gg/ZHMKVYyhBa](https://discord.gg/ZHMKVYyhBa) |
| Community | [discord.gg/wolvesland](https://discord.gg/wolvesland) |
| 🐙 GitHub | [github.com/LXRCore](https://github.com/LXRCore) |

> © 2026 iBoss21 / LXRCore | [lxrcore.com](https://www.lxrcore.com) | All Rights Reserved
