--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Gangs, Families & Factions
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore's faction model. A gang is any organisation the law does not
     licence: outlaw bands, plantation families, city mobs, hill clans, cults.
     The same record shape drives player-made gangs registered at runtime
     (LXRCore.Functions.AddGang) using LXRShared.GangTemplate.

       G(name, label, {
           type        = one of LXRShared.GangTypes,   region = LXRShared.States key,
           hideout     = flavour name (coords belong to the gang resource),
           color       = hex for UI, blip = { sprite, colour },
           maxMembers  = cap the gang resource enforces,  reputation = starting rep with the law (-100..0),
           rivals / allies = { gang keys },   activities = { 'robbery', 'rustling', … },
           illegal     = false for families/companies that are factions, not outlaws,
           grades      = { { name, perms }, … } (index 0 first)
       })

     Grade permissions:
       invite kick promote stash hideout war treasury manage (manage = everything)
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

LXRShared.GangTypes = {
    none    = { label = 'Unaffiliated' },
    outlaw  = { label = 'Outlaw Gang',    illegal = true },
    family  = { label = 'Family',         illegal = false },
    mob     = { label = 'City Mob',       illegal = true },
    clan    = { label = 'Hill Clan',      illegal = true },
    cult    = { label = 'Cult',           illegal = true },
    militia = { label = 'Militia',        illegal = true },
    posse   = { label = 'Posse',          illegal = false },
    custom  = { label = 'Gang',           illegal = true },
}
LXRShared.GangActivities = { 'robbery', 'rustling', 'moonshine', 'smuggling', 'extortion', 'kidnapping', 'bounty', 'counterfeiting', 'gambling', 'poaching' }

local PERM_ALL = { invite = true, kick = true, promote = true, stash = true, hideout = true, war = true, treasury = true, manage = true }
local function perms(list) local p = {} for _, k in ipairs(list or {}) do p[k] = true end return p end

local Gangs = {}
local function G(name, label, o)
    local grades = {}
    for i, g in ipairs(o.grades) do
        grades[tostring(i - 1)] = { name = g[1], perms = g.boss and PERM_ALL or perms(g[2]), isboss = g.boss == true }
    end
    Gangs[name] = {
        name = name, label = label, shortLabel = o.short or label,
        type = o.type or 'custom', region = o.region, hideout = o.hideout, description = o.description or '',
        color = o.color or '#a83a3a', blip = o.blip,
        maxMembers = o.maxMembers or 20, reputation = o.reputation or -20,
        rivals = o.rivals or {}, allies = o.allies or {}, activities = o.activities or {},
        illegal = (o.illegal ~= nil) and o.illegal or (LXRShared.GangTypes[o.type or 'custom'] or {}).illegal ~= false,
        playerMade = o.playerMade == true,
        grades = grades,
    }
end

-- the default ladder for player-made gangs
LXRShared.GangTemplate = {
    { 'Recruit',    {} },
    { 'Member',     { 'stash' } },
    { 'Enforcer',   { 'stash', 'hideout', 'invite' } },
    { 'Lieutenant', { 'stash', 'hideout', 'invite', 'kick', 'promote', 'war' } },
    { 'Boss',       boss = true },
}
local OUTLAW = LXRShared.GangTemplate

G('none', 'No Gang', { type = 'none', short = 'None', illegal = false, maxMembers = 0, reputation = 0, grades = { { 'Unaffiliated', {} } } })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐎 OUTLAW GANGS
-- ═══════════════════════════════════════════════════════════════════════════════
G('vanderlinde', 'Van der Linde Gang', { short = 'VDL', type = 'outlaw', region = 'newhanover', hideout = 'Horseshoe Overlook', color = '#8b1e1e', maxMembers = 25, reputation = -60,
    description = 'Robin Hoods with a philosophy and a growing body count. Loyal, doomed, and famous.',
    rivals = { 'odriscoll', 'pinkerton_agents' }, activities = { 'robbery', 'rustling', 'smuggling' },
    grades = { { 'Hanger-on', {} }, { 'Gun', { 'stash' } }, { 'Trusted Gun', { 'stash', 'hideout', 'invite' } }, { 'Lieutenant', { 'stash', 'hideout', 'invite', 'kick', 'promote', 'war', 'treasury' } }, { 'Leader', boss = true } } })
G('odriscoll', "O'Driscoll Boys", { short = "O'Driscolls", type = 'outlaw', region = 'newhanover', hideout = 'Six Point Cabin', color = '#4f6b2f', maxMembers = 40, reputation = -70,
    description = 'Irish-led rabble: numbers over brains, cruelty over both.',
    rivals = { 'vanderlinde' }, activities = { 'robbery', 'rustling', 'kidnapping', 'moonshine' },
    grades = OUTLAW })
