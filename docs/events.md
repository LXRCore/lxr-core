<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# LXR-CORE — Events (v3, API level 3)

Names are stable within API level 3. When `Config.Compat.rsg.enabled` is true
every lifecycle event is also emitted under the equivalent `RSGCore:*` name.

## Server-side events (AddEventHandler)

| Event | Arguments | When |
|---|---|---|
| `LXRCore:Server:Ready` | – | boot finished, database migrated |
| `LXRCore:Server:DatabaseReady` | – | oxmysql ready + migrations applied |
| `LXRCore:Server:PlayerConnecting` | `source, name, setKickReason, deferrals` | after core checks passed; call `deferrals.done(msg)` to refuse |
| `LXRCore:Server:PlayerLoaded` | `Player` | character loaded (`Players[source]` set) |
| `LXRCore:Server:PlayerSpawned` | `source, Player` | spawn resource signalled `LXRCore:Server:OnPlayerLoaded` |
| `LXRCore:Server:OnPlayerUnload` | `source` | before logout save |
| `LXRCore:Server:PlayerDropped` | `Player, reason` | before drop save |
| `LXRCore:Server:OnPlayerUpdated` | `PlayerData` | every debounced PlayerData push |
| `LXRCore:Player:SetPlayerData` | `PlayerData` | same moment as above (RSG name) |
| `LXRCore:Server:OnJobUpdate` | `source, job` | SetJob / duty change |
| `LXRCore:Server:SetDuty` | `source, onduty` | |
| `LXRCore:Server:OnGangUpdate` | `source, gang` | |
| `LXRCore:Server:OnMoneyChange` | `source, account, amount, 'add'|'remove'|'set', reason` | |
| `LXRCore:Server:OnMoneySet` | `source, account, amount, before, reason` | |
| `LXRCore:Server:OnMetaDataUpdate` | `source, keyOrTable, value` | |
| `LXRCore:Server:OnInventoryUpdate` | `source` | core provider item change |
| `LXRCore:Server:CharacterDeleted` | `source (0 = console), citizenid` | |
| `LXRCore:Server:PreCommandExecution` | `source, command, args` | |
| `LXRCore:Server:UpdateObject` | – | core object mutated (SetMethod/SetField/registry) |
| `lxr-log:server:CreateLog` | `channel, title, color, message, tagEveryone` | every info+ log line (configurable) |

## Client-side events (RegisterNetEvent / AddEventHandler)

| Event | Arguments | Notes |
|---|---|---|
| `LXRCore:Client:OnPlayerLoaded` | – | fired by spawn / multicharacter resources; sets `LocalPlayer.state.isLoggedIn` |
| `LXRCore:Client:OnPlayerUnload` | – | |
| `LXRCore:Player:SetPlayerData` | `PlayerData` | replicated data (`LXRCore.PlayerData`) |
| `LXRCore:Client:OnPlayerDataUpdate` | `PlayerData` | local echo after replication |
| `LXRCore:Client:OnJobUpdate` | `job` | |
| `LXRCore:Client:SetDuty` | `onduty` | |
| `LXRCore:Client:OnGangUpdate` | `gang` | |
| `LXRCore:Client:OnMoneyChange` | `account, amount, op, reason` | |
| `hud:client:OnMoneyChange` | `account, amount, isMinus` | RSG HUD convention |
| `LXRCore:Client:OnXpChange` | `skill, xp, level` | |
| `LXRCore:Notify` | `text, type, duration` or `{…}` or legacy `(id, text, …)` | |
| `LXRCore:Client:PvpHasToggled` | `state` | |
| `LXRCore:Client:SharedUpdate` | `LXRShared` | full snapshot on join |
| `LXRCore:Client:OnSharedUpdate` | `table, key, value` | |
| `LXRCore:Client:OnSharedUpdateMultiple` | `table, values` | |
| `LXRCore:Client:UpdateObject` | – | after shared data changed |
| `LXRCore:Client:Heal` / `LXRCore:Client:Revive` | `[param]` | from VORP facade `Core.Player.*` |

## Net events accepted from clients (validated + rate limited)

| Event | Arguments | Validation |
|---|---|---|
| `LXRCore:Server:Callback:Request` | `name, reqId, …` | rate limit, registry |
| `LXRCore:Server:Callback:Response` | `reqId, …` | must match pending request source |
| `LXRCore:Server:TriggerCallback` | `name, …` | legacy v2 protocol |
| `LXRCore:Server:TriggerClientCallback` | `name, …` | legacy |
| `LXRCore:UpdatePlayer` | – | one save per 30 s |
| `LXRCore:Server:SetMetaData` | `key, number` | key ∈ `Config.Security.clientMetadataWhitelist` |
| `LXRCore:ToggleDuty` | – | |
| `LXRCore:Server:OnPlayerLoaded` | – | spawn signal |
| `LXRCore:Server:UseItem` | `item` | ownership re-checked server-side |
| `LXRCore:CallCommand` | `name, args` | ACE `command.<name>` |
| `LXRCore:Server:CloseServer` / `OpenServer` | `[reason]` | `admin` ace |
| `LXRCore:Server:RequestShared` | – | |

Deprecated and **disabled** (logged as exploit attempts): `LXRCore:Server:AddItem`,
`LXRCore:Server:RemoveItem`, `LXRCore:Player:GiveXp`, `LXRCore:Player:RemoveXp`,
`LXRCore:Player:SetLevel`, and their `RSGCore:*` twins.

## State bags

| Bag | Key | Value |
|---|---|---|
| `Player(src).state` | `isLoggedIn` | bool |
| | `citizenid` | string |
| | `job` | `{ name, grade, onduty, type }` |
| | `hunger`, `thirst`, `cleanliness`, `stress`, `health` | numbers (persisted back on save) |
| | `instance` | routing bucket when `SetPlayerBucket` used |
| | `IsInSession`, `Character` | VORP compat (`Config.Compat.vorp.enabled`) |
| `GlobalState` | `Count:Players` | online count |
| | `LXRCoreReady` | true after boot |
