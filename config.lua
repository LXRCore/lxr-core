--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - Framework Configuration
    
    This configuration file is the central control system for LXR Core - the premier
    RedM roleplay framework. All server settings, economy systems, framework support,
    and gameplay mechanics are configured here. This is the ONLY file server owners
    need to edit for most configurations.
    
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
    Server:      https://servers.redm.net/servers/detail/8gj7eb
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    Performance Target: Supreme performance - 70% faster than standard frameworks
    
    Tags: RedM, Georgian, SeriousRP, Whitelist, Framework, Economy, RPG, Security
    
    Framework Support:
    - LXR Core (Primary - This Framework)
    - RSG Core (Compatible via Bridge)
    - VORP Core (Compatible via Bridge)
    - RedEM:RP (Optional - if detected)
    - QBR Core (Optional - if detected)
    - QR Core (Optional - if detected)
    - Standalone Mode (Fallback)
    
    ═══════════════════════════════════════════════════════════════════════════════
    CREDITS
    ═══════════════════════════════════════════════════════════════════════════════
    
    Lead Developer: iBoss21 / The Lux Empire for The Land of Wolves
    Original Framework: QBCore (Converted for RedM)
    Performance Optimization: iBoss21
    Security Hardening: iBoss21
    Georgian Localization: wolves.land Community
    
    Special Thanks:
    - QBCore Team for the original FiveM framework
    - RedM Community for feedback and testing
    - wolves.land Staff and Players
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION - RUNTIME CHECK
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = "lxr-core"
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[
        
        ═══════════════════════════════════════════════════════════════════════════════
        ❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
        ═══════════════════════════════════════════════════════════════════════════════
        
        Expected: %s
        Got: %s
        
        This resource is branded and must maintain the correct name.
        Rename the folder to "%s" to continue.
        
        🐺 wolves.land - The Land of Wolves
        
        ═══════════════════════════════════════════════════════════════════════════════
        
    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME))
end

LXRConfig = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.ServerInfo = {
    name = 'The Land of Wolves 🐺',
    tagline = 'Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!',
    description = 'ისტორია ცოცხლდება აქ!', -- History Lives Here!
    type = 'Serious Hardcore Roleplay',
    access = 'Discord & Whitelisted',
    
    -- Contact & Links
    website = 'https://www.wolves.land',
    discord = 'https://discord.gg/CrKcWdfd3A',
    github = 'https://github.com/iBoss21',
    store = 'https://theluxempire.tebex.io',
    serverListing = 'https://servers.redm.net/servers/detail/8gj7eb',
    
    -- Developer Info
    developer = 'iBoss21 / The Lux Empire',
    
    -- Tags
    tags = {'RedM', 'Georgian', 'SeriousRP', 'Whitelist', 'Framework', 'Economy', 'RPG', 'Security'}
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXR-Core (Primary - This Framework)
    2. RSG-Core (Compatible)
    3. VORP Core (Compatible)
    4. RedEM:RP (Optional - if detected)
    5. QBR-Core (Optional - if detected)
    6. QR-Core (Optional - if detected)
    7. Standalone (Fallback)
]]

LXRConfig.Framework = 'lxr-core' -- This IS lxr-core, but other resources can detect: 'lxr-core', 'rsg-core', 'vorp_core', etc.

