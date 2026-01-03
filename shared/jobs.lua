--[[
    LXRCore - Jobs Configuration (1899 Era)
    
    Historically accurate jobs for Red Dead Redemption 2 era
    All payments reflect 1899 economy (below medium wage)
    
    Historical Context:
    - Average worker earned $1-3 per day in 1899
    - Skilled workers earned $3-5 per day
    - Professional jobs earned $5-10 per day
    
    Payment rates are in dollars per paycheck cycle (30 min default)
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
]]--

LXRShared = LXRShared or {}
LXRShared.ForceJobDefaultDutyAtLogin = true

LXRShared.Jobs = {
    -- ============================================
    -- UNEMPLOYED / CIVILIAN
    -- ============================================
    unemployed = {
        label = 'Civilian',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Citizen', payment = 0 }
        }
    },
    
    -- ============================================
    -- LAW ENFORCEMENT
    -- ============================================
    police = {
        label = 'Sheriff Department',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Deputy', payment = 2 },
            ['1'] = { name = 'Senior Deputy', payment = 3 },
            ['2'] = { name = 'Undersheriff', payment = 4 },
            ['3'] = { name = 'Sheriff', isboss = true, payment = 6 },
        },
    },
    
    marshal = {
        label = 'U.S. Marshal Service',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Deputy Marshal', payment = 3 },
            ['1'] = { name = 'Marshal', payment = 5 },
            ['2'] = { name = 'Chief Marshal', isboss = true, payment = 8 },
        },
    },
    
    ranger = {
        label = 'Texas Rangers',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Ranger', payment = 3 },
            ['1'] = { name = 'Senior Ranger', payment = 5 },
            ['2'] = { name = 'Captain', isboss = true, payment = 7 },
        },
    },
    
    -- ============================================
    -- MEDICAL SERVICES
    -- ============================================
    doctor = {
        label = 'Medical Practice',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Nurse', payment = 2 },
            ['1'] = { name = 'Physician', payment = 5 },
            ['2'] = { name = 'Surgeon', payment = 8 },
            ['3'] = { name = 'Chief Physician', isboss = true, payment = 10 },
        },
    },
    
    apothecary = {
        label = 'Apothecary',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 1 },
            ['1'] = { name = 'Pharmacist', payment = 3 },
            ['2'] = { name = 'Master Apothecary', isboss = true, payment = 5 },
        },
    },
    
    -- ============================================
    -- AGRICULTURE & RANCHING
    -- ============================================
    farmer = {
        label = 'Farmer',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Farmhand', payment = 1 },
            ['1'] = { name = 'Farmer', payment = 2 },
            ['2'] = { name = 'Ranch Owner', isboss = true, payment = 4 },
        },
    },
    
    rancher = {
        label = 'Cattle Rancher',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Wrangler', payment = 1 },
            ['1'] = { name = 'Cattle Hand', payment = 2 },
            ['2'] = { name = 'Foreman', payment = 3 },
            ['3'] = { name = 'Ranch Owner', isboss = true, payment = 5 },
        },
    },
    
    -- ============================================
    -- TRANSPORTATION
    -- ============================================
    stagecoach = {
        label = 'Stagecoach Company',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Driver', payment = 2 },
            ['1'] = { name = 'Guard', payment = 2 },
            ['2'] = { name = 'Station Manager', isboss = true, payment = 4 },
        },
    },
    
    railroad = {
        label = 'Railroad Company',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Track Worker', payment = 1 },
            ['1'] = { name = 'Engineer', payment = 3 },
            ['2'] = { name = 'Conductor', payment = 3 },
            ['3'] = { name = 'Station Master', isboss = true, payment = 5 },
        },
    },
    
    ferryman = {
        label = 'Ferry Service',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Deckhand', payment = 1 },
            ['1'] = { name = 'Captain', payment = 3 },
            ['2'] = { name = 'Harbor Master', isboss = true, payment = 5 },
        },
    },
    
    -- ============================================
    -- TRADES & CRAFTS
    -- ============================================
    blacksmith = {
        label = 'Blacksmith',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 1 },
            ['1'] = { name = 'Blacksmith', payment = 3 },
            ['2'] = { name = 'Master Smith', isboss = true, payment = 5 },
        },
    },
    
    gunsmith = {
        label = 'Gunsmith',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 2 },
            ['1'] = { name = 'Gunsmith', payment = 4 },
            ['2'] = { name = 'Master Gunsmith', isboss = true, payment = 6 },
        },
    },
    
    tailor = {
        label = 'Tailor Shop',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Seamstress', payment = 1 },
            ['1'] = { name = 'Tailor', payment = 2 },
            ['2'] = { name = 'Master Tailor', isboss = true, payment = 4 },
        },
    },
    
    carpenter = {
        label = 'Carpenter',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 1 },
            ['1'] = { name = 'Carpenter', payment = 2 },
            ['2'] = { name = 'Master Carpenter', isboss = true, payment = 4 },
        },
    },
    
    -- ============================================
    -- ENTERTAINMENT & SERVICES
    -- ============================================
    saloon = {
        label = 'Saloon',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Barback', payment = 1 },
            ['1'] = { name = 'Bartender', payment = 2 },
            ['2'] = { name = 'Saloon Girl', payment = 2 },
            ['3'] = { name = 'Pianist', payment = 2 },
            ['4'] = { name = 'Saloon Owner', isboss = true, payment = 5 },
        },
    },
    
    hotel = {
        label = 'Hotel',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Porter', payment = 1 },
            ['1'] = { name = 'Clerk', payment = 2 },
            ['2'] = { name = 'Manager', isboss = true, payment = 4 },
        },
    },
    
    theater = {
        label = 'Theater',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Stagehand', payment = 1 },
            ['1'] = { name = 'Performer', payment = 3 },
            ['2'] = { name = 'Director', isboss = true, payment = 5 },
        },
    },
    
    photographer = {
        label = 'Photography Studio',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Assistant', payment = 1 },
            ['1'] = { name = 'Photographer', isboss = true, payment = 3 },
        },
    },
    
    -- ============================================
    -- RETAIL & MERCHANTS
    -- ============================================
    general = {
        label = 'General Store',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Clerk', payment = 1 },
            ['1'] = { name = 'Shop Keep', payment = 2 },
            ['2'] = { name = 'Store Owner', isboss = true, payment = 4 },
        },
    },
    
    butcher = {
        label = 'Butcher Shop',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 1 },
            ['1'] = { name = 'Butcher', isboss = true, payment = 3 },
        },
    },
    
    -- ============================================
    -- RESOURCE GATHERING
    -- ============================================
    miner = {
        label = 'Mining Company',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Laborer', payment = 1 },
            ['1'] = { name = 'Miner', payment = 2 },
            ['2'] = { name = 'Foreman', payment = 3 },
            ['3'] = { name = 'Mine Boss', isboss = true, payment = 5 },
        },
    },
    
    lumberjack = {
        label = 'Logging Company',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Feller', payment = 1 },
            ['1'] = { name = 'Logger', payment = 2 },
            ['2'] = { name = 'Mill Foreman', isboss = true, payment = 4 },
        },
    },
    
    fisher = {
        label = 'Fisherman',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Deckhand', payment = 1 },
            ['1'] = { name = 'Fisherman', payment = 2 },
            ['2'] = { name = 'Boat Captain', isboss = true, payment = 3 },
        },
    },
    
    hunter = {
        label = 'Hunter & Trapper',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Trapper', payment = 1 },
            ['1'] = { name = 'Hunter', payment = 2 },
            ['2'] = { name = 'Master Hunter', isboss = true, payment = 4 },
        },
    },
    
    -- ============================================
    -- PROFESSIONAL SERVICES
    -- ============================================
    lawyer = {
        label = 'Law Firm',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Clerk', payment = 2 },
            ['1'] = { name = 'Attorney', payment = 6 },
            ['2'] = { name = 'Senior Partner', isboss = true, payment = 10 },
        },
    },
    
    banker = {
        label = 'Bank',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Teller', payment = 2 },
            ['1'] = { name = 'Accountant', payment = 4 },
            ['2'] = { name = 'Bank Manager', isboss = true, payment = 8 },
        },
    },
    
    journalist = {
        label = 'Newspaper',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Reporter', payment = 2 },
            ['1'] = { name = 'Editor', payment = 4 },
            ['2'] = { name = 'Publisher', isboss = true, payment = 6 },
        },
    },
    
    telegram = {
        label = 'Telegraph Office',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Messenger', payment = 1 },
            ['1'] = { name = 'Operator', payment = 2 },
            ['2'] = { name = 'Station Manager', isboss = true, payment = 3 },
        },
    },
    
    postman = {
        label = 'Post Office',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Mail Carrier', payment = 1 },
            ['1'] = { name = 'Clerk', payment = 2 },
            ['2'] = { name = 'Postmaster', isboss = true, payment = 4 },
        },
    },
    
    -- ============================================
    -- RELIGIOUS & EDUCATION
    -- ============================================
    priest = {
        label = 'Church',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Deacon', payment = 1 },
            ['1'] = { name = 'Priest', payment = 2 },
            ['2'] = { name = 'Bishop', isboss = true, payment = 3 },
        },
    },
    
    teacher = {
        label = 'School House',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Assistant', payment = 2 },
            ['1'] = { name = 'Teacher', payment = 3 },
            ['2'] = { name = 'Headmaster', isboss = true, payment = 5 },
        },
    },
    
    -- ============================================
    -- GOVERNMENT & JUDICIARY
    -- ============================================
    mayor = {
        label = 'Town Government',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Clerk', payment = 2 },
            ['1'] = { name = 'Council Member', payment = 4 },
            ['2'] = { name = 'Mayor', isboss = true, payment = 8 },
        },
    },
    
    judge = {
        label = 'Judiciary',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Bailiff', payment = 2 },
            ['1'] = { name = 'Magistrate', payment = 6 },
            ['2'] = { name = 'Judge', isboss = true, payment = 10 },
        },
    },
    
    -- ============================================
    -- MISC JOBS
    -- ============================================
    undertaker = {
        label = 'Undertaker',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Assistant', payment = 1 },
            ['1'] = { name = 'Undertaker', isboss = true, payment = 3 },
        },
    },
    
    stable = {
        label = 'Livery Stable',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Stable Boy', payment = 1 },
            ['1'] = { name = 'Stable Hand', payment = 2 },
            ['2'] = { name = 'Stable Owner', isboss = true, payment = 4 },
        },
    },
    
    barber = {
        label = 'Barber Shop',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = { name = 'Apprentice', payment = 1 },
            ['1'] = { name = 'Barber', isboss = true, payment = 2 },
        },
    },
}