G('lemoyne_raiders', 'Lemoyne Raiders', { short = 'Raiders', type = 'militia', region = 'lemoyne', hideout = 'Shady Belle', color = '#5a5a5a', maxMembers = 40, reputation = -80,
    description = 'Unreconstructed rebels still fighting a war that ended in 1865. Grey coats, stolen artillery.',
    rivals = { 'vanderlinde', 'grays' }, activities = { 'robbery', 'smuggling', 'extortion' },
    grades = { { 'Private', {} }, { 'Corporal', { 'stash' } }, { 'Sergeant', { 'stash', 'hideout', 'invite' } }, { 'Lieutenant', { 'stash', 'hideout', 'invite', 'kick', 'promote', 'war' } }, { 'Colonel', boss = true } } })
G('del_lobo', 'Del Lobo Gang', { short = 'Del Lobos', type = 'outlaw', region = 'newaustin', hideout = 'Fort Mercer', color = '#b8742a', maxMembers = 40, reputation = -75,
    description = 'Bandits of the border. They own the desert south of Armadillo and the law knows it.',
    activities = { 'robbery', 'rustling', 'smuggling', 'kidnapping' },
    grades = { { 'Lobito', {} }, { 'Pistolero', { 'stash' } }, { 'Capitán', { 'stash', 'hideout', 'invite', 'kick' } }, { 'Jefe', boss = true } } })
G('laramie', 'Laramie Gang', { short = 'Laramies', type = 'outlaw', region = 'westelizabeth', hideout = 'Hanging Dog Ranch', color = '#7a4b2a', maxMembers = 25, reputation = -50,
    description = 'Rustlers and land-grabbers pushing ranchers off the Big Valley.',
    activities = { 'rustling', 'extortion' },
    grades = OUTLAW })
G('skinner', 'Skinner Brothers', { short = 'Skinners', type = 'clan', region = 'westelizabeth', hideout = 'Tall Trees', color = '#3b2b1e', maxMembers = 30, reputation = -90,
    description = 'The worst men in the West. Nobody rides through Tall Trees after dark.',
    activities = { 'kidnapping', 'poaching', 'robbery' },
    grades = OUTLAW })
G('murfree', 'Murfree Brood', { short = 'Murfrees', type = 'clan', region = 'newhanover', hideout = "Beaver Hollow", color = '#6b5a3a', maxMembers = 30, reputation = -90,
    description = 'Inbred hill folk of Roanoke Ridge. Traps, caves, and things best not described.',
    activities = { 'kidnapping', 'poaching', 'moonshine' },
    grades = OUTLAW })
G('nightfolk', 'Night Folk', { short = 'Night Folk', type = 'cult', region = 'lemoyne', hideout = 'Bayou Nwa', color = '#2a3b3a', maxMembers = 20, reputation = -95,
    description = 'Silent, painted, and waiting in the swamp. Nobody knows what they want.',
    activities = { 'kidnapping' },
    grades = { { 'Initiate', {} }, { 'Hunter', { 'stash', 'hideout' } }, { 'Elder', boss = true } } })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🏛️ FAMILIES, MOBS & COMPANIES — factions the law tolerates
-- ═══════════════════════════════════════════════════════════════════════════════
G('bronte', "Bronte's Organisation", { short = 'Bronte', type = 'mob', region = 'lemoyne', hideout = 'Bronte Mansion, Saint Denis', color = '#2b2b6b', maxMembers = 30, reputation = -10,
    description = 'Angelo Bronte runs Saint Denis from a mansion with the mayor on the payroll. Business, not banditry — mostly.',
    activities = { 'extortion', 'gambling', 'smuggling', 'counterfeiting' },
    grades = { { 'Associate', {} }, { 'Soldier', { 'stash' } }, { 'Capo', { 'stash', 'hideout', 'invite', 'kick', 'promote' } }, { 'Consigliere', { 'stash', 'hideout', 'invite', 'kick', 'promote', 'war', 'treasury' } }, { 'Don', boss = true } } })
G('grays', 'The Gray Family', { short = 'Grays', type = 'family', region = 'lemoyne', hideout = 'Caliga Hall', color = '#6e6e6e', maxMembers = 20, reputation = 10, illegal = false,
    description = 'Old Lemoyne money, the sheriff of Rhodes in their pocket, and a feud older than the state.',
    rivals = { 'braithwaites', 'lemoyne_raiders' }, activities = { 'moonshine', 'extortion' },
    grades = { { 'Hand', {} }, { 'Cousin', { 'stash' } }, { 'Son', { 'stash', 'hideout', 'invite', 'kick' } }, { 'Patriarch', boss = true } } })
