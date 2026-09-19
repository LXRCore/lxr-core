--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - RedM Framework Resource Manifest

    LXRCore is the canonical framework layer for RedM servers: player and character
    lifecycle, accounts, jobs, gangs, permissions, callbacks, usable items, an
    inventory abstraction and compatibility adapters for RSG-Core, VORP and QBR
    resources. This manifest declares load order and dependencies; every tunable
    lives in config.lua.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves 🐺
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    Community:   https://discord.gg/wolvesland
    GitHub:      https://github.com/LXRCore

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 3.0.0
    Performance Target: 0.00 ms idle client, event-driven server (no polling loops)

    Framework Support:
    - LXR Core (Native)
    - RSG Core resources (Adapter: bridges/rsg-core)
    - VORP Core resources (Adapter: bridges/vorp_core + bridges/vorp_inventory)
    - QBR Core resources (Adapter: bridges/qbr-core)
    - Standalone resources (Compatible)

    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════

    Script Author: iBoss21 / LXRCore
    Architecture: independent implementation; API shapes kept compatible with the
    RedM ecosystem (see THIRD_PARTY_NOTICES.md)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

fx_version '3.0.0'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'lxr-core'
author 'iBoss21 / LXRCore'
description 'LXRCore v3 — production RedM framework core with RSG / VORP / QBR compatibility adapters'
version '3.0.2'
repository 'https://github.com/LXRCore/lxr-core'
lxr_core_api '3'

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📦 SHARED SCRIPTS — load order matters: locale engine → config → shared data
-- ═══════════════════════════════════════════════════════════════════════════════

shared_scripts {
    'shared/main.lua',
    'shared/locale.lua',
    'locales/*.lua',
    'config.lua',
    'shared/catalog.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/gangs.lua',
    'shared/weapons.lua',
    'shared/horses.lua',
    'shared/vehicles.lua',
    'shared/prices.lua',
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💻 CLIENT SCRIPTS
-- ═══════════════════════════════════════════════════════════════════════════════

client_scripts {
    'client/main.lua',
    'client/callbacks.lua',
    'client/notify.js',
    'client/notify.lua',
    'client/functions.lua',
    'client/prompts.lua',
    'client/drawtext.lua',
    'client/events.lua',
    'client/gameevents.lua',
    'client/api.lua',
    'client/compat/rsg.lua',
    'client/compat/vorp.lua',
    'client/compat/legacy.lua',
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🖥️  SERVER SCRIPTS — log → database → engines → player → net events → exports
-- ═══════════════════════════════════════════════════════════════════════════════

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/log.lua',
    'server/emit.lua',
    'server/database.lua',
    'server/callbacks.lua',
    'server/permissions.lua',
    'server/commands.lua',
    'server/roles.lua',
    'server/accounts.lua',
    'server/items.lua',
    'server/player.lua',
    'server/events.lua',
    'server/exports.lua',
    'server/api.lua',
    'server/compat/rsg.lua',
    'server/compat/vorp.lua',
    'server/compat/legacy.lua',
    'server/boot.lua',
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📁 FILES — the shared catalog is readable by every resource that imports it
--    (shared_scripts { '@lxr-core/shared/import.lua', … } — see shared/import.lua)
-- ═══════════════════════════════════════════════════════════════════════════════

files {
    'shared/import.lua',
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

dependencies {
    '/server:7290',
    '/onesync',
    'oxmysql',
}
