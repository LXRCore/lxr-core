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
    
    1899 Economy Standards:
    - Average worker: $0.50-1.50 per day
    - Skilled worker: $2-3 per day  
    - Professional: $4-6 per day
    - Gold: $20 per ounce (historical)
    - Most items: $0.05-0.50
]]--

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
    
    -- ============ Promissory Notes ============
    promisarynotes = {
        label = 'Promissory Notes',
        startAmount = 0,
        tangible = true,
        canMinus = false,
        icon = 'promissory_note',
        weight = 1,
        maxCarry = 50,
        description = 'Legal promise to pay - can be traded or cashed at bank',
        paycheck = false,
        hidden = false,
        cashable = true,            -- Can be cashed at bank
        tradeable = true,           -- Can be traded between players
        expiryDays = 30,            -- Expires after 30 days
        valueInDollars = 10,        -- Each note worth $10
        requiresSignature = true    -- Needs issuer's signature
    },
    
    -- ============ Admin/Hidden Currencies ============
    adminmoney = {
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
-- Updated for 1899 economy standards
LXRConfig.Money.ExchangeRates = {
    enabled = true,
    commission = 0.10,          -- 10% commission on exchanges (banks take bigger cut in 1899)
    rates = {
        coins_to_cash = 0.01,           -- 100 coins = 1 dollar
        goldcoins_to_cash = 5,          -- 1 gold coin = 5 dollars
        silvercoins_to_cash = 1,        -- 1 silver coin = 1 dollar
        gold_to_cash = 25,              -- 1 gold bar = 25 dollars
        diamonds_to_cash = 50,          -- 1 diamond = 50 dollars
        promisarynotes_to_bank = 10,    -- 1 note = 10 bank dollars
        marshalcoins_to_cash = 2,       -- 1 marshal coin = 2 dollars
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
-- TEBEX INTEGRATION (Premium Currency)
-- ============================================

--[[
    Server Owner Setup:
    1. Create account at tebex.io
    2. Get your secret key from Tebex panel
    3. Set up webhook: https://your-server-ip:30120/tebex/webhook
    4. Configure packages below
    5. Set Enabled = true
]]--

LXRConfig.Tebex = {
    Enabled = false,            -- Set to true when configured
    SecretKey = '',             -- Your Tebex secret key from tebex.io
    
    -- Package ID to reward mapping
    -- Get package IDs from your Tebex panel
    Packages = {
        -- Example packages (replace with your actual package IDs)
        
        -- Starter Packs
        [1001] = {
            name = 'Starter Pack',
            goldcurrency = 100,     -- 100 gold currency
            tokens = 50,            -- 50 premium tokens
            cash = 10,              -- $10 cash
        },
        
        [1002] = {
            name = 'Basic Pack',
            goldcurrency = 250,
            tokens = 125,
            cash = 25,
        },
        
        [1003] = {
            name = 'Premium Pack',
            goldcurrency = 600,
            tokens = 300,
            cash = 50,
            items = {
                ['weapon_revolver_cattleman'] = 1,
            }
        },
        
        [1004] = {
            name = 'Ultimate Pack',
            goldcurrency = 1500,
            tokens = 750,
            cash = 100,
            items = {
                ['weapon_revolver_schofield'] = 1,
                ['horse_arabian'] = 1,
            }
        },
        
        -- Gold Currency Only Packs
        [2001] = {
            name = '100 Gold',
            goldcurrency = 100,
        },
        
        [2002] = {
            name = '250 Gold',
            goldcurrency = 250,
        },
        
        [2003] = {
            name = '500 Gold',
            goldcurrency = 500,
        },
        
        [2004] = {
            name = '1000 Gold',
            goldcurrency = 1000,
        },
        
        [2005] = {
            name = '2500 Gold',
            goldcurrency = 2500,
        },
        
        -- Token Only Packs
        [3001] = {
            name = '100 Tokens',
            tokens = 100,
        },
        
        [3002] = {
            name = '250 Tokens',
            tokens = 250,
        },
        
        [3003] = {
            name = '500 Tokens',
            tokens = 500,
        },
        
        [3004] = {
            name = '1000 Tokens',
            tokens = 1000,
        },
        
        -- VIP Packs (use command to set VIP status)
        [4001] = {
            name = 'VIP 30 Days',
            goldcurrency = 300,
            tokens = 150,
            command = 'setvip %s 30'  -- %s will be replaced with player ID
        },
        
        [4002] = {
            name = 'VIP 90 Days',
            goldcurrency = 800,
            tokens = 400,
            command = 'setvip %s 90'
        },
        
        [4003] = {
            name = 'VIP Lifetime',
            goldcurrency = 2000,
            tokens = 1000,
            command = 'setvip %s -1'  -- -1 = lifetime
        },
    },
    
    -- Exchange rates for gold currency and tokens
    -- How much gold/tokens can buy in-game
    GoldShop = {
        enabled = true,
        items = {
            -- Format: itemName = goldCost
            weapon_revolver_schofield = 50,
            weapon_rifle_springfield = 75,
            horse_arabian = 200,
            horse_turkoman = 150,
            saddle_special_01 = 100,
        }
    },
    
    TokenShop = {
        enabled = true,
        items = {
            -- Format: itemName = tokenCost
            cosmetic_hat_01 = 25,
            cosmetic_outfit_01 = 50,
            emote_dance_01 = 10,
            vehicle_skin_01 = 75,
        }
    }
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
    maxCash = 500,              -- Max $500 cash in wallet (1899 economy - that's a lot!)
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
