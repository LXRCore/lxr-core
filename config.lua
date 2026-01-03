--[[
    LXRCore Configuration File
    
    For Server Owners:
    This is the ONLY file you need to edit for most configurations.
    Everything is centralized here for easy management.
    
    Website: https://www.lxrcore.com
    Launched on: The Land of Wolves RP (https://www.wolves.land)
    
    Version: 2.0.0
]]--

LXRConfig = {}

-- ============================================
-- SERVER SETTINGS
-- ============================================

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
LXRConfig.Discord = "https://discord.gg/yourserver"

-- Close server to public (only admins with 'lxradmin.join' can connect)
LXRConfig.ServerClosed = false
LXRConfig.ServerClosedReason = "Server Closed for Maintenance"

-- Use connectqueue resource for queue system
LXRConfig.UseConnectQueue = true

-- Permission groups (add as many as needed)
-- Players are assigned to these groups via ACE permissions
LXRConfig.Permissions = {'god', 'admin', 'mod', 'support'}

-- ============================================
-- CURRENCY & MONEY SYSTEM (Supreme Edition)
-- ============================================

--[[
    Currency Types:
    - tangible = true: Physical items that take inventory space (can be stolen/dropped)
    - tangible = false: Account-based money (cannot be stolen directly)
    - hidden = true: Hidden from standard displays (for admin/special currencies)
    - canMinus = false: Cannot go negative (like cash in hand)
]]--

LXRConfig.Money = {}

-- Main Currency Types
LXRConfig.Money.MoneyTypes = {
    -- ============ Standard Currencies ============
    ['cash'] = {
        label = 'Cash Dollars',
        startAmount = 50,           -- Starting amount for new players
        tangible = true,            -- Physical item (can be stolen)
        canMinus = false,           -- Cannot go negative
        icon = 'dollar',            -- Icon name for UI
        weight = 0,                 -- Weight per unit (grams)
        maxCarry = 50000,           -- Maximum amount player can carry
        description = 'Paper money used for everyday transactions',
        paycheck = true,            -- Can receive paycheck in this currency
        hidden = false              -- Show in standard UI
    },
    
    ['bank'] = {
        label = 'Bank Account',
        startAmount = 250,
        tangible = false,           -- Account-based (cannot be stolen directly)
        canMinus = false,
        icon = 'bank',
        weight = 0,
        maxCarry = 999999999,       -- Virtually unlimited
        description = 'Money stored safely in the bank',
        paycheck = true,
        hidden = false
    },
    
    -- ============ Precious Metals ============
    ['gold'] = {
        label = 'Gold Bars',
        startAmount = 0,
        tangible = true,            -- Physical gold bars
        canMinus = false,
        icon = 'gold_bar',
        weight = 1000,              -- 1kg per gold bar
        maxCarry = 100,             -- Max 100 gold bars (heavy!)
        description = 'Pure gold bars - highly valuable and heavy',
        paycheck = false,
        hidden = false,
        valueInDollars = 250        -- Each gold bar worth $250
    },
    
    ['goldcurrency'] = {
        label = 'Gold Currency',
        startAmount = 0,
        tangible = false,           -- Account-based gold like VORP
        canMinus = false,
        icon = 'gold_coin',
        weight = 0,
        maxCarry = 999999,
        description = 'Gold-backed currency used for premium transactions',
        paycheck = false,
        hidden = false,
        valueInDollars = 100        -- 1 gold currency = $100
    },
    
    -- ============ Coins System ============
    ['coins'] = {
        label = 'Coins',
        startAmount = 25,
        tangible = true,
        canMinus = false,
        icon = 'coins',
        weight = 0.1,               -- Very light
        maxCarry = 10000,
        description = 'Small denomination coins for minor purchases',
        paycheck = true,
        hidden = false,
        valueInDollars = 0.1        -- 10 coins = $1
    },
    
    ['goldcoins'] = {
        label = 'Gold Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'gold_coin',
        weight = 50,                -- Heavy coins
        maxCarry = 500,
        description = 'Rare gold coins used for high-value transactions',
        paycheck = false,
        hidden = false,
        valueInDollars = 50         -- 1 gold coin = $50
    },
    
    ['silvercoins'] = {
        label = 'Silver Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'silver_coin',
        weight = 25,
        maxCarry = 1000,
        description = 'Silver coins used for medium-value transactions',
        paycheck = false,
        hidden = false,
        valueInDollars = 10         -- 1 silver coin = $10
    },
    
    -- ============ Special Faction Coins ============
    ['marshalcoins'] = {
        label = 'Marshal Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'marshal_badge',
        weight = 10,
        maxCarry = 100,
        description = 'Special currency earned by law enforcement',
        paycheck = false,
        hidden = false,
        valueInDollars = 25,
        restricted = {
            jobs = {'police', 'marshal'},  -- Only these jobs can earn
            description = 'Law enforcement only'
        }
    },
    
    ['trustcoins'] = {
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
    ['diamonds'] = {
        label = 'Diamonds',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'diamond',
        weight = 50,
        maxCarry = 100,
        description = 'Extremely rare and valuable diamonds',
        paycheck = false,
        hidden = false,
        valueInDollars = 500        -- 1 diamond = $500
    },
    
    -- ============ Blood Money System ============
    ['bloodmoney'] = {
        label = 'Blood Money',
        startAmount = 0,
        tangible = true,            -- Dirty cash that must be laundered
        canMinus = false,
        icon = 'blood_dollar',
        weight = 0,
        maxCarry = 25000,
        description = 'Illegally obtained cash - must be laundered to use',
        paycheck = false,
        hidden = false,
        needsLaundering = true,     -- Must be converted to clean money
        launderRate = 0.7,          -- 70% conversion rate (30% lost to laundering)
        detectRisk = 0.3            -- 30% chance of detection per transaction
    },
    
    ['bloodcoins'] = {
        label = 'Blood Coins',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'blood_coin',
        weight = 0.5,
        maxCarry = 1000,
        description = 'Illegally obtained coins - highly suspicious',
        paycheck = false,
        hidden = false,
        needsLaundering = true,
        launderRate = 0.6,          -- 60% conversion rate
        detectRisk = 0.4,           -- 40% detection risk
        valueInDollars = 5
    },
    
    -- ============ Tokens System ============
    ['tokens'] = {
        label = 'Premium Tokens',
        startAmount = 0,
        tangible = false,           -- Premium currency (donation/reward)
        canMinus = false,
        icon = 'token',
        weight = 0,
        maxCarry = 99999,
        description = 'Premium tokens used in special shops',
        paycheck = false,
        hidden = false,
        valueInDollars = 0,         -- Cannot buy with regular money
        earnMethods = {
            donation = true,        -- Can be purchased with real money
            events = true,          -- Can be earned in events
            daily = 1               -- 1 free token per day
        }
    },
    
    ['rewardtokens'] = {
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
    
    -- ============ Promissory Notes ============
    ['promisarynotes'] = {
        label = 'Promissory Notes',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'promissory_note',
        weight = 1,
        maxCarry = 100,
        description = 'Legal promise to pay - can be traded or cashed at bank',
        paycheck = false,
        hidden = false,
        cashable = true,            -- Can be cashed at bank
        tradeable = true,           -- Can be traded between players
        expiryDays = 30,            -- Expires after 30 days
        valueInDollars = 100,       -- Each note worth $100
        requiresSignature = true    -- Needs issuer's signature
    },
    
    -- ============ Admin/Hidden Currencies ============
    ['adminmoney'] = {
        label = 'Admin Currency',
        startAmount = 0,
        tangible = false,
        canMinus = true,            -- Can go negative for admin purposes
        icon = 'admin',
        weight = 0,
        maxCarry = 999999999,
        description = 'Special currency for admin events and rewards',
        paycheck = false,
        hidden = true,              -- Hidden from normal players
        adminOnly = true            -- Only admins can add/remove
    }
}

-- Money types that cannot go negative
-- Note: This is auto-generated from MoneyTypes above
LXRConfig.Money.DontAllowMinus = {}
for moneyType, data in pairs(LXRConfig.Money.MoneyTypes) do
    if not data.canMinus then
        table.insert(LXRConfig.Money.DontAllowMinus, moneyType)
    end
end

-- Paycheck Configuration
LXRConfig.Money.PayCheckTimeOut = 30           -- Minutes between paychecks
LXRConfig.Money.PayCheckSociety = false        -- Paychecks from society account (requires lxr-bossmenu)
LXRConfig.Money.PayCheckTypes = {'cash', 'bank'} -- Which currencies can be used for paychecks

-- Currency Exchange Rates (for conversion between types)
LXRConfig.Money.ExchangeRates = {
    enabled = true,
    commission = 0.05,          -- 5% commission on exchanges
    rates = {
        ['coins_to_cash'] = 0.1,        -- 10 coins = 1 dollar
        ['goldcoins_to_cash'] = 50,     -- 1 gold coin = 50 dollars
        ['silvercoins_to_cash'] = 10,   -- 1 silver coin = 10 dollars
        ['gold_to_cash'] = 250,         -- 1 gold bar = 250 dollars
        ['diamonds_to_cash'] = 500,     -- 1 diamond = 500 dollars
        ['promisarynotes_to_bank'] = 100, -- 1 note = 100 bank dollars
    }
}

-- Money Laundering Configuration
LXRConfig.Money.Laundering = {
    enabled = true,
    locations = {
        vector3(-308.23, 803.97, 118.98),  -- Add your laundering locations
    },
    cooldown = 300,             -- 5 minutes between laundering attempts
    policeAlert = true,         -- Alert police when laundering
    minPoliceRequired = 2,      -- Minimum police online for laundering
}

-- ============================================
-- PLAYER SETTINGS
-- ============================================

LXRConfig.Player = {}

-- Reveal entire map on first join
LXRConfig.Player.RevealMap = true

-- Maximum carrying weight (in grams)
-- Note: 120000 = 120kg
LXRConfig.Player.MaxWeight = 120000

-- Maximum inventory slots
LXRConfig.Player.MaxInvSlots = 41

-- Available blood types for character creation
LXRConfig.Player.Bloodtypes = {
    "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"
}

-- Wallet settings for physical money
LXRConfig.Player.Wallet = {
    enabled = true,
    maxCash = 5000,             -- Max cash in wallet before needing deposit
    dropOnDeath = {
        enabled = true,
        percentage = 0.5,       -- Drop 50% of tangible money on death
        excludeTypes = {'bank', 'goldcurrency', 'tokens'} -- Never drop these
    }
}

-- ============================================
-- SKILL & LEVELING SYSTEM
-- ============================================

-- Left side is level, right side xp needed
-- You can add as many skills as you want here
LXRConfig.Levels = {
    ["main"] = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    ["mining"] = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    ["herbalism"] = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
    ["hunting"] = {
        [0] = 0, [1] = 50, [2] = 100, [3] = 150, [4] = 200,
        [5] = 250, [6] = 300, [7] = 350, [8] = 400, [9] = 450,
        [10] = 500, [11] = 550, [12] = 600, [13] = 650, [14] = 700,
        [15] = 750, [16] = 800, [17] = 850, [18] = 900, [19] = 950,
        [20] = 1000
    },
}

-- XP Multipliers (server-wide bonuses)
LXRConfig.XPMultiplier = {
    enabled = true,
    weekend = 1.5,              -- 50% bonus on weekends
    event = 2.0,                -- 100% bonus during events
    vip = 1.25,                 -- 25% bonus for VIP players
}

-- ============================================
-- SHOPS & ECONOMY
-- ============================================

LXRConfig.Shops = {
    -- Which currencies are accepted in shops
    acceptedCurrencies = {
        'cash', 'coins', 'goldcoins', 'silvercoins', 'tokens'
    },
    
    -- Tax rate on purchases (goes to society/government)
    taxRate = 0.05,             -- 5% sales tax
    
    -- Discount for paying with specific currencies
    currencyDiscounts = {
        ['goldcoins'] = 0.10,   -- 10% discount if paying with gold coins
        ['promisarynotes'] = 0.05, -- 5% discount with promissory notes
    }
}

-- ============================================
-- SECURITY SETTINGS
-- ============================================

LXRConfig.Security = {
    -- Rate limiting per event (calls per second)
    rateLimits = {
        default = 10,
        ['AddMoney'] = 5,
        ['AddItem'] = 20,
        ['UseItem'] = 5,
    },
    
    -- Anti-cheat thresholds
    antiCheat = {
        rapidMoney = {
            threshold = 100000,     -- Flag if gaining $100k+
            window = 60000,         -- Within 60 seconds
            action = 'log'          -- 'log', 'kick', or 'ban'
        },
        rapidItems = {
            threshold = 50,
            window = 10000,
            action = 'log'
        }
    }
}

-- ============================================
-- NOTIFICATION SETTINGS
-- ============================================

LXRConfig.Notifications = {
    -- Money notifications
    showMoneyChanges = true,
    minAmountToShow = 10,       -- Only show if amount >= $10
    
    -- Item notifications
    showItemChanges = true,
    
    -- XP notifications
    showXPGains = true,
}

-- Export config for other resources
exports('GetConfig', function()
    return LXRConfig
end)
