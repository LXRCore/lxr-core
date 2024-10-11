LXRShared = LXRShared or {}
LXRShared.Gangs = {
    -- gangs
	{ name = 'none',         label = 'No Gang',           grades = { { name = 'Unaffiliated' } } },
    { name = 'odriscoll',    label = "O'Driscoll Boys",   grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'lemoyne',      label = 'Lemoyne Raiders',   grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'murfree',      label = 'Murfree Brood',     grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'skinner',      label = 'Skinner Brothers',  grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'laramie',      label = 'Laramie Gang',      grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'dellobo',      label = 'Del Lobo Gang',     grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'night',        label = 'Night Folk',        grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'foreman',      label = 'Foreman Brothers',  grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'anderson',     label = 'Anderson Boys',     grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'watson',       label = 'Watson Boys',       grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    -- new gangs
    { name = 'khevsurian_warriors',       label = "Khevsurian Warriors",       grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'gurian_horsemen',           label = "Gurian Horsemen",           grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'svaneti_brigands',          label = "Svaneti Brigands",          grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'tush_rebels',               label = "Tush Rebels",               grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'kartlian_bandits',          label = "Kartlian Bandits",          grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'mingrelian_marauders',      label = "Mingrelian Marauders",      grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'imeretian_outlaws',         label = "Imeretian Outlaws",         grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'adjara_corsairs',           label = "Adjara Corsairs",           grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'kakhetian_raiders',         label = "Kakhetian Raiders",         grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'samtskhe_javakheti_band',   label = "Samtskhe-Javakheti Band",   grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'abkhazian_highlanders',     label = "Abkhazian Highlanders",     grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'sukhumi_shadows',           label = "Sukhumi Shadows",           grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'black_sea_corsairs',        label = "Black Sea Corsairs",        grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'abzhua_bandits',            label = "Abzhua Bandits",            grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },
    { name = 'bzyb_rebels',               label = "Bzyb Rebels",               grades = { { name = 'Recruit' }, { name = 'Enforcer' }, { name = 'Shot Caller' }, { name = 'Boss', isboss = true } } },

    --[[
Config.GangLocations = {
    {name = 'khevsurian_warriors', gangname = "Khevsurian Warriors", coords = vector3(2652.83, -1181.54, 53.33)},  -- Roanoke Ridge
    {name = 'gurian_horsemen', gangname = "Gurian Horsemen", coords = vector3(1329.69, -1302.02, 76.24)},  -- Heartland Oil Fields
    {name = 'svaneti_brigands', gangname = "Svaneti Brigands", coords = vector3(849.17, 1787.36, 201.55)},  -- Grizzlies East
    {name = 'tush_rebels', gangname = "Tush Rebels", coords = vector3(-2068.57, 2501.45, 343.89)},  -- Mount Hagen
    {name = 'kartlian_bandits', gangname = "Kartlian Bandits", coords = vector3(1519.74, 436.36, 90.96)},  -- Flat Iron Lake
    {name = 'mingrelian_marauders', gangname = "Mingrelian Marauders", coords = vector3(-1256.56, 1143.21, 167.18)},  -- Big Valley
    {name = 'imeretian_outlaws', gangname = "Imeretian Outlaws", coords = vector3(-3707.52, -2607.49, -13.33)},  -- Thieves Landing
    {name = 'adjara_corsairs', gangname = "Adjara Corsairs", coords = vector3(3027.51, 561.77, 44.62)},  -- Van Horn Trading Post
    {name = 'kakhetian_raiders', gangname = "Kakhetian Raiders", coords = vector3(728.16, -376.83, 74.21)},  -- Scarlet Meadows
    {name = 'samtskhe_javakheti_band', gangname = "Samtskhe-Javakheti Band", coords = vector3(2571.78, 1082.21, 89.61)},  -- Annesburg
    {name = 'abkhazian_highlanders', gangname = "Abkhazian Highlanders", coords = vector3(1924.93, 1963.61, 264.79)},  -- O'Creagh's Run
    {name = 'sukhumi_shadows', gangname = "Sukhumi Shadows", coords = vector3(2759.96, 1355.34, 72.51)},  -- Elysian Pool
    {name = 'black_sea_corsairs', gangname = "Black Sea Corsairs", coords = vector3(2688.73, -1442.59, 45.65)},  -- Saint Denis
    {name = 'abzhua_bandits', gangname = "Abzhua Bandits", coords = vector3(-1805.32, -399.23, 160.12)},  -- Cumberland Forest
    {name = 'bzyb_rebels', gangname = "Bzyb Rebels", coords = vector3(-254.83, 740.62, 115.96)},  -- Roanoke Ridge
    }
]]

}