--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Framework Configuration

    This file is the server owner's control panel for the LXRCore framework.
    Every tunable — accounts, character defaults, permissions, save intervals,
    security limits, compatibility adapters and logging — lives here. Nothing in
    server/ or client/ needs to be edited for ordinary configuration.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves 🐺
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/ZHMKVYyhBa (development)
    Community:   https://discord.gg/wolvesland
    GitHub:      https://github.com/LXRCore

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 3.0.0
    Performance Target: 0.00 ms idle client, event-driven server

    Framework Support:
    - LXR Core (Native)
    - RSG Core resources (Adapter)
    - VORP Core resources (Adapter)
    - QBR Core resources (Adapter)
    - Standalone (Compatible)

    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════

    Script Author: iBoss21 / LXRCore

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE CONFIGURATION ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Lang = 'en' -- Any file in locales/ ('en', 'ka', ...). Missing keys fall back to English.

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ GENERAL SETTINGS ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.General = {
    maxPlayers        = GetConvarInt('sv_maxclients', 48),
    defaultSpawn      = vector4(-1035.71, -2731.87, 12.86, 0.0), -- Fallback spawn when a character has no saved position
    saveInterval      = 5,     -- Minutes between periodic character saves (only dirty players are written)
    hidePlayerNames   = true,  -- Replace overhead names with "Stranger (id)"
    revealMap         = true,  -- Remove fog of war on login
    enablePVP         = true,  -- Friendly fire between players
    paycheck = {
        enabled         = true,
        intervalMin     = 10,      -- Minutes between paychecks
        account         = 'bank',  -- Account that receives the paycheck
        fromSociety     = false,   -- true: pay from the job society account through the banking resource below
        societyResource = 'lxr-banking',
        societyExports  = { balance = 'GetAccountBalance', remove = 'RemoveMoney' },
    },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ NOTIFICATIONS & UI ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Notify = {
    backend  = 'native',  -- 'native' (RedM feed), 'ox_lib' (lib.notify when started), 'event' (lxr-notify:client:show)
    duration = 4000,      -- Default duration in ms
}

Config.Prompts = {
    holdMs    = 1000,     -- Default hold time for hold-to-confirm prompts
    distance  = 1.5,      -- Default interaction distance (meters)
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DATABASE & PERSISTENCE ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Database = {
    autoMigrate       = true,  -- Apply database/migrations/*.sql at boot (idempotent, tracked in lxr_migrations)
    requireReady      = true,  -- Refuse connections until oxmysql is ready and migrations finished
    slowQueryMs       = 250,   -- Log queries slower than this (0 = disabled)
    relinkImportedRows = true, -- Characters imported from VORP are keyed by steam id; re-link them to the license on first login
    -- Tables that own character rows keyed by citizenid. Character deletion runs one
    -- transaction across this list; resources extend it with LXRCore.Player.RegisterCharacterTable.
    characterTables   = { 'players', 'playerskins', 'playeroutfit', 'player_horses', 'player_weapons' },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ECONOMY SETTINGS ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Money = {
    -- account = starting balance. Accounts are added to existing characters on
    -- login when missing; removing one here never deletes stored balances.
    MoneyTypes = { cash = 25, bank = 0, gold = 0, bloodmoney = 0, valbank = 0, rhobank = 0, blkbank = 0, armbank = 0 },
    DontAllowMinus  = { 'cash', 'gold', 'bloodmoney' }, -- Accounts that can never go negative
    MinusLimit      = -5000,           -- Floor for accounts that may go negative (bank overdraft)
    MaxBalance      = 1000000000,      -- Hard cap per account (protects against overflow exploits)
    IntegerAccounts = { gold = true }, -- Accounts that only accept whole numbers
    Decimals        = 2,               -- Precision for non-integer accounts
    LogThreshold    = 100000,          -- Amounts above this are flagged as "large" in logs
    Ledger = {
        enabled     = true,            -- Write every add/remove/set/transfer to lxr_ledger
        flushMs     = 2000,            -- Batched insert interval
        maxBatch    = 200,
    },
    -- RSG-style money as physical items. When enabled, cash balance is mirrored to items.
    EnableMoneyItems = false,
    MoneyItems = { cash = 'dollar', bloodmoney = 'blood_dollar' },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PLAYER & CHARACTER DEFAULTS ███████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Player = {
    maxCharacters   = 5,         -- Default character slots per license (multicharacter reads this)
    maxWeight       = 120000,    -- Default carry weight (grams) for the internal inventory provider
    maxSlots        = 41,        -- Default inventory slots for the internal inventory provider
    bloodTypes      = { 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' },
    -- Skills are stored in metadata.xp / metadata.levels (legacy LXR API AddXp/RemoveXp).
    skills          = { 'main', 'mining', 'herbalism', 'hunting', 'fishing' },
    xpPerLevel      = 50,        -- Level = floor(xp / xpPerLevel) capped at maxLevel
    maxLevel        = 20,
    -- Applied to every character on load; missing keys only, existing data is never overwritten.
    defaults = {
        cid = 1,
        optin = true,
        charinfo = {
            firstname   = 'Stranger',
            lastname    = '',
            birthdate   = '1870-01-01',
            gender      = 0,
            nationality = 'USA',
        },
        job  = { name = 'unemployed', grade = { level = 0 }, onduty = true },
        gang = { name = 'none', grade = { level = 0 } },
        metadata = {
            health = 600, hunger = 100, thirst = 100, cleanliness = 100, stress = 0,
            isdead = false, armor = 0, ishandcuffed = false, injail = 0, jailitems = {},
            status = {}, rep = {}, callsign = 'NO CALLSIGN',
            criminalrecord = { hasRecord = false },
            xp = {}, levels = {},
        },
    },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER ACCESS & PERMISSIONS ███████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Server = {
    closed                = false,          -- Only players with ace 'lxrcore.join' may connect
    closedReason          = 'Server Closed',
    whitelist             = false,          -- Require Config.Server.whitelistPermission to connect
    whitelistPermission   = 'whitelisted',
    checkDuplicateLicense = true,
    requireDiscord        = false,          -- Refuse connections without a discord identifier
    -- Permission groups. Each becomes ace 'lxrcore.<group>'. Assign in server.cfg:
    --   add_principal identifier.license:xxxx lxrcore.admin
    -- 'god' implicitly receives every command permission.
    permissions = { 'god', 'developer', 'headadmin', 'admin', 'mod', 'helper', 'whitelisted' },
}

Config.Commands = {
    oocColor = { 255, 151, 133 },
    meRange  = 12.0,   -- /me visibility radius (meters)
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ INVENTORY ABSTRACTION █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Inventory = {
    -- 'auto' picks the first started resource in `providers`, or force one provider id.
    -- 'internal' is the built-in slot inventory persisted in players.inventory (no UI).
    provider  = 'auto',
    providers = { 'lxr-inventory', 'rsg-inventory', 'vorp_inventory', 'internal' },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SHARED CATALOG (items · jobs · gangs · horses …) ██████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Catalog = {
    validateOnBoot   = true,   -- Cross-check every shared/*.lua record at boot (missing ammo, bad category, …)
    failOnInvalid    = false,  -- true: refuse to accept players while the catalog has problems (strict servers)
    year             = 1899,   -- Server year. Shops hide items / weapons whose `era` is later than this
    enforceEra       = true,   -- false: ignore `era` everywhere
    contrabandSeizable = true, -- Lawmen may seize `legal = false` items (search resources read this)
    -- Skills that earn XP (Config.Player.skills is extended with these at boot)
    skills           = { 'gunslinging', 'marksman', 'cooking', 'crafting', 'horsemanship', 'trading' },
    -- Item decay: metadata.decayAt is stamped on pickup; the inventory turns the item into `decay.into` when it passes
    decay            = { enabled = true, tickMin = 10, realtimeHoursPerGameHour = 1.0 },
    -- Starter kit offered at character creation when the multicharacter UI has no kit picker
    defaultStarterKit = 'drifter',
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ COMPATIBILITY ADAPTERS ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Compat = {
    -- RSG: emit RSGCore:* events alongside LXRCore:* events, answer RSGCore callback
    -- events, create rsgcore.<group> aces. Pair with bridges/rsg-core for exports.
    rsg    = { enabled = true },
    -- VORP: vorp_core-shaped GetCore() facade (bridges/vorp_core) and vorp:* events.
    -- Currency ids: 0 cash, 1 gold, 2 rol (mapped to rolAccount).
    vorp   = { enabled = true, rolAccount = 'bloodmoney' },
    -- QBR / legacy LXR export-per-function surface (exports['lxr-core']:GetPlayer(src)).
    legacy = { enabled = true },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY & ANTI-ABUSE █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Security = {
    itemUseCooldownMs   = 300,    -- Minimum ms between two uses of the same item by one player (item `use.cooldown` may raise it)
    callbackRateLimit   = { burst = 40, windowMs = 5000 },  -- Per player, server callbacks
    callbackTimeoutMs   = 15000,   -- Pending callbacks are rejected after this
    eventRateLimit      = { burst = 60, windowMs = 5000 },  -- Per player, validated net events
    -- Metadata keys a client may set through LXRCore:Server:SetMetaData. Everything
    -- else must be set by a server-side resource. Keep this list short.
    clientMetadataWhitelist = { 'hunger', 'thirst', 'cleanliness', 'stress' },
    kickOnExploit       = true,    -- Drop players that trigger integrity failures
    logExploits         = true,
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PERFORMANCE OPTIMIZATION ██████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Performance = {
    saveBatchSize     = 25,     -- Players written per save tick to spread DB load
    saveBatchDelayMs  = 50,
    playerDataSyncMs  = 100,    -- Debounce for LXRCore:Player:SetPlayerData pushes (coalesces bursts)
    metrics           = true,   -- Track counters (LXRCore.Metrics) exposed through /lxr:metrics
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LOGGING & OBSERVABILITY ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Log = {
    level     = 'info',   -- 'debug' | 'info' | 'warn' | 'error'
    console   = true,
    -- Forward structured logs as the ecosystem-standard event (lxr-log / rsg-log listen to it):
    --   TriggerEvent('lxr-log:server:CreateLog', channel, title, color, message, tagEveryone)
    forwardEvent    = 'lxr-log:server:CreateLog',
    forwardRsgEvent = true, -- also fire 'rsg-log:server:CreateLog' when Compat.rsg is enabled
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG SETTINGS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.Debug = {
    enabled     = false,  -- Verbose tracing of player lifecycle and callbacks
    printBanner = true,   -- Console banner at boot
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ END OF CONFIGURATION ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Backwards-compatible alias used by legacy LXR / QBR resources (exports GetConfig).
LXRConfig = Config
LXRCore.Config = Config
