# 🐺 LXR-CORE — Core API

Everything below exists in the code as written. Names in **bold** are the
preferred v3 API; the others are RSG / QBR-compatible aliases of the same
implementation.

## Getting the core object

```lua
-- server or client, any resource
local LXRCore = exports['lxr-core']:GetCoreObject()   -- alias: GetCore()
```

The returned table is the live core object (not a copy on the server side).
Function references stay valid across resource restarts of the caller.

## Server object layout

| Field | Purpose |
|---|---|
| `LXRCore.Config` | `config.lua` table |
| `LXRCore.Shared` | `Items`, `Jobs`, `Gangs`, `Weapons`, `Horses`, `Vehicles`, `StarterItems` |
| `LXRCore.Players` | `source → Player` |
| `LXRCore.PlayersByCitizenId`, `PlayersByLicense` | O(1) indexes |
| `LXRCore.Functions` | RSG-shaped function set (lookups, callbacks, permissions, registry, world helpers) |
| `LXRCore.Player` | character lifecycle module (`Login`, `Logout`, `Save`, `DeleteCharacter`, …) |
| `LXRCore.Commands` | `Add`, `Refresh`, `Call`, `List` |
| `LXRCore.Accounts` | economy engine |
| `LXRCore.Roles` | job/gang builders + registry |
| `LXRCore.Perms` | ACE permissions |
| `LXRCore.Callback` | request-id RPC |
| `LXRCore.Items` / `LXRCore.Inventory` | usable items / provider-aware inventory |
| `LXRCore.DB` | query wrappers, migrations, `OnReady` |
| `LXRCore.Log`, `LXRCore.Metrics` | observability |
| `LXRCore.Ready`, `LXRCore.Version`, `LXRCore.ApiLevel` | state |

## Players

```lua
local Player = LXRCore.Functions.GetPlayer(source)          -- number or identifier string
local Player = LXRCore.Functions.GetPlayerByCitizenId(cid)
local Player = LXRCore.Functions.GetPlayerByLicense(license) -- online, else offline object
local off    = LXRCore.Player.GetOfflinePlayer(cid)          -- Offline = true, Save() writes back
local ids    = LXRCore.Functions.GetPlayers()                -- { source, … }
local all    = LXRCore.Functions.GetLXRPlayers()             -- source → Player (alias GetRSGPlayers)
local list, n = LXRCore.Functions.GetPlayersOnDuty('vallaw')
local n      = LXRCore.Functions.GetDutyCount('vallaw')
local rows   = LXRCore.Player.GetCharacters(sourceOrLicense) -- decoded DB rows for multicharacter
local count  = LXRCore.Player.CountCharacters(license)
```

### Player.PlayerData

```
source, citizenid, cid, license, name, identifiers{license, license2, steam, discord, fivem, ip}
money{cash, bank, gold, bloodmoney, …}            -- every key in Config.Money.MoneyTypes
charinfo{firstname, lastname, birthdate, gender, nationality, account}
job{name, label, type, onduty, isboss, payment, grade{name, level, payment, isboss}}
gang{name, label, isboss, grade{name, level, isboss}}
metadata{health, hunger, thirst, cleanliness, stress, isdead, armor, ishandcuffed, injail,
         jailitems, status, rep, callsign, bloodtype, fingerprint, walletid, criminalrecord,
         xp{skill=n}, levels{skill=n}, …}
position{x, y, z, w}, items{slot = item}, weight, slots, optin, outlawstatus
```

### Player.Functions