-- Framework-specific settings for multi-framework resources
LXRConfig.FrameworkSettings = {
    ['lxr-core'] = {
        resource = 'lxr-core',
        notifications = 'ox_lib', -- notification system to use
        inventory = 'lxr-inventory',
        target = 'ox_target',
        -- Event naming convention
        events = {
            server = 'lxr-core:server:%s',
            client = 'lxr-core:client:%s',
            callback = 'lxr-core:callback:%s'
        }
    },
    ['rsg-core'] = {
        resource = 'rsg-core',
        notifications = 'ox_lib',
        inventory = 'rsg-inventory',
        target = 'ox_target',
        events = {
            server = 'RSGCore:Server:%s',
            client = 'RSGCore:Client:%s',
            callback = 'RSGCore:Callback:%s'
        }
    },
    ['vorp_core'] = {
        resource = 'vorp_core',
        notifications = 'vorp',
        inventory = 'vorp_inventory',
        target = 'vorp_target',
        events = {
            server = 'vorp:%s',
            client = 'vorp:%s',
            callback = 'vorp:callback:%s'
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE & LOCALE █████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Lang = 'en' -- Available: en, es, fr, de, ru, pt, it, tr, zh, ja, ko, ar, pl, ka (Georgian)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER SETTINGS ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Maximum players allowed on the server
-- Note: Set this to match your server.cfg sv_maxclients
LXRConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48)

-- Default spawn location when player first joins
-- Format: vector4(x, y, z, heading)
LXRConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)

-- How often to save player data (in minutes)
-- Lower = more frequent saves but more database load
-- Recommended: 5-10 minutes
LXRConfig.UpdateInterval = 5

-- Enable/disable PVP on the server
-- true = Players can damage each other
-- false = PVE only server
LXRConfig.EnablePVP = true

-- Your Discord invite link (shown on kick messages)
LXRConfig.Discord = "https://discord.gg/CrKcWdfd3A"

-- Close server to public (only admins with 'lxradmin.join' can connect)
LXRConfig.ServerClosed = false
LXRConfig.ServerClosedReason = "Server Closed for Maintenance"

-- Use connectqueue resource for queue system
LXRConfig.UseConnectQueue = true

-- Permission groups (add as many as needed)
-- Players are assigned to these groups via ACE permissions
LXRConfig.Permissions = {'god', 'admin', 'mod', 'support'}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CURRENCY & MONEY SYSTEM ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Currency Types:
    - tangible = true: Physical items that take inventory space (can be stolen/dropped)
    - tangible = false: Account-based money (cannot be stolen directly)
    - hidden = true: Hidden from standard displays (for admin/special currencies)
    - canMinus = false: Cannot go negative (like cash in hand)
    
    1899 Economy Standards:
    - Average worker: $0.50-1.50 per day
    - Skilled worker: $2-3 per day  
    - Professional: $4-6 per day
    - Gold: $20 per ounce (historical)
    - Most items: $0.05-0.50
]]

LXRConfig.Money = {}

