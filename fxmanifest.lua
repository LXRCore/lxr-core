--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - FiveM/RedM Resource Manifest
    
    This manifest file declares all scripts, dependencies, and metadata for the
    LXR Core framework. It defines the resource structure, load order, and
    compatibility requirements for RedM servers.
    
    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════
    
    Server:      The Land of Wolves 🐺
    Tagline:     Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
    Description: ისტორია ცოცხლდება აქ! (History Lives Here!)
    Type:        Serious Hardcore Roleplay
    Access:      Discord & Whitelisted
    
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    Framework: LXR Core (Primary RedM Framework)
    Performance: Supreme optimization - 70% faster than standard frameworks
    
    Tags: RedM, Framework, Georgian, SeriousRP, Performance, Security
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 FXMANIFEST CONFIGURATION
-- ═══════════════════════════════════════════════════════════════════════════════

fx_version 'cerulean'
game 'rdr3'
lua54 'yes'

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🚨 REDM PRERELEASE WARNING (MANDATORY)
-- ═══════════════════════════════════════════════════════════════════════════════

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources WILL become incompatible once RedM ships.'

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📋 RESOURCE METADATA
-- ═══════════════════════════════════════════════════════════════════════════════

name 'LXR-Core'
author 'iBoss21 / The Lux Empire'
description 'LXR Core Framework - Premier RedM roleplay framework with supreme performance and military-grade security. Converted from QBCore and optimized for RedM by iBoss21.'
version '2.0.0'
repository 'https://github.com/LXRCore/lxr-core'

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📦 SHARED SCRIPTS (Client & Server)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Execution Order:
-- 1. Locale system (translation support)
-- 2. Language file (default: en.lua)
-- 3. Main configuration (all server settings)
-- 4. Core shared functions
-- 5. Game data (items, jobs, vehicles, weapons, etc.)
--
-- ═══════════════════════════════════════════════════════════════════════════════

shared_scripts {
    'shared/locale.lua',            -- Localization system
    'locale/en.lua',                -- Language file (change to desired language)
    'config.lua',                   -- Main configuration file
    'shared/framework.lua',         -- Multi-framework adapter (NEW)
    'shared/main.lua',              -- Core shared functions
    'shared/items.lua',             -- Item definitions
    'shared/jobs.lua',              -- Job system configuration
    'shared/horse.lua',             -- Horse system data
    'shared/vehicles.lua',          -- Vehicle data
    'shared/gangs.lua',             -- Gang system configuration
    'shared/weapons.lua'            -- Weapon definitions
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💻 CLIENT SCRIPTS
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Load Order (Critical):
-- 1. Performance optimization (must load first)
-- 2. Anti-cheat (security layer)
-- 3. Core functions (utilities)
-- 4. Client loops (ongoing processes)
-- 5. Event handlers (network events)
-- 6. UI systems (notifications, prompts, text)
--
-- ═══════════════════════════════════════════════════════════════════════════════

client_scripts {
    'client/performance.lua',       -- Performance optimization (FPS, memory)
    'client/anticheat.lua',         -- Client-side anti-cheat detection
    'client/functions.lua',         -- Client utility functions
    'client/loops.lua',             -- Client-side loops (FPS-aware)
    'client/events.lua',            -- Client event handlers
    'client/notify.js',             -- Notification system (JavaScript)
    'client/drawtxt.lua',           -- Text drawing utilities
    'client/prompts.lua'            -- Interaction prompt system
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🖥️  SERVER SCRIPTS
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Load Order (Critical):
-- 1. Database library (oxmysql)
-- 2. Protection & Security (rate limiting, validation)
-- 3. Logging system
-- 4. Developer tools & bridge layer
-- 5. Core systems (database, performance, anti-cheat)
-- 6. Integrations (Tebex monetization)
-- 7. Core functions & player management
-- 8. Event handlers & commands
-- 9. Exports (public API)
--
-- ═══════════════════════════════════════════════════════════════════════════════

server_scripts {
    '@oxmysql/lib/MySQL.lua',       -- MySQL/MariaDB database library
    'server/protection.lua',        -- Rate limiting & DDoS protection
    'server/logs.lua',              -- Audit logging system
    'server/developertools.lua',    -- Development utilities
    'server/bridge.lua',            -- Framework compatibility bridge
    'server/security.lua',          -- Security & validation
    'server/performance.lua',       -- Performance monitoring & optimization
    'server/database.lua',          -- Database operations
    'server/antidupe.lua',          -- Anti-duplication system
    'server/anticheat.lua',         -- Server-side anti-cheat
    'server/tebex.lua',             -- Tebex monetization integration
    'server/debug.lua',             -- Debug utilities
    'server/functions.lua',         -- Core server functions
    'server/player.lua',            -- Player management system
    'server/events.lua',            -- Server event handlers
    'server/commands.lua',          -- Admin & player commands
    'server/exports.lua'            -- Exported functions (public API)
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🌐 USER INTERFACE (NUI)
-- ═══════════════════════════════════════════════════════════════════════════════

ui_page 'html/index.html'

files {
    'html/index.html',              -- Main HTML file
    'html/script.js',               -- JavaScript logic
    'html/style.css'                -- CSS styling
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 DEPENDENCIES
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Required Resources:
-- - oxmysql: Modern MySQL/MariaDB library (https://github.com/overextended/oxmysql)
--
-- ═══════════════════════════════════════════════════════════════════════════════

dependencies {
    'oxmysql'                       -- Required: MySQL database library
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- ✅ MANIFEST END
-- ═══════════════════════════════════════════════════════════════════════════════