| Function | Returns | Notes |
|---|---|---|
| `UpdatePlayerData()` | – | debounced push to client (`Config.Performance.playerDataSyncMs`) |
| `SetPlayerData(key, value)` | bool | |
| `SetJob(name, grade)` / `SetGang(name, grade)` | `ok, err` | validated against `Shared.Jobs` / `Shared.Gangs` |
| `SetJobDuty(bool)` | bool | fires `OnJobUpdate` + `SetDuty` |
| `SetMetaData(key, value)` / `SetMetaData({k = v})` | bool | hunger/thirst/cleanliness/stress clamped 0–100 |
| `GetMetaData(key)` | any | |
| `AddRep / RemoveRep / GetRep(rep, amount)` | | stored in `metadata.rep` |
| `AddXp / RemoveXp(skill, amount)`, `GetXp / GetLevel(skill)` | | level = `floor(xp / Config.Player.xpPerLevel)` |
| **`AddMoney(account, amount, reason)`** | `ok, err` | err ∈ `invalid_account`, `invalid_amount` |
| **`RemoveMoney(account, amount, reason)`** | `ok, err` | err also `not_enough_money` |
| `SetMoney(account, amount, reason)` | `ok, err` | |
| `GetMoney(account)` / `HasMoney(account, amount)` | number / bool | |
| `AddItem(item, amount, slot, info, reason)` | `ok, err` | provider-aware (core / rsg-inventory / vorp_inventory) |
| `RemoveItem(item, amount, slot, reason)` | `ok, err` | all-or-nothing across stacks |
| `HasItem(items, amount)` | bool | string, list or `{ name = amount }` |
| `GetItemByName / GetItemsByName / GetItemBySlot` | | core-provider view of `PlayerData.items` |
| `SetInventory(items)` / `ClearInventory(filter)` | | |
| `Save()` / `Logout()` | | |
| `AddMethod(name, fn)` / `AddField(name, value)` | | extend at runtime |
| `InitializeStateBags()` / `PersistStateBags()` | | hunger/thirst/… mirrored to `Player(src).state` |

### Accounts (direct engine access)

```lua
LXRCore.Accounts.Add(player, account, amount, reason)      -- same as Player.Functions.AddMoney
LXRCore.Accounts.Transfer(fromPlayer, toPlayer, account, amount, reason)  -- atomic, both ledger rows
exports['lxr-core']:TransferMoney(fromSource, toSource, account, amount, reason)
```
Rules: finite numbers only, `> 0` (Set allows 0), integer for `Config.Money.IntegerAccounts`,
rounded to `Config.Money.Decimals`, `DontAllowMinus` / `MinusLimit` floors, `MaxBalance`
ceiling. Every mutation is written to `lxr_ledger` when `Config.Money.Ledger.enabled`.

## Lifecycle

```lua
LXRCore.Player.Login(source, citizenid)                     -- existing character
LXRCore.Player.Login(source, false, { cid = 1, charinfo = { firstname = 'J', lastname = 'M', gender = 0, birthdate = '1870-01-01', nationality = 'USA' } })
LXRCore.Player.Logout(source)                               -- saves, clears indexes, fires unload events
LXRCore.Player.Save(source, sync)                           -- upsert players row (+ inventory provider save)
LXRCore.Player.DeleteCharacter(source, citizenid)           -- ownership enforced; transaction over character tables
LXRCore.Player.ForceDeleteCharacter(citizenid)              -- admin / console
LXRCore.Player.RegisterCharacterTable('my_table', 'citizenid')  -- include in delete transaction
```
`Login` returns `false` when the database is not ready, a login is already in
progress, the character is in use, or the row does not belong to the license
(the player is kicked when `Config.Security.kickOnExploit`). Switching
characters is `Login` while another character is loaded — the previous one is
saved synchronously first.

## Callbacks

```lua
-- server: answer clients
LXRCore.Callback.Register('shop:buy', function(source, itemName, amount)
    return ok, err          -- returned values are sent back
end)
LXRCore.Functions.CreateCallback('shop:list', function(source, cb) cb(list) end)  -- RSG/QBR style

-- server: ask a client
LXRCore.Callback.Trigger('client:cam', source, function(x, y, z) end, args…)
local x, y, z = LXRCore.Callback.Await('client:cam', source, args…)          -- nil on timeout

-- client: ask the server
LXRCore.Functions.TriggerCallback('shop:buy', function(ok, err) end, 'bread', 2)
local ok, err = LXRCore.Callback.Await('shop:buy', 'bread', 2)

-- client: answer the server
LXRCore.Callback.Register('client:cam', function(…) return … end)
LXRCore.Functions.CreateClientCallback('client:cam', function(cb, …) cb(…) end)
```
Requests carry unique ids; concurrent calls of one name never collide.
Timeout: `Config.Security.callbackTimeoutMs`. Per-player limit:
`Config.Security.callbackRateLimit`.

