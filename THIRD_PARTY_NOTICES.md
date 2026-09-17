# Third-party notices

LXRCore v3 is an independent implementation. No source code from the projects
below is included. They are listed because LXRCore deliberately reproduces the
*shape* of their public APIs (function names, argument orders, event names,
table layouts) so that resources written for them can run on LXRCore.

| Project | Licence | What LXRCore reproduces |
|---|---|---|
| RSG-Core (Rexshack-RedM) | GPL-3.0 | `GetCoreObject()` object layout, `Player.Functions.*` method names, `RSGCore:*` event names, `players`/`bans` column shape |
| VORP Core (VORPCORE) | GPL-2.0 | `GetCore()` facade names (`getUser`, `getUsedCharacter`, `Callback.*`, `Notify*`), `vorp:*` event names |
| QBR-Core (qbcore-redm) / QBCore | GPL-3.0 | export-per-function names (`GetPlayer`, `CreateCallback`, …), `LXRCore:*` legacy event names inherited by LXR v1/v2 |
| oxmysql (CommunityOx) | LGPL-3.0 | consumed as a dependency through `@oxmysql/lib/MySQL.lua`; not bundled |

RDR3 native hashes and struct layouts used in `client/notify.js` come from the
public Cfx.re native reference.

Previous LXRCore releases (v1.x / v2.x) were derived from QBR-Core and were
distributed under GPL-3.0. This release replaces that code base entirely.
