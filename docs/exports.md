# 🐺 LXR-CORE — Exports

Generated from the source on 2026-09-17. Legacy resources call these as
`exports['lxr-core']:Name(...)`; new resources should prefer the core object
(`docs/api.md`). Every export listed here exists in the code.

## Server (111)

| | | | |
|---|---|---|---|
| `AddCommand` | `AddGang` | `AddGangs` | `AddItem` |
| `AddItems` | `AddJob` | `AddJobs` | `AddMoney` |
| `AddPermission` | `AddPlayerItem` | `AddXp` | `AwaitClientCallback` |
| `CallCommand` | `CanUseItem` | `ClearInventory` | `CreateCallback` |
| `CreateUseableItem` | `Debug` | `DeleteCharacter` | `ExploitBan` |
| `ForceDeleteCharacter` | `GetCharacters` | `GetClosestPlayer` | `GetConfig` |
| `GetCore` | `GetCoreObject` | `GetCoreVersion` | `GetDutyCount` |
| `GetFirstSlotByItem` | `GetGangs` | `GetHorses` | `GetIdentifier` |
| `GetInventoryProvider` | `GetItem` | `GetItemByName` | `GetItemBySlot` |
| `GetItems` | `GetItemsByName` | `GetJobs` | `GetLXRPlayers` |
| `GetMetrics` | `GetMoney` | `GetOfflinePlayerByCitizenId` | `GetPermissionGroup` |
| `GetPermissions` | `GetPlayer` | `GetPlayerByCitizenId` | `GetPlayerByLicense` |
| `GetPlayerData` | `GetPlayerItem` | `GetPlayerItemCount` | `GetPlayerItems` |
| `GetPlayers` | `GetPlayersByJob` | `GetPlayersInBucket` | `GetPlayersOnDuty` |
| `GetShared` | `GetSlotsByItem` | `GetSource` | `GetTotalWeight` |
| `GetVehicles` | `GetVorpCore` | `GetWeapons` | `HasItem` |
| `HasPermission` | `IsDatabaseConnected` | `IsDatabaseReady` | `IsOptin` |
| `IsPlayerBanned` | `IsPlayerLoaded` | `IsReady` | `Kick` |
| `KickPlayer` | `Login` | `Logout` | `Notify` |
| `RandomInt` | `RandomStr` | `RefreshCommands` | `RegisterCallback` |
| `RegisterCharacterTable` | `RegisterMigration` | `RegisterUsableItem` | `RemoveGang` |
| `RemoveItem` | `RemoveJob` | `RemoveMoney` | `RemovePermission` |
| `RemovePlayerItem` | `RemoveXp` | `Round` | `SavePlayer` |
| `SetEntityBucket` | `SetField` | `SetGang` | `SetInventory` |
| `SetJob` | `SetMethod` | `SetPlayerBucket` | `ShowError` |
| `ShowSuccess` | `SplitStr` | `ToggleOptin` | `TransferMoney` |
| `TriggerCallback` | `TriggerClientCallback` | `Trim` | `UpdateGang` |
| `UpdateItem` | `UpdateJob` | `UseItem` |  |

Notable signatures:

```lua
exports['lxr-core']:GetPlayer(sourceOrIdentifier)            -- Player | nil
exports['lxr-core']:Login(source, citizenid | false, newData)  -- bool
exports['lxr-core']:AddMoney(source, account, amount, reason)  -- ok, err
exports['lxr-core']:TransferMoney(from, to, account, amount, reason)
exports['lxr-core']:AddPlayerItem(source, name, amount, slot, info, reason)   -- inventory (player)
exports['lxr-core']:AddItem(name, definition)                  -- registry (RSG semantics)
exports['lxr-core']:CreateCallback(name, function(source, cb, ...) end)
exports['lxr-core']:RegisterCallback(name, function(source, ...) return ... end)
exports['lxr-core']:AwaitClientCallback(name, source, ...)
exports['lxr-core']:AddCommand(name, help, args, argsRequired, cb, permission)
exports['lxr-core']:RegisterMigration(resource, name, sql)
exports['lxr-core']:RegisterCharacterTable(table, column)
exports['lxr-core']:Notify(source, message, type, duration)
exports['lxr-core']:GetVorpCore()                              -- VORP facade (server & client)
```

## Client (62)

| | | | |
|---|---|---|---|
| `AttachProp` | `AwaitCallback` | `CreateBlip` | `CreateClientCallback` |
| `Debug` | `DeleteBlip` | `DeleteVehicle` | `DisplayRightText` |
| `DrawText` | `GenerateCSRFToken` | `GetClosestObject` | `GetClosestPed` |
| `GetClosestPlayer` | `GetClosestVehicle` | `GetConfig` | `GetCoords` |
| `GetCore` | `GetCoreObject` | `GetGangs` | `GetHorses` |
| `GetItems` | `GetJobs` | `GetPeds` | `GetPlate` |
| `GetPlayerData` | `GetPlayersFromCoords` | `GetVehicles` | `GetVorpCore` |
| `GetWeapons` | `HasItem` | `IsLoggedIn` | `KeyPressed` |
| `LoadModel` | `Notify` | `PlayAnim` | `Progressbar` |
| `RandomInt` | `RandomStr` | `RegisterClientCallback` | `RegisterPrompt` |
| `RemovePed` | `Round` | `ShowAdvancedLeftNotification` | `ShowAdvancedRightNotification` |
| `ShowBasicTopNotification` | `ShowLocationNotification` | `ShowObjective` | `ShowSimpleCenterText` |
| `ShowSimpleTopNotification` | `ShowTooltip` | `ShowTopNotification` | `SpawnPed` |
| `SpawnVehicle` | `SplitStr` | `TriggerCallback` | `Trim` |
| `createPrompt` | `createPromptGroup` | `deletePrompt` | `deletePromptGroup` |
| `getPrompt` | `getPromptGroup` |  |  |

Notable signatures:

```lua
exports['lxr-core']:GetPlayerData()                             -- table
exports['lxr-core']:TriggerCallback(name, cb, ...)
exports['lxr-core']:AwaitCallback(name, ...)
exports['lxr-core']:Notify(text, type, duration)                -- or table, or legacy (id, text, duration, subtext, dict, icon, color)
exports['lxr-core']:createPrompt(name, coords, key, label, options, marker)
exports['lxr-core']:createPromptGroup(name, label, coords, prompts, distance)
exports['lxr-core']:Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
exports['lxr-core']:ShowAdvancedLeftNotification(title, subtitle, dict, icon, duration, color)
```
