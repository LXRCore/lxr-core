--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared import for other resources
     ═══════════════════════════════════════════════════════════════════════════
     Every resource runs in its own Lua VM: the catalog the core loaded is not
     visible there. One manifest line brings `LXRShared` (items, jobs, gangs,
     weapons, horses, wagons, prices and the helpers) into a resource, on both
     sides, without that resource listing the core's files itself:

         shared_scripts { '@lxr-core/shared/import.lua', 'config.lua', ... }

     It reads the core's shared data files through LoadResourceFile and runs
     them here, so the tables are real Lua tables (no export copies, no
     cross-resource calls). The list below is owned by the core; the core's
     own `config.lua` and locale files are deliberately not part of it — a
     resource keeps its own `Config`, `Locale` and `Lang`.

     What a resource sees is the catalog as shipped on disk. Items added at
     runtime through LXRCore.Functions.AddItem exist in the core only.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if LXRShared and LXRShared.Items and next(LXRShared.Items) then return end -- already here (the core itself, or imported twice)

local FILES = {
    'shared/main.lua',
    'shared/catalog.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/gangs.lua',
    'shared/weapons.lua',
    'shared/horses.lua',
    'shared/vehicles.lua',
    'shared/prices.lua',
}

local here = GetCurrentResourceName()
for _, path in ipairs(FILES) do
    local code = LoadResourceFile('lxr-core', path)
    if not code then
        error(('[lxr-core import] %s cannot read @lxr-core/%s — is lxr-core started before %s?'):format(here, path, here))
    end
    local chunk, err = load(code, '@lxr-core/' .. path)
    if not chunk then error(('[lxr-core import] %s: %s'):format(path, err)) end
    chunk()
end