G('braithwaites', 'The Braithwaite Family', { short = 'Braithwaites', type = 'family', region = 'lemoyne', hideout = 'Braithwaite Manor', color = '#8a6f3a', maxMembers = 20, reputation = 10, illegal = false,
    description = 'Plantation aristocrats with a moonshine business and a grudge.',
    rivals = { 'grays' }, activities = { 'moonshine', 'rustling' },
    grades = { { 'Hand', {} }, { 'Cousin', { 'stash' } }, { 'Son', { 'stash', 'hideout', 'invite', 'kick' } }, { 'Matriarch', boss = true } } })
G('foreman', 'Foreman Brothers', { short = 'Foremans', type = 'outlaw', region = 'lemoyne', hideout = 'Clemens Cove', color = '#4a3a2a', maxMembers = 15, reputation = -40,
    description = 'Small-time rustlers and kidnappers on the Lemoyne shore.',
    activities = { 'rustling', 'kidnapping' },
    grades = OUTLAW })
G('pinkerton_agents', 'Pinkerton Field Office', { short = 'Pinkertons', type = 'posse', region = 'lemoyne', hideout = 'Saint Denis', color = '#1e1e2e', maxMembers = 10, reputation = 40, illegal = false,
    description = 'The gang side of the agency: operatives who work outside the law to enforce it. Use the job for the licensed version.',
    rivals = { 'vanderlinde' }, activities = { 'bounty' },
    grades = { { 'Operative', { 'stash' } }, { 'Agent', { 'stash', 'hideout', 'invite' } }, { 'Superintendent', boss = true } } })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 LXRCORE ORIGINALS
-- ═══════════════════════════════════════════════════════════════════════════════
G('wolves', 'The Wolves', { short = 'Wolves', type = 'outlaw', region = 'ambarino', hideout = 'Cotorra Springs', color = '#c4a574', maxMembers = 30, reputation = -30,
    description = 'The pack of the high country. They take from the railroad and the mining company, and leave the homesteads alone. The Land of Wolves is named for them.',
    rivals = { 'odriscoll', 'skinner' }, allies = { 'wapiti_traders' }, activities = { 'robbery', 'smuggling', 'bounty' },
    grades = { { 'Pup', {} }, { 'Wolf', { 'stash' } }, { 'Hunter', { 'stash', 'hideout', 'invite' } }, { 'Pack Leader', { 'stash', 'hideout', 'invite', 'kick', 'promote', 'war', 'treasury' } }, { 'Alpha', boss = true } } })
G('wapiti_traders', 'Wapiti Trading Company', { short = 'Wapiti Co.', type = 'posse', region = 'ambarino', hideout = 'Wapiti', color = '#3a6b4a', maxMembers = 20, reputation = 0, illegal = false,
    description = 'Hunters and traders from the reservation, moving pelts and horses without Cornwall\'s permission.',
    activities = { 'smuggling', 'poaching' },
    grades = { { 'Runner', {} }, { 'Trader', { 'stash', 'invite' } }, { 'Chief Trader', boss = true } } })
G('river_rats', 'Lannahechee River Rats', { short = 'River Rats', type = 'outlaw', region = 'lemoyne', hideout = 'Lagras', color = '#5b7a8a', maxMembers = 20, reputation = -35,
    description = 'Smugglers of the bayou: moonshine upriver, stolen goods down, in pirogues that leave no tracks.',
    activities = { 'smuggling', 'moonshine', 'gambling' },
    grades = OUTLAW })
G('coal_dust', 'Coal Dust Union', { short = 'Union', type = 'militia', region = 'newhanover', hideout = 'Annesburg', color = '#333333', maxMembers = 30, reputation = -15,
    description = 'Miners who had enough of company scrip and company guns. Strikes, sabotage, and a printing press.',
    rivals = { 'pinkerton_agents' }, activities = { 'extortion', 'counterfeiting' },
    grades = { { 'Member', {} }, { 'Picket', { 'stash' } }, { 'Steward', { 'stash', 'hideout', 'invite', 'kick' } }, { 'Union Chief', boss = true } } })

LXRShared.Gangs = Gangs

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 LOOKUPS
-- ═══════════════════════════════════════════════════════════════════════════════
function LXRShared.GangHasPerm(gang, perm)
    if type(gang) ~= 'table' then return false end
    if gang.isboss then return true end
    local def = Gangs[gang.name]
    if not def then return false end
    local g = def.grades[tostring(gang.grade and gang.grade.level or 0)]
    return g ~= nil and g.perms ~= nil and g.perms[perm] == true
end
function LXRShared.GangsAreRivals(a, b)
    local ga = Gangs[a]
    if not ga then return false end
    for _, r in ipairs(ga.rivals) do if r == b then return true end end
    local gb = Gangs[b]
    if gb then for _, r in ipairs(gb.rivals) do if r == a then return true end end end
    return false
end
function LXRShared.GangsInRegion(region)
    local out = {}
    for name, g in pairs(Gangs) do if g.region == region then out[name] = g end end
    return out
end
