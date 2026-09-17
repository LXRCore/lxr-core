<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# LXR-CORE — Compatibility Matrix

"Adapter" means LXRCore reproduces the API shape so the resource runs
unmodified. "Tested" is only marked after a real run; the offline suite
(`tests/test_compat.lua`) verifies the API surface and event wiring, not
in-game behaviour.

| System | Native | Adapter | Offline suite | In-game tested |
|---|---:|---:|---:|---:|
| LXRCore v3 resources | YES | N/A | YES | NOT TESTED |
| LXR v1/v2 & QBR resources (`exports['lxr-core']:GetPlayer` style) | NO | YES — `server/compat/legacy.lua`, `bridges/qbr-core` | YES | NOT TESTED |
| RSG-Core resources | NO | YES — `server/compat/rsg.lua`, `client/compat/rsg.lua`, `bridges/rsg-core` | YES | NOT TESTED |
| rsg-inventory as provider | NO | YES — `Config.Inventory.providers` | NO | NOT TESTED |
| VORP resources | NO | PARTIAL — `server/compat/vorp.lua`, `client/compat/vorp.lua`, `bridges/vorp_core` | YES (facade) | NOT TESTED |
| vorp_inventory API | NO | PARTIAL (item subset) — `bridges/vorp_inventory` | NO | NOT TESTED |
| QR-Core | NO | via QBR shim (same export names) | NO | NOT TESTED |
| Standalone | N/A | N/A | – | – |

## What each adapter covers

### RSG-Core
* `exports['rsg-core']:GetCoreObject()` → LXRCore (through the shim resource).
* `RSGCore.Functions.*`, `RSGCore.Player.*`, `Player.Functions.*` — same names, see `docs/api.md`.
* Events: every `LXRCore:*` lifecycle event is mirrored to `RSGCore:*`; client `RSGCore:Client:OnPlayerLoaded` from rsg-spawn is accepted.
* Callbacks: `RSGCore:Server:TriggerCallback` / `RSGCore:Client:TriggerCallback` name-keyed protocol answered.
* ACE: `rsgcore.<group>` principals inherit `lxrcore.<group>` so an RSG `server.cfg` works unchanged.
* `players` / `bans` tables keep the RSG column layout.
* Not covered: `ox_lib` (declare it in your server if RSG resources need it), RSG-only tables (`playerskins`, `player_horses`, …) which the owning RSG resource creates itself.

### VORP
* `exports.vorp_core:GetCore()` → facade with `getUser`, `getUsers`, `getUserByCharId`, `maxCharacters`, 19 `Notify*` functions, `Callback.Register/TriggerAsync/TriggerAwait`, `Player.Heal/Revive/Respawn`, `RegisterJobs/GetRegisteredJobs`, `AddWebhook`.
* `getUsedCharacter` snapshot: `identifier, charIdentifier, group, job, jobLabel, jobGrade, money, gold, rol, xp, firstname, lastname, coords, isdead, age, gender, invCapacity, skills` + closures `addCurrency(0|1|2, n)`, `removeCurrency`, `setMoney/Gold/Rol`, `setJob`, `setJobGrade`, `addXp/removeXp/setXp`, `setFirstname/…`, `setStatus`, `updateInvCapacity`.
* Currency ids: 0 cash, 1 gold, 2 → `Config.Compat.vorp.rolAccount`.
* Events: `vorp:SelectedCharacter` (server + client), `vorp:TriggerServerCallback` / `vorp:ServerCallback`, `vorp:*` notification events on the client; state bags `IsInSession`, `Character`.
* Not covered (returns nil/false and logs once): `setGroup` (groups are ACE), whitelist API, skin/comps storage, `vorp_inventory` weapon and custom-inventory APIs, direct SQL against `characters` / `users`.

### Legacy LXR (v1/v2) & QBR
* The full export-per-function surface (`GetPlayer`, `GetLXRPlayers`, `CreateCallback`, `TriggerCallback`, `CreateUseableItem`, `AddCommand`, `Login`, `Logout`, `DeleteCharacter`, `HasPermission`, `Notify`, `Progressbar`, `createPrompt`, `Show*Notification`, …) — see `docs/exports.md`.
* `LXRCore:*` event names unchanged. `LXRCore:Notify` accepts the old numeric-id signature.
* Old client-triggerable item/XP events are disabled (they were exploitable).

## Bridge resources

Copy the folders from `bridges/` to `resources/[lxr-bridges]/` **only when the
real resource is not installed**, and `ensure` them after `lxr-core`:

| Folder | Provides |
|---|---|
| `rsg-core` | `GetCoreObject`, registry exports, `GenerateCSRFToken` |
| `vorp_core` | `GetCore`, `getCore` event, VORP client notification exports |
| `qbr-core` | every QBR export forwarded by name |
| `vorp_inventory` | item subset of the vorp_inventory exports |