## Jobs, gangs, items (registry)

```lua
LXRCore.Functions.AddJob(name, def) / AddJobs(map) / UpdateJob / RemoveJob
LXRCore.Functions.AddGang / AddGangs / UpdateGang / RemoveGang
LXRCore.Functions.AddItem(name, def) / AddItems(map) / UpdateItem / RemoveItem   -- registry, not player inventory
LXRCore.Roles.BuildJob(name, grade) → job table | nil, 'invalid_job' | 'invalid_grade'
```
Each returns `ok, message[, offendingEntry]` (`success`, `job_exists`, `job_not_exists`, …) and broadcasts to every client.

## Usable items & inventory abstraction

```lua
LXRCore.Functions.CreateUseableItem('bread', function(source, item) … end)   -- alias RegisterUsableItem
LXRCore.Items.Use(source, itemOrName)      -- re-verifies ownership server-side before calling the handler

LXRCore.Inventory.Provider                 -- 'core' | 'rsg-inventory' | 'vorp_inventory'
LXRCore.Inventory.AddItem(source, name, amount, slot, info, reason)
LXRCore.Inventory.RemoveItem(source, name, amount, slot, reason)
LXRCore.Inventory.HasItem(source, items, amount)
LXRCore.Inventory.GetItem(source, name, slot) / GetItems(source) / GetItemCount(source, name)
LXRCore.Inventory.CanCarry(source, name, amount)
LXRCore.Inventory.SetMetadata(source, slot, info) / ClearInventory(source, keep) / SetInventory(source, items)
```

## Permissions & commands

```lua
LXRCore.Perms.Has(source, 'admin')  / Has(source, { 'admin', 'mod' })
LXRCore.Perms.Add(source, 'admin')  / Remove(source, 'admin' | nil) / Get(source) / Group(source)
LXRCore.Commands.Add(name, help, { { name = 'id', help = '' } }, argsRequired, function(source, args, raw) end, 'admin')
LXRCore.Commands.Refresh(source)     -- chat suggestions
LXRCore.Commands.Call(source, name, args)
```
Groups become `lxrcore.<group>` aces; commands become `command.<name>`.

## Database

```lua
LXRCore.DB.Query / Single / Scalar / Insert / Update / Prepare(sql, params)   -- await variants with timing + slow log
LXRCore.DB.Transaction({ { query = '', values = {} }, … })                     -- bool
LXRCore.DB.InsertAsync / UpdateAsync(sql, params, cb)
LXRCore.DB.RegisterMigration(resourceName, '0001_name', sqlString)
LXRCore.DB.OnReady(function() … end)
LXRCore.DB.TableExists(name) / ColumnExists(table, column)
```

## Logging & metrics

```lua
LXRCore.Log.debug|info|warn|error('channel', 'message', { data = 1 })
LXRCore.Log.exploit(source, 'what happened', { detail = … })
LXRCore.Metrics.Inc('my.counter') / Time('my.timing', ms) / Get()
```

## Client object

```lua
LXRCore.PlayerData                 -- replicated, read-only
LXRCore.Functions.IsLoggedIn()     -- LocalPlayer.state.isLoggedIn
LXRCore.Functions.Notify(text, type, duration) / Notify({ title, description, type, duration })
LXRCore.Functions.GetCoords, GetClosestPlayer/Ped/Vehicle/Object, GetPlayersFromCoords, LoadModel, RequestAnimDict,
PlayAnim, SpawnPed, RemovePed, AttachProp, SpawnVehicle, DeleteVehicle, GetPlate, CreateBlip, DeleteBlip,
HasItem, Progressbar, DrawText, DrawText3D
LXRCore.Prompts.Create(name, coords, key, label, { type = 'server'|'client'|'callback', event, args }, distance, marker, holdMs)
LXRCore.Prompts.CreateGroup(name, label, coords, { { key, text, options } }, distance)
LXRCore.Prompts.Delete / DeleteGroup / Register(key, label, holdMs)
```
