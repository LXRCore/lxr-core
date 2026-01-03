--[[
    LXRCore - Gangs Configuration (1899 Era)
    
    All gangs from Red Dead Redemption 2 and era-appropriate outlaw groups
    Includes RDR2 canon gangs and additional period-accurate gangs
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
]]--

LXRShared = LXRShared or {}
LXRShared.Gangs = {
    -- ============================================
    -- NO GANG / CIVILIAN
    -- ============================================
    none = {
        label = 'No Gang Affiliation',
        grades = {
            ['0'] = { name = 'Unaffiliated' }
        }
    },
    
    -- ============================================
    -- RDR2 CANON GANGS
    -- ============================================
    vanderlinde = {
        label = 'Van der Linde Gang',
        grades = {
            ['0'] = { name = 'Associate' },
            ['1'] = { name = 'Member' },
            ['2'] = { name = 'Trusted' },
            ['3'] = { name = 'Lieutenant' },
            ['4'] = { name = 'Leader', isboss = true }
        }
    },
    
    odriscoll = {
        label = "O'Driscoll Boys",
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Thug' },
            ['2'] = { name = 'Enforcer' },
            ['3'] = { name = 'Shot Caller' },
            ['4'] = { name = 'Boss', isboss = true }
        }
    },
    
    lemoyne = {
        label = 'Lemoyne Raiders',
        grades = {
            ['0'] = { name = 'Private' },
            ['1'] = { name = 'Corporal' },
            ['2'] = { name = 'Sergeant' },
            ['3'] = { name = 'Captain' },
            ['4'] = { name = 'Colonel', isboss = true }
        }
    },
    
    murfree = {
        label = 'Murfree Brood',
        grades = {
            ['0'] = { name = 'Savage' },
            ['1'] = { name = 'Bruiser' },
            ['2'] = { name = 'Terrorizer' },
            ['3'] = { name = 'Patriarch', isboss = true }
        }
    },
    
    skinner = {
        label = 'Skinner Brothers',
        grades = {
            ['0'] = { name = 'Skinner' },
            ['1'] = { name = 'Hunter' },
            ['2'] = { name = 'Executioner' },
            ['3'] = { name = 'Chief', isboss = true }
        }
    },
    
    laramie = {
        label = 'Laramie Gang',
        grades = {
            ['0'] = { name = 'Rustler' },
            ['1'] = { name = 'Gunhand' },
            ['2'] = { name = 'Lieutenant' },
            ['3'] = { name = 'Leader', isboss = true }
        }
    },
    
    dellobo = {
        label = 'Del Lobo Gang',
        grades = {
            ['0'] = { name = 'Bandito' },
            ['1'] = { name = 'Pistolero' },
            ['2'] = { name = 'Teniente' },
            ['3'] = { name = 'Jefe', isboss = true }
        }
    },
    
    nightfolk = {
        label = 'Night Folk',
        grades = {
            ['0'] = { name = 'Shadow' },
            ['1'] = { name = 'Stalker' },
            ['2'] = { name = 'Elder', isboss = true }
        }
    },
    
    foreman = {
        label = 'Foreman Brothers',
        grades = {
            ['0'] = { name = 'Recruit' },
            ['1'] = { name = 'Bruiser' },
            ['2'] = { name = 'Foreman', isboss = true }
        }
    },
    
    -- ============================================
    -- NATIVE AMERICAN GROUPS
    -- ============================================
    wapiti = {
        label = 'Wapiti Indians',
        grades = {
            ['0'] = { name = 'Warrior' },
            ['1'] = { name = 'Brave' },
            ['2'] = { name = 'War Chief' },
            ['3'] = { name = 'Chief', isboss = true }
        }
    },
    
    -- ============================================
    -- HISTORICAL OUTLAW GANGS (1899 Era)
    -- ============================================
    
    -- Southwest Outlaws
    dalton = {
        label = 'Dalton Gang',
        grades = {
            ['0'] = { name = 'Rider' },
            ['1'] = { name = 'Gunslinger' },
            ['2'] = { name = 'Lieutenant' },
            ['3'] = { name = 'Dalton Brother', isboss = true }
        }
    },
    
    doolin = {
        label = 'Doolin-Dalton Gang',
        grades = {
            ['0'] = { name = 'Outlaw' },
            ['1'] = { name = 'Gunman' },
            ['2'] = { name = 'Wild Bunch' },
            ['3'] = { name = 'Boss', isboss = true }
        }
    },
    
    wilderbunch = {
        label = 'Wild Bunch',
        grades = {
            ['0'] = { name = 'Rustler' },
            ['1'] = { name = 'Bank Robber' },
            ['2'] = { name = 'Train Robber' },
            ['3'] = { name = 'Butch & Sundance', isboss = true }
        }
    },
    
    -- Mexican Bandits
    revolucion = {
        label = 'Revolución',
        grades = {
            ['0'] = { name = 'Soldado' },
            ['1'] = { name = 'Guerrero' },
            ['2'] = { name = 'Capitán' },
            ['3'] = { name = 'General', isboss = true }
        }
    },
    
    bandidos = {
        label = 'Los Bandidos',
        grades = {
            ['0'] = { name = 'Bandido' },
            ['1'] = { name = 'Vaquero' },
            ['2'] = { name = 'Líder', isboss = true }
        }
    },
    
    -- Cattle Rustlers & Ranch Raiders
    cattlerustlers = {
        label = 'Cattle Rustlers',
        grades = {
            ['0'] = { name = 'Rustler' },
            ['1'] = { name = 'Wrangler' },
            ['2'] = { name = 'Boss Rustler', isboss = true }
        }
    },
    
    -- Train & Bank Robbers
    trainrobbers = {
        label = 'Train Robbers',
        grades = {
            ['0'] = { name = 'Lookout' },
            ['1'] = { name = 'Gunman' },
            ['2'] = { name = 'Dynamiter' },
            ['3'] = { name = 'Mastermind', isboss = true }
        }
    },
    
    -- Moonshiners & Smugglers
    moonshiners = {
        label = 'Moonshine Runners',
        grades = {
            ['0'] = { name = 'Runner' },
            ['1'] = { name = 'Distiller' },
            ['2'] = { name = 'Moonshine Boss', isboss = true }
        }
    },
    
    smugglers = {
        label = 'Smuggling Ring',
        grades = {
            ['0'] = { name = 'Mule' },
            ['1'] = { name = 'Smuggler' },
            ['2'] = { name = 'Kingpin', isboss = true }
        }
    },
    
    -- Bounty Hunters (Rogue)
    bountyhunters = {
        label = 'Rogue Bounty Hunters',
        grades = {
            ['0'] = { name = 'Tracker' },
            ['1'] = { name = 'Hunter' },
            ['2'] = { name = 'Master Hunter', isboss = true }
        }
    },
    
    -- River & Swamp Gangs
    riverpir ates = {
        label = 'River Pirates',
        grades = {
            ['0'] = { name = 'Deckhand' },
            ['1'] = { name = 'Pirate' },
            ['2'] = { name = 'Captain', isboss = true }
        }
    },
    
    bayougang = {
        label = 'Bayou Gang',
        grades = {
            ['0'] = { name = 'Swamper' },
            ['1'] = { name = 'Gator' },
            ['2'] = { name = 'Swamp King', isboss = true }
        }
    },
    
    -- Mountain & Northern Gangs
    mountainmen = {
        label = 'Mountain Men',
        grades = {
            ['0'] = { name = 'Trapper' },
            ['1'] = { name = 'Mountain Man' },
            ['2'] = { name = 'Mountain King', isboss = true }
        }
    },
    
    grizzlies = {
        label = 'Grizzlies Gang',
        grades = {
            ['0'] = { name = 'Survivor' },
            ['1'] = { name = 'Raider' },
            ['2'] = { name = 'Warlord', isboss = true }
        }
    },
    
    -- Town Thugs & Organized Crime
    saintdenismob = {
        label = 'Saint Denis Mob',
        grades = {
            ['0'] = { name = 'Thug' },
            ['1'] = { name = 'Made Man' },
            ['2'] = { name = 'Underboss' },
            ['3'] = { name = 'Don', isboss = true }
        }
    },
    
    blackwater = {
        label = 'Blackwater Crew',
        grades = {
            ['0'] = { name = 'Muscle' },
            ['1'] = { name = 'Enforcer' },
            ['2'] = { name = 'Boss', isboss = true }
        }
    },
    
    -- Trappers & Hunters Turned Bad
    pelttraders = {
        label = 'Illegal Pelt Traders',
        grades = {
            ['0'] = { name = 'Poacher' },
            ['1'] = { name = 'Trader' },
            ['2'] = { name = 'Pelt Baron', isboss = true }
        }
    },
    
    -- Horse Thieves
    horsethieves = {
        label = 'Horse Thieves',
        grades = {
            ['0'] = { name = 'Rustler' },
            ['1'] = { name = 'Horse Thief' },
            ['2'] = { name = 'Stable Master', isboss = true }
        }
    },
    
    -- Claim Jumpers & Prospector Gangs
    claimjumpers = {
        label = 'Claim Jumpers',
        grades = {
            ['0'] = { name = 'Jumper' },
            ['1'] = { name = 'Claim Thief' },
            ['2'] = { name = 'Mining Boss', isboss = true }
        }
    },
    
    -- Stagecoach Robbers
    highwaymen = {
        label = 'Highwaymen',
        grades = {
            ['0'] = { name = 'Footpad' },
            ['1'] = { name = 'Highwayman' },
            ['2'] = { name = 'Road Agent', isboss = true }
        }
    },
    
    -- Counterfeiters & Con Artists
    counterfeiters = {
        label = 'Counterfeit Ring',
        grades = {
            ['0'] = { name = 'Runner' },
            ['1'] = { name = 'Forger' },
            ['2'] = { name = 'Mastermind', isboss = true }
        }
    },
    
    -- Grave Robbers & Body Snatchers
    graverobbers = {
        label = 'Grave Robbers',
        grades = {
            ['0'] = { name = 'Digger' },
            ['1'] = { name = 'Robber' },
            ['2'] = { name = 'Resurrectionist', isboss = true }
        }
    },
    
    -- Opium & Drug Dealers
    opiumden = {
        label = 'Opium Ring',
        grades = {
            ['0'] = { name = 'Runner' },
            ['1'] = { name = 'Dealer' },
            ['2'] = { name = 'Opium Lord', isboss = true }
        }
    },
    
    -- Fight Club Operators
    fightclub = {
        label = 'Fight Club',
        grades = {
            ['0'] = { name = 'Brawler' },
            ['1'] = { name = 'Promoter' },
            ['2'] = { name = 'Fight Boss', isboss = true }
        }
    },
    
    -- Gambling Ring
    gamblers = {
        label = 'Gambling Ring',
        grades = {
            ['0'] = { name = 'Card Sharp' },
            ['1'] = { name = 'High Roller' },
            ['2'] = { name = 'House', isboss = true }
        }
    },
    
    -- Protection Racket
    protection = {
        label = 'Protection Racket',
        grades = {
            ['0'] = { name = 'Collector' },
            ['1'] = { name = 'Enforcer' },
            ['2'] = { name = 'Boss', isboss = true }
        }
    },
    
    -- Gunslingers for Hire
    gunslingers = {
        label = 'Guns for Hire',
        grades = {
            ['0'] = { name = 'Gunhand' },
            ['1'] = { name = 'Gunslinger' },
            ['2'] = { name = 'Legendary Gunslinger', isboss = true }
        }
    },
    
    -- Vigilantes (Lawless Justice)
    vigilantes = {
        label = 'Vigilantes',
        grades = {
            ['0'] = { name = 'Watchman' },
            ['1'] = { name = 'Vigilante' },
            ['2'] = { name = 'Regulator', isboss = true }
        }
    },
}

--[[
    Gang Territories & Hideouts Configuration
    
    Server Owner Note:
    Uncomment and configure these locations based on your map
    Each gang can have multiple hideouts and territories
    
    Example format:
    LXRShared.GangLocations = {
        ['vanderlinde'] = {
            hideout = vector3(-1742.43, -389.97, 155.19),  -- Horseshoe Overlook
            territory = {
                vector3(-1800.0, -400.0, 150.0),
                vector3(-1700.0, -350.0, 160.0),
            }
        },
        ['odriscoll'] = {
            hideout = vector3(1470.53, 368.87, 86.45),  -- Six Point Cabin
            territory = {
                vector3(1400.0, 300.0, 80.0),
                vector3(1500.0, 400.0, 90.0),
            }
        },
    }
]]--