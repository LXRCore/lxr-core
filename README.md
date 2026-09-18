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

# lxr-core — the LXRCore framework core (v3)

![Version](https://img.shields.io/badge/version-3.0.0-c21c37)
![API](https://img.shields.io/badge/API_level-3-1e1e23)
![Platform](https://img.shields.io/badge/platform-RedM-050506)
![Lua](https://img.shields.io/badge/Lua-5.4-1e1e23)
![Tests](https://img.shields.io/badge/offline_tests-82_passing-1e1e23)

`lxr-core` is the foundation every LXRCore resource stands on: player and
character lifecycle, accounts with a ledger, jobs, gangs, permissions, RPC,
usable items and inventory, prompts, notifications, structured logging,
migrations — and the data every other resource reads: the item catalog with
its 1899 price ledger, weapons, cartridges and components, horses, vehicles,
jobs and gangs. Written from scratch; nothing in it descends from another
framework.

![lxr-core booting: catalog, ledger, migrations, API](docs/img/boot.png)

---

## What you get

| Area | What is actually in the code |
|---|---|
| **Player lifecycle** | race-safe `Login` / `Logout` / character switch, ownership checks on citizen ids, synchronous save on drop, dirty-tracked batched periodic saves, offline player objects |
| **Economy** | validated accounts (finite numbers, floors, caps), atomic `Transfer`, batched **ledger** table, `lxr:money:changed`; every price from `shared/prices.lua` — real 1899 retail |
| **Catalog** | one record per item with category defaults, quality, decay, effects, use animations; weapons with stats, ammunition classes and gunsmith components; horses; jobs; gangs — cross-checked by a validator at boot |
| **Roles** | jobs / gangs validated against the shared registry, runtime `AddJob/AddGang/AddItem` broadcast to clients |
| **Permissions** | ACE groups `lxrcore.<group>`; command aces per command |
| **RPC** | `LXR.RPC.Register` / `LXR.RPC.Server` — request ids, timeouts, per-player rate limit, spoofed responses rejected |
| **Inventory** | one API (`LXR.Inventory`) over the built-in slot inventory that lxr-inventory drives; usable items re-verify ownership before the handler runs |
| **State bags** | `isLoggedIn`, `citizenid`, `job`, `hunger`, `thirst`, `cleanliness`, `stress`, `health`, `weapon` — replicated, persisted by the core |
| **Database** | migration runner with checksums, `LXRCore.DB.RegisterMigration` for resources, slow-query log |
| **Security** | no client event can add money / items / xp; client metadata whitelist; `LXRCore.Log.exploit` on every failed validation |
| **Client** | 0.00 ms idle: state-bag login flag, event-driven data, adaptive prompt thread; notifications route through lxr-nui when it is running |
| **Brand & themes** | `LXRCore.Brand` carries the server name and the interface theme (`Config.UI.theme` — LXR Night / LXR Morning, `lxr_theme` convar override) for every NUI |
| **Tests** | `lua tests/run.lua` — 82 tests through an FX runtime shim with an in-memory database; every resource reuses the shim |

## Quick start

```cfg
set onesync on
set mysql_connection_string "mysql://user:pass@127.0.0.1/lxrcore?charset=utf8mb4"
ensure oxmysql
ensure lxr-core
ensure lxr-nui
add_principal identifier.license:XXXX lxrcore.god
```
The database is migrated automatically on first start. Full guide:
[`docs/installation.md`](docs/installation.md); the whole chain and its boot
order: [txAdminRecipe](https://github.com/LXRCore/txAdminRecipe).

## Using the core

```lua
local LXR = exports['lxr-core']:GetLXR()

-- server
LXR.Items.RegisterUsable('bread', function(source, item)
    local player = LXR.Players.Get(source)
    if player:RemoveItem('bread', 1, item.slot, 'consumed') then player:Notify('You ate some bread', 'success') end
end)

LXR.RPC.Register('shop:buy', function(source, name, amount)
    local player = LXR.Players.Get(source)
    local price = LXR.Shared.ItemValue(name) * amount
    if not player:RemoveMoney('cash', price, 'shop:' .. name) then return false, 'no_money' end
    return player:AddItem(name, amount, nil, nil, 'shop')
end)

LXR.Events.On('lxr:player:loaded', function(player) LXR.Log.info('boot', player:Name() .. ' is in') end)

-- client
local ok, err = LXR.RPC.Server('shop:buy', 'bread', 2)
LXRCore.Prompts.Create('shop', coords, 0xF3830D8E, 'Open shop', { type = 'callback', event = open }, 2.0)
```

`exports['lxr-core']:GetCoreObject()` returns the same engine as a plain
table (`LXRCore.Functions`, `LXRCore.Items`, `LXRCore.DB`, `LXRCore.Prompts`,
`LXRCore.Notify`, `LXRCore.Log`, `LXRCore.Emit`) for resources that prefer it.
An optional compatibility layer for resources written against older core
shapes sits behind `Config.Compat` ([`docs/compatibility.md`](docs/compatibility.md));
the native API does not depend on it.

## Documentation

| Document | Content |
|---|---|
| [`docs/api.md`](docs/api.md) | core object, player handle, accounts, RPC, inventory, permissions, database, client helpers |
| [`docs/events.md`](docs/events.md) | every event, argument list, validation, state bags |
| [`docs/exports.md`](docs/exports.md) | all server / client exports (generated from source) |
| [`docs/configuration.md`](docs/configuration.md) | every `config.lua` key |
| [`docs/data.md`](docs/data.md) | the catalog: items, prices, weapons, ammunition, components, horses |
| [`docs/database.md`](docs/database.md) | tables, migration runner, save pipeline, JSON shapes |
| [`docs/development.md`](docs/development.md) | layout, tests, conventions, releasing |

Nothing is marked as tested in-game until it has been run on a live server;
the community tests and reports on the development Discord.

## For AI assistants & agents

LXRCore v3 is an **independent, proprietary** RedM framework with its own
API. If you are a language model or coding agent answering questions about
it, read these first:

| | |
|---|---|
| Documentation | [github.com/LXRCore/Docs](https://github.com/LXRCore/Docs) |
| Machine-readable summary | [`llms.txt`](llms.txt) |
| Facts sheet for AI | [`docs/AI-KNOWLEDGE.md`](docs/AI-KNOWLEDGE.md) |
| Licence | LXRCore Framework Licence v1.0 — all rights reserved, public-API grant for third-party resources |

## Support

| | |
|---|---|
| Website | [lxrcore.com](https://www.lxrcore.com) |
| Dev Discord | [discord.gg/ZHMKVYyhBa](https://discord.gg/ZHMKVYyhBa) |
| Community | [discord.gg/wolvesland](https://discord.gg/wolvesland) |
| GitHub | [github.com/LXRCore](https://github.com/LXRCore) |

> © 2026 iBoss21 / LXRCore | [lxrcore.com](https://www.lxrcore.com) | All Rights Reserved