-- Main Currency Types
LXRConfig.Money.MoneyTypes = {
    -- ============ Standard Currencies ============
    cash = {
        label = 'Cash Dollars',
        startAmount = 2,            -- Start with $2 (2 day's wages)
        tangible = true,            -- Physical item (can be stolen)
        canMinus = false,           -- Cannot go negative
        icon = 'dollar',            -- Icon name for UI
        weight = 0,                 -- Weight per unit (grams)
        maxCarry = 5000,            -- Max $5000 cash (very heavy)
        description = 'Paper money used for everyday transactions',
        paycheck = true,            -- Can receive paycheck in this currency
        hidden = false              -- Show in standard UI
    },
    
    bank = {
        label = 'Bank Account',
        startAmount = 5,            -- Start with $5 in bank
        tangible = false,           -- Account-based (cannot be stolen directly)
        canMinus = false,
        icon = 'bank',
        weight = 0,
        maxCarry = 999999,          -- Virtually unlimited
        description = 'Money stored safely in the bank',
        paycheck = true,
        hidden = false
    },
    
    -- ============ Precious Metals ============
    gold = {
        label = 'Gold Bars',
        startAmount = 0,
        tangible = true,            -- Physical gold bars
        canMinus = false,
        icon = 'gold_bar',
        weight = 1000,              -- 1kg per gold bar
        maxCarry = 50,              -- Max 50 gold bars (very heavy!)
        description = 'Pure gold bars - highly valuable and heavy',
        paycheck = false,
        hidden = false,
        valueInDollars = 25         -- Each gold bar worth $25 (1oz = $20 historical)
    },
    
    goldcurrency = {
        label = 'Gold Currency',
        startAmount = 0,
        tangible = false,           -- Account-based gold like VORP
        canMinus = false,
        icon = 'gold_coin',
        weight = 0,
        maxCarry = 999999,
        description = 'Gold-backed premium currency - purchased with real money',
        paycheck = false,
        hidden = false,
        valueInDollars = 0,         -- Premium currency - not directly convertible
        tebexPurchasable = true     -- Can be bought via Tebex
    },
    
    -- ============ Coins System ============
    coins = {
        label = 'Coins',
        startAmount = 50,           -- Start with 50 cents
        tangible = true,
        canMinus = false,
        icon = 'coins',
        weight = 0.01,              -- Very light (1 gram per 100 coins)
        maxCarry = 10000,
        description = 'Small denomination coins for minor purchases',
        paycheck = true,
        hidden = false,
        valueInDollars = 0.01       -- 100 coins = $1
    },
    
    goldcoins = {
        label = 'Gold Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'gold_coin',
        weight = 25,                -- Heavy coins
        maxCarry = 200,
        description = 'Rare gold coins used for valuable transactions',
        paycheck = false,
        hidden = false,
        valueInDollars = 5          -- 1 gold coin = $5 (quarter ounce)
    },
    
    silvercoins = {
        label = 'Silver Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'silver_coin',
        weight = 10,
        maxCarry = 500,
        description = 'Silver coins used for medium-value transactions',
        paycheck = false,
        hidden = false,
        valueInDollars = 1          -- 1 silver coin = $1 (silver dollar)
    },
    
    -- ============ Special Faction Coins ============
    marshalcoins = {
        label = 'Marshal Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'marshal_badge',
        weight = 5,
        maxCarry = 100,
        description = 'Special currency earned by law enforcement',
        paycheck = false,
        hidden = false,
        valueInDollars = 2,         -- 1 marshal coin = $2
        restricted = {
            jobs = {'police', 'marshal', 'ranger'},
            description = 'Law enforcement only'
        }
    },
    
    trustcoins = {
        label = 'Trust Coins',
        startAmount = 0,
        tangible = false,           -- Reputation-based currency
        canMinus = false,
        icon = 'trust_badge',
        weight = 0,
        maxCarry = 1000,
        description = 'Trust currency earned through reputation',
        paycheck = false,
        hidden = false,
        valueInDollars = 0,         -- Cannot be converted to dollars
        earnRate = {
            enabled = true,
            method = 'activity',    -- Earned through gameplay
            perHour = 1             -- 1 trust coin per hour of gameplay
        }
    },
    
    -- ============ Precious Gems ============
    diamonds = {
        label = 'Diamonds',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'diamond',
        weight = 10,
        maxCarry = 50,
        description = 'Extremely rare and valuable diamonds',
        paycheck = false,
        hidden = false,
        valueInDollars = 50         -- 1 diamond = $50 (very rare)
    },
    
    -- ============ Blood Money System ============
    bloodmoney = {
        label = 'Blood Money',
        startAmount = 0,
        tangible = true,            -- Dirty cash that must be laundered
        canMinus = false,
        icon = 'blood_dollar',
        weight = 0,
        maxCarry = 2500,
        description = 'Illegally obtained cash - must be laundered to use',
        paycheck = false,
        hidden = false,
        needsLaundering = true,     -- Must be converted to clean money
        launderRate = 0.6,          -- 60% conversion rate (40% lost to laundering)
        detectRisk = 0.35           -- 35% chance of detection per transaction
    },
    
    bloodcoins = {
        label = 'Blood Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'blood_coin',
        weight = 0.2,
        maxCarry = 1000,
        description = 'Illegally obtained coins - highly suspicious',
        paycheck = false,
        hidden = false,
        needsLaundering = true,
        launderRate = 0.5,          -- 50% conversion rate
        detectRisk = 0.45,          -- 45% detection risk
        valueInDollars = 0.5
    },
    
    -- ============ Tokens System ============
    tokens = {
        label = 'Premium Tokens',
        startAmount = 0,
        tangible = false,           -- Premium currency (donation/reward)
        canMinus = false,
        icon = 'token',
        weight = 0,
        maxCarry = 99999,
        description = 'Premium tokens used in special shops - purchased with real money',
        paycheck = false,
        hidden = false,
        valueInDollars = 0,         -- Cannot buy with regular money
        tebexPurchasable = true,    -- Can be bought via Tebex
        earnMethods = {
            donation = true,        -- Can be purchased with real money
            events = true,          -- Can be earned in events
            daily = 1,              -- 1 free token per day
            playtime = {
                enabled = true,
                hours = 24,         -- Every 24 hours of playtime
                amount = 5          -- Earn 5 tokens
            }
        }
    },
    
    rewardtokens = {
        label = 'Reward Tokens',
        startAmount = 0,
        tangible = false,
        canMinus = false,
        icon = 'reward_token',
        weight = 0,
        maxCarry = 99999,
        description = 'Earned through achievements and milestones',
        paycheck = false,
        hidden = false,
        valueInDollars = 0
    },
    
    -- ============ Historical Currencies ============
    promisarynotes = {
        label = 'Promissory Notes',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'promissory_note',
        weight = 1,
        maxCarry = 200,
        description = 'Historical IOU notes - can be redeemed at banks',
        paycheck = false,
        hidden = false,
        valueInDollars = 10,        -- Each note worth $10
        redeemable = {
            enabled = true,
            locations = {'bank'},   -- Can only redeem at bank
            fee = 0.02              -- 2% redemption fee
        }
    }
}

-- Currency exchange rates and conversion
LXRConfig.Money.Exchange = {
    enabled = true,
    locations = {'bank'},           -- Where currency exchange is available
    
    -- Conversion rates (from -> to)
    rates = {
        ['cash'] = {
            ['bank'] = 1.0,         -- $1 cash = $1 bank (no fee for deposits)
            ['goldcoins'] = 0.2,    -- $1 cash = 0.2 gold coins ($5 per gold coin)
            ['silvercoins'] = 1.0   -- $1 cash = 1 silver coin
        },
        ['bank'] = {
            ['cash'] = 0.98,        -- $1 bank = $0.98 cash (2% withdrawal fee)
            ['goldcoins'] = 0.19,   -- Slight fee for gold exchange
            ['silvercoins'] = 0.99  -- Minimal fee
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PLAYER SETTINGS ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Player = {}

-- Starting inventory (items given to new characters)
LXRConfig.Player.StartingItems = {
    {item = 'bread', amount = 3},
    {item = 'water', amount = 3},
    {item = 'torch', amount = 1}
}

-- Player status system (hunger, thirst, etc.)
LXRConfig.Player.Status = {
    enabled = true,
    
    -- Decay rates (per minute)
    decay = {
        hunger = 0.5,           -- Lose 0.5 hunger per minute
        thirst = 0.7,           -- Lose 0.7 thirst per minute (faster than hunger)
        stress = -0.2           -- Stress naturally decreases
    },
    
    -- Death thresholds
    thresholds = {
        hunger = 10,            -- Die if hunger drops below 10
        thirst = 5              -- Die if thirst drops below 5 (more critical)
    }
}

-- Starting position options
LXRConfig.Player.SpawnLocations = {
    {label = 'Valentine', coords = vector4(-275.46, 805.17, 119.38, 0.0)},
    {label = 'Blackwater', coords = vector4(-813.97, -1324.19, 43.88, 0.0)},
    {label = 'Saint Denis', coords = vector4(2635.03, -1312.74, 51.42, 0.0)},
    {label = 'Tumbleweed', coords = vector4(-5514.56, -2906.77, -2.20, 0.0)},
    {label = 'Rhodes', coords = vector4(1225.62, -1293.82, 76.90, 0.0)},
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ INVENTORY SYSTEM ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Inventory = {
    -- Default inventory slots
    defaultSlots = 30,
    
    -- Max inventory weight (grams)
    defaultWeight = 120000,         -- 120kg default carry weight
    
    -- Weight units display
    useKilograms = true,            -- false = pounds
    
    -- Backpack system (additional slots/weight)
    backpacks = {
        ['backpack_small'] = {slots = 10, weight = 20000},      -- +10 slots, +20kg
        ['backpack_medium'] = {slots = 20, weight = 40000},     -- +20 slots, +40kg
        ['backpack_large'] = {slots = 30, weight = 60000},      -- +30 slots, +60kg
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ JOB SYSTEM ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Jobs = {}

-- Starting job for new players
LXRConfig.Jobs.DefaultJob = {
    name = 'unemployed',
    label = 'Unemployed',
    grade = 0
}

-- Paycheck system
LXRConfig.Jobs.Paychecks = {
    enabled = true,
    interval = 30,                  -- Pay every 30 minutes
    currency = 'bank',              -- Pay into bank account
    
    -- Minimum payment (for unemployed)
    minimumWage = 2,                -- $2 minimum per paycheck
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ GANG SYSTEM ███████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Gangs = {}

-- Default gang (no gang)
LXRConfig.Gangs.DefaultGang = {
    name = 'none',
    label = 'No Gang Affiliation',
    grade = 0
}

-- Gang territory system
LXRConfig.Gangs.Territory = {
    enabled = true,
    captureTime = 300,              -- 5 minutes to capture territory
    contestTime = 600,              -- 10 minute contest period
    rewards = {
        currency = 'cash',
        amount = 500                -- $500 for capturing territory
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ VEHICLE SYSTEM ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Vehicles = {}

-- Vehicle fuel system
LXRConfig.Vehicles.Fuel = {
    enabled = false,                 -- RedM doesn't typically use vehicle fuel
    startFuel = 100,
    fuelTypes = {
        'gasoline',
        'diesel'
    }
}

-- Vehicle damage system
LXRConfig.Vehicles.Damage = {
    enabled = true,
    realisticDamage = true,         -- Realistic damage calculations
    engineDamageOnFlip = true       -- Damage engine if vehicle flips
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ HORSE SYSTEM ██████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Horse = {}

-- Starting horse for new players
LXRConfig.Horse.StarterHorse = {
    enabled = true,
    model = 'A_C_Horse_Kentucky_Grey',
    saddle = 'HORSE_SADDLE_01',
}

-- Horse care system
LXRConfig.Horse.Care = {
    hunger = {
        enabled = true,
        decay = 0.3,                -- Hunger decay per minute
        items = {                   -- Items that can feed horses
            'hay',
            'apple',
            'carrot'
        }
    },
    stamina = {
        enabled = true,
        regenRate = 1.5,            -- Stamina regen per second when not sprinting
        drainRate = 3.0             -- Stamina drain per second when sprinting
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ WEAPON SYSTEM █████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Weapons = {}

-- Weapon durability
LXRConfig.Weapons.Durability = {
    enabled = true,
    degradeRate = 0.1,              -- Durability loss per shot (0.1%)
    jamChance = {
        mint = 0.001,               -- 0.1% jam chance at 100% durability
        worn = 0.10,                -- 10% jam chance at 0% durability
    }
}

-- Weapon damage multipliers
LXRConfig.Weapons.Damage = {
    headshot = 3.0,                 -- 3x damage for headshots
    bodyshot = 1.0,                 -- Normal damage
    limbshot = 0.7                  -- 70% damage for limb shots
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ KEYS & CONTROLS ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Keys = {
    -- Interaction key
    interact = 0xD9D0E1C0,          -- SPACEBAR
    
    -- Menu navigation
    menuUp = 0x911CB09E,            -- W
    menuDown = 0x4403F97F,          -- S
    menuLeft = 0xAD7FCC5B,          -- A
    menuRight = 0xB238FE0B,         -- D
    menuSelect = 0xC7B5340A,        -- ENTER
    menuBack = 0x156F7119,          -- BACKSPACE
    
    -- Inventory
    openInventory = 0xF3830D8E,     -- I
    
    -- Vehicle controls
    vehicleHorn = 0x3C3DD371,       -- H
    vehicleLights = 0x8FFC75D6,     -- L
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ CRAFTING SYSTEM ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Crafting = {
    enabled = true,
    
    -- Crafting stations
    stations = {
        {name = 'campfire', label = 'Campfire', icon = 'fire'},
        {name = 'workbench', label = 'Workbench', icon = 'tools'},
        {name = 'anvil', label = 'Anvil', icon = 'hammer'},
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ ECONOMY SETTINGS ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Economy = {
    -- Starting money (configured per currency in MoneyTypes above)
    
    -- Maximum money limits (anti-cheat)
    maxMoney = {
        cash = 50000,               -- Max $50k cash
        bank = 500000,              -- Max $500k in bank
        goldcurrency = 10000        -- Max 10k gold currency
    },
    
    -- Transaction logging
    logging = {
        enabled = true,
        threshold = 1000,           -- Log transactions over $1000
        webhook = '',               -- Discord webhook URL (optional)
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PROGRESSION SYSTEM ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Progression = {}

-- Skills system
LXRConfig.Progression.Skills = {
    enabled = true,
    
    -- Available skills
    skills = {
        'hunting',
        'fishing',
        'mining',
        'herbalism',
        'crafting',
        'cooking'
    },
    
    -- Max skill level
    maxLevel = 20,
    
    -- XP required per level
    xpPerLevel = 100                -- 100 XP per level (increases per level)
}

-- Reputation system
LXRConfig.Progression.Reputation = {
    enabled = true,
    
    -- Reputation categories
    categories = {
        'lawful',                   -- Law-abiding citizen
        'outlaw',                   -- Criminal reputation
        'trader',                   -- Merchant/trading reputation
        'bounty_hunter'             -- Bounty hunting reputation
    },
    
    -- Reputation ranges
    min = -100,
    max = 100
}

-- XP thresholds for leveling up different skills
LXRConfig.Progression.XPThresholds = {
    hunting = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    fishing = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    crafting = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    cooking = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    mining = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    herbalism = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
}

-- XP Multipliers (server-wide bonuses)
LXRConfig.Progression.XPMultiplier = {
    enabled = true,
    weekend = 1.5,                  -- 50% bonus on weekends
    event = 2.0,                    -- 100% bonus during events
    vip = 1.25,                     -- 25% bonus for VIP players
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SHOPS & TRADING ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Shops = {
    -- Which currencies are accepted in shops
    acceptedCurrencies = {
        'cash', 'coins', 'goldcoins', 'silvercoins', 'tokens'
    },
    
    -- Tax rate on purchases (goes to society/government)
    taxRate = 0.05,                 -- 5% sales tax
    
    -- Discount for paying with specific currencies
    currencyDiscounts = {
        ['goldcoins'] = 0.10,       -- 10% discount if paying with gold coins
        ['promisarynotes'] = 0.05,  -- 5% discount with promissory notes
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DATABASE TABLES ███████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.DatabaseTables = {
    players = 'players',
    player_items = 'player_items',
    player_money = 'player_money',
    player_vehicles = 'player_vehicles',
    player_horses = 'player_horses',
    player_weapons = 'player_weapons',
    jobs = 'jobs',
    gangs = 'gangs',
    societies = 'societies',
    logs = 'server_logs',
    tebex = 'tebex_transactions'
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ NOTIFICATIONS & UI ████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Notifications = {
    -- Notification system to use
    system = 'ox_lib',              -- 'ox_lib', 'vorp', 'rsg', or 'custom'
    
    -- Money notifications
    showMoneyChanges = true,
    minAmountToShow = 10,           -- Only show if amount >= $10
    
    -- Item notifications
    showItemChanges = true,
    
    -- XP notifications
    showXPGains = true,
    
    -- Duration (milliseconds)
    duration = 5000
}

-- UI Settings
LXRConfig.UI = {
    -- HUD elements
    hud = {
        enabled = true,
        showMoney = true,
        showHealth = true,
        showStamina = true,
        showHunger = true,
        showThirst = true
    },
    
    -- Minimap
    minimap = {
        enabled = true,
        shape = 'square',           -- 'square' or 'circle'
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY & ANTI-ABUSE █████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Security = {
    -- Rate limiting per event (calls per second)
    rateLimits = {
        enabled = true,
        default = 10,
        events = {
            ['AddMoney'] = 5,
            ['AddItem'] = 20,
            ['UseItem'] = 5,
            ['UpdatePlayerData'] = 3
        }
    },
    
    -- Anti-cheat thresholds
    antiCheat = {
        enabled = true,
        
        -- Rapid money gain detection
        rapidMoney = {
            threshold = 100000,     -- Flag if gaining $100k+
            window = 60000,         -- Within 60 seconds
            action = 'log'          -- 'log', 'kick', or 'ban'
        },
        
        -- Rapid item gain detection
        rapidItems = {
            threshold = 50,
            window = 10000,
            action = 'log'
        },
        
        -- Teleport detection
        teleport = {
            enabled = true,
            maxDistance = 500,      -- Max 500 units per second
            action = 'log'
        }
    },
    
    -- Server-side validation
    validation = {
        validateCoordinates = true, -- Validate player coordinates
        validateItems = true,       -- Validate item operations
        validateMoney = true,       -- Validate money operations
        validateWeapons = true      -- Validate weapon usage
    },
    
    -- Logging
    logging = {
        enabled = true,
        logLevel = 'info',          -- 'debug', 'info', 'warn', 'error'
        logToConsole = true,
        logToDatabase = true,
        logToDiscord = false,       -- Set to true and add webhook
        discordWebhook = '',
        
        -- What to log
        categories = {
            money = true,
            items = true,
            commands = true,
            adminActions = true,
            security = true,
            errors = true
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ PERFORMANCE OPTIMIZATION ██████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Performance = {
    -- Database query caching
    caching = {
        enabled = true,
        playerDataTTL = 300,        -- Cache player data for 5 minutes
        itemDataTTL = 600,          -- Cache item data for 10 minutes
        vehicleDataTTL = 900        -- Cache vehicle data for 15 minutes
    },
    
    -- Client-side optimization
    client = {
        updateInterval = 1000,      -- Update interval in ms
        maxNearbyPlayers = 32,      -- Max nearby players to track
        maxNearbyVehicles = 16,     -- Max nearby vehicles to track
        reducedTrafficDensity = 0.3 -- Reduce NPC traffic (0.0 - 1.0)
    },
    
    -- Server-side optimization
    server = {
        tickRate = 30,              -- Server tick rate (Hz)
        saveInterval = 300000,      -- Save player data every 5 minutes
        cleanupInterval = 600000,   -- Cleanup old data every 10 minutes
        maxPlayersPerSecond = 2     -- Max new players per second (anti-DDoS)
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG SETTINGS ████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

LXRConfig.Debug = {
    enabled = false,                -- Master debug toggle
    verbose = false,                -- Extra verbose logging
    
    -- Debug categories
    categories = {
        playerData = false,
        money = false,
        items = false,
        vehicles = false,
        jobs = false,
        gangs = false,
        events = false,
        database = false,
        performance = false
    },
    
    -- Developer commands
    devCommands = {
        enabled = false,            -- Enable dev commands
        allowedIds = {              -- Steam/license IDs allowed to use dev commands
            -- 'steam:110000000000000',
        }
    }
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ END OF CONFIGURATION ██████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

-- Export config for other resources
exports('GetConfig', function()
    return LXRConfig
end)

-- Startup banner (runs after all resources are loaded)
CreateThread(function()
    Wait(1000)
    
    -- Count various items for display
    local moneyTypeCount = 0
    for _ in pairs(LXRConfig.Money.MoneyTypes) do
        moneyTypeCount = moneyTypeCount + 1
    end
    
    local skillCount = LXRConfig.Progression.Skills and #LXRConfig.Progression.Skills.skills or 0
    
    print([[
        
        ═══════════════════════════════════════════════════════════════════════════════
        
            ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
            ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
            ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
            ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
            ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
            ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
            
            ███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
            ██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
            █████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
            ██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
            ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
            ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
        
        ═══════════════════════════════════════════════════════════════════════════════
        🐺 LXR CORE FRAMEWORK - SUCCESSFULLY LOADED
        ═══════════════════════════════════════════════════════════════════════════════
        
        Version:          2.0.0
        Server:           ]] .. LXRConfig.ServerInfo.name .. [[
        
        Framework:        LXR-Core (Primary)
        Language:         ]] .. LXRConfig.Lang .. [[
        Max Players:      ]] .. LXRConfig.MaxPlayers .. [[
        
        Currency Types:   ]] .. moneyTypeCount .. [[ configured
        Skills System:    ]] .. skillCount .. [[ skills available
        Progression:      ]] .. (LXRConfig.Progression.Skills.enabled and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        
        PVP:              ]] .. (LXRConfig.EnablePVP and 'ENABLED ✓' or 'DISABLED ✗') .. [[
        Security:         ]] .. (LXRConfig.Security.antiCheat.enabled and 'ACTIVE ✓' or 'DISABLED ✗') .. [[
        Performance:      ]] .. (LXRConfig.Performance.caching.enabled and 'OPTIMIZED ✓' or 'STANDARD') .. [[
        Debug Mode:       ]] .. (LXRConfig.Debug.enabled and 'ENABLED' or 'DISABLED') .. [[
        
        ═══════════════════════════════════════════════════════════════════════════════
        
        Developer:        iBoss21 / The Lux Empire
        Website:          https://www.wolves.land
        Discord:          https://discord.gg/CrKcWdfd3A
        
        ═══════════════════════════════════════════════════════════════════════════════
        
    ]])
end)
