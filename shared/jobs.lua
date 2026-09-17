--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Jobs (employment in the five states, 1899)
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore's job model. A job is an organisation with a ladder of grades;
     every grade carries a wage and a permission set the boss menu, stashes,
     armouries and society accounts read. Nothing about a job is hard-coded
     in a resource — lxr-lawman checks `job.type == 'leo'`, the banking
     resource checks `grade.perms.society`, the shop checks `grade.perms.till`.

       J(name, label, {
           type         = one of LXRShared.JobTypes,      category = one of LXRShared.JobCategories,
           town         = LXRShared.Towns key or nil,     description = flavour shown in the job centre,
           defaultDuty  = start on duty,                  offDutyPay = wages while off duty,
           whitelisted  = only admins/boss can assign,    hireable = bosses may hire from the boss menu,
           society      = { account = 'society_<name>', startBalance = $ },
           payroll      = { fromSociety = bool, intervalMin = override },
           uniform      = outfit key for the wardrobe,    blip = { sprite, colour } for the map,
           grades       = { ['0'] = { name, payment, perms = { … }, isboss = bool } },
       })

     Grade permissions (all default false unless the grade says otherwise):
       duty    – may toggle duty            hire    – may hire into lower grades
       fire    – may fire lower grades      promote – may promote/demote below own grade
       stash   – job stash                  armory  – job armoury / evidence locker
       society – society account access     till    – shop till / pricing
       vehicles – job wagons & horses       manage  – boss menu (implies everything)

     Wages are one working day's pay at 1899 rates, in dollars and cents:
     a cowhand $1.00 a day and board, a deputy $2.00, a locomotive engineer
     $4.00, a surgeon $6.00, a United States Marshal $11.00. One paycheck
     (Config.General.paycheck.intervalMin) is one working day.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}
LXRShared.ForceJobDefaultDutyAtLogin = true -- true: duty state reset to defaultDuty on login; false: keep saved duty

LXRShared.JobTypes = {
    none       = { label = 'None' },
    leo        = { label = 'Law Enforcement', armed = true,  arrest = true },
    federal    = { label = 'Federal Agent',   armed = true,  arrest = true },
    medical    = { label = 'Medical',         revive = true },
    government = { label = 'Government' },
    justice    = { label = 'Justice' },
    trade      = { label = 'Trade & Craft' },
    service    = { label = 'Service' },
    industry   = { label = 'Industry' },
    ranch      = { label = 'Ranching & Farming' },
    transport  = { label = 'Transport' },
    press      = { label = 'Press' },
    faith      = { label = 'Faith & Learning' },
    outlaw     = { label = 'Outlaw Trade', illegal = true },
    civ        = { label = 'Civilian' },
}

LXRShared.JobCategories = {
    law = 'Law & Order', medical = 'Medicine', government = 'Government', trade = 'Trades',
    service = 'Services', industry = 'Industry', ranch = 'Ranching', transport = 'Transport',
    culture = 'Press, Faith & Learning', underworld = 'Underworld', none = 'Unemployed',
}

local PERM_ALL = { duty = true, hire = true, fire = true, promote = true, stash = true, armory = true, society = true, till = true, vehicles = true, manage = true }
local function perms(list)
    local p = {}
    for _, k in ipairs(list or {}) do p[k] = true end
    return p
end

local Jobs = {}
local function J(name, label, o)
    local grades = {}
    for i, g in ipairs(o.grades) do
        local key = tostring(i - 1)
        grades[key] = {
            name = g[1], payment = g[2],
            perms = g.boss and PERM_ALL or perms(g[3]),
            isboss = g.boss == true,
        }
    end
    Jobs[name] = {
        name = name, label = label, shortLabel = o.short or label,
        type = o.type or 'civ', category = o.category or 'service', town = o.town,
        description = o.description or '',
        defaultDuty = o.defaultDuty == true, offDutyPay = o.offDutyPay == true,
        whitelisted = o.whitelisted == true, hireable = o.hireable ~= false,
        society = o.society ~= false and { account = 'society_' .. name, startBalance = o.startBalance or 0 } or nil,
        payroll = { fromSociety = o.fromSociety == true },
        uniform = o.uniform, blip = o.blip, tags = o.tags or {},
        grades = grades,
    }
end

-- shared ladders ---------------------------------------------------------------
local function lawLadder(chiefTitle, deputyTitle)
    return {
        { 'Recruit', 1.50, { 'duty' } },
        { deputyTitle or 'Deputy', 2.00, { 'duty', 'stash', 'armory' } },
        { 'Senior ' .. (deputyTitle or 'Deputy'), 2.50, { 'duty', 'stash', 'armory', 'vehicles' } },
        { 'Under-' .. (chiefTitle or 'Sheriff'), 3.00, { 'duty', 'stash', 'armory', 'vehicles', 'hire', 'fire', 'promote' } },
        { chiefTitle or 'Sheriff', 4.00, boss = true },
    }
end
local function doctorLadder()
    return {
        { 'Orderly', 1, { 'duty' } },
        { 'Nurse', 1.25, { 'duty', 'stash' } },
        { 'Physician', 4, { 'duty', 'stash', 'vehicles' } },
        { 'Surgeon', 6, { 'duty', 'stash', 'vehicles', 'hire', 'promote' } },
        { 'Head Doctor', 8, boss = true },
    }
end
local function shopLadder(ownerTitle, workerTitle)
    return {
        { workerTitle or 'Apprentice', 0.75, { 'duty', 'stash' } },
        { 'Journeyman', 2, { 'duty', 'stash', 'till' } },
        { 'Foreman', 3, { 'duty', 'stash', 'till', 'hire', 'promote' } },
        { ownerTitle or 'Proprietor', 4.00, boss = true },
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🚫 UNEMPLOYED
-- ═══════════════════════════════════════════════════════════════════════════════
J('unemployed', 'Drifter', { short = 'Drifter', type = 'none', category = 'none', defaultDuty = true, society = false, hireable = false,
    description = 'No employer, no wage, no rules but your own.',
    grades = { { 'Drifter', 0 } } })

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⭐ LAW & ORDER — one office per town, marshals and Pinkertons above them
-- ═══════════════════════════════════════════════════════════════════════════════
J('vallaw', "Valentine Sheriff's Office",   { short = 'VSO', type = 'leo', category = 'law', town = 'valentine',  whitelisted = true, startBalance = 500, uniform = 'law_valentine', blip = { sprite = 'blip_ambient_sheriff', colour = 'BLIP_MODIFIER_MP_COLOR_4' }, description = 'Cattle town law. Drunks on Saturday, rustlers on Sunday.', grades = lawLadder('Sheriff') })
J('rholaw', "Rhodes Sheriff's Office",      { short = 'RSO', type = 'leo', category = 'law', town = 'rhodes',     whitelisted = true, startBalance = 500, uniform = 'law_rhodes', description = 'Keeping the Grays and Braithwaites from burning the town down. Again.', grades = lawLadder('Sheriff') })
J('strlaw', "Strawberry Sheriff's Office",  { short = 'SSO', type = 'leo', category = 'law', town = 'strawberry', whitelisted = true, startBalance = 400, uniform = 'law_strawberry', description = 'Mountain town, one cell, a mayor with ambitions.', grades = lawLadder('Sheriff') })
J('annlaw', "Annesburg Sheriff's Office",   { short = 'ASO', type = 'leo', category = 'law', town = 'annesburg',  whitelisted = true, startBalance = 400, uniform = 'law_annesburg', description = 'Company town. The mine pays the wages, remember that.', grades = lawLadder('Sheriff') })
J('armlaw', "Armadillo Sheriff's Office",   { short = 'AMO', type = 'leo', category = 'law', town = 'armadillo',  whitelisted = true, startBalance = 400, uniform = 'law_armadillo', description = 'Desert law. Cholera took the last sheriff.', grades = lawLadder('Sheriff') })
J('tumlaw', "Tumbleweed Sheriff's Office",  { short = 'TSO', type = 'leo', category = 'law', town = 'tumbleweed', whitelisted = true, startBalance = 400, uniform = 'law_tumbleweed', description = 'Last stop before Mexico. Del Lobos ride through when they please.', grades = lawLadder('Sheriff') })
J('blklaw', "Blackwater Marshal's Office",  { short = 'BMO', type = 'leo', category = 'law', town = 'blackwater', whitelisted = true, startBalance = 800, uniform = 'law_blackwater', description = 'Modern policing for a modern town, with a ferry-robbery to live down.', grades = lawLadder('Marshal', 'Officer') })
J('sdlaw',  'Saint Denis Police Department',{ short = 'SDPD', type = 'leo', category = 'law', town = 'saintdenis', whitelisted = true, startBalance = 1500, uniform = 'law_saintdenis', description = 'Uniforms, precincts, a chief who answers to the mayor and the mayor who answers to Bronte.', grades = {
    { 'Cadet', 1.50, { 'duty' } },
    { 'Patrolman', 2.25, { 'duty', 'stash', 'armory' } },
    { 'Sergeant', 3, { 'duty', 'stash', 'armory', 'vehicles' } },
    { 'Detective', 3.50, { 'duty', 'stash', 'armory', 'vehicles', 'hire' } },
    { 'Captain', 4.50, { 'duty', 'stash', 'armory', 'vehicles', 'hire', 'fire', 'promote' } },
    { 'Chief of Police', 6, boss = true },
} })
J('usmarshal', 'United States Marshals Service', { short = 'USMS', type = 'federal', category = 'law', whitelisted = true, startBalance = 2000, uniform = 'law_marshal', description = 'Federal warrants, cross-state pursuit, and the authority to deputise a posse.', grades = {
    { 'Deputy Marshal', 3, { 'duty', 'stash', 'armory', 'vehicles' } },
    { 'Senior Deputy', 2.50, { 'duty', 'stash', 'armory', 'vehicles', 'hire', 'promote' } },
    { 'Chief Deputy', 5, { 'duty', 'stash', 'armory', 'vehicles', 'hire', 'fire', 'promote', 'society' } },
    { 'United States Marshal', 11, boss = true },
} })
J('pinkerton', 'Pinkerton National Detective Agency', { short = 'Pinkerton', type = 'federal', category = 'law', town = 'saintdenis', whitelisted = true, startBalance = 5000, uniform = 'pinkerton', description = 'We never sleep. Hired by railroads, banks and anyone else with a grudge and a chequebook.', grades = {
    { 'Operative', 3, { 'duty', 'stash', 'armory' } },
    { 'Senior Agent', 5, { 'duty', 'stash', 'armory', 'vehicles', 'hire' } },
    { 'Superintendent', 10, boss = true },
} })
J('prison', 'Sisika Penitentiary', { short = 'Sisika', type = 'leo', category = 'law', whitelisted = true, startBalance = 300, uniform = 'prison_guard', description = 'Island prison. Nobody escapes, except the ones who do.', grades = {
    { 'Guard', 1.75, { 'duty', 'stash' } },
    { 'Senior Guard', 2.25, { 'duty', 'stash', 'armory' } },
    { 'Warden', 6, boss = true },
} })
J('bountyhunter', 'Licensed Bounty Hunter', { short = 'Bounty', type = 'civ', category = 'law', defaultDuty = true, society = false, hireable = false, description = 'You bring them in; the county pays. Alive pays more.', grades = {
    { 'Greenhorn', 0, { 'duty' } },
    { 'Bounty Hunter', 0, { 'duty' } },
    { 'Manhunter', 0, { 'duty' } },
} })

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⚕️ MEDICINE
-- ═══════════════════════════════════════════════════════════════════════════════
J('valdoc', "Valentine Doctor's Office",   { short = 'Doctor', type = 'medical', category = 'medical', town = 'valentine',  whitelisted = true, startBalance = 300, uniform = 'doctor', description = 'Gunshot Tuesdays, births on Wednesdays.', grades = doctorLadder() })
J('rhodoc', "Rhodes Doctor's Office",      { short = 'Doctor', type = 'medical', category = 'medical', town = 'rhodes',     whitelisted = true, startBalance = 300, uniform = 'doctor', description = 'Malaria, feuds and the occasional honest fever.', grades = doctorLadder() })
J('strdoc', 'Strawberry Infirmary',        { short = 'Doctor', type = 'medical', category = 'medical', town = 'strawberry', whitelisted = true, startBalance = 250, uniform = 'doctor', description = 'Logging accidents and bear maulings.', grades = doctorLadder() })
J('blkdoc', 'Blackwater Physician',        { short = 'Doctor', type = 'medical', category = 'medical', town = 'blackwater', whitelisted = true, startBalance = 400, uniform = 'doctor', description = 'A modern practice with an electric lamp.', grades = doctorLadder() })
J('sddoc',  'Saint Denis General Hospital',{ short = 'Hospital', type = 'medical', category = 'medical', town = 'saintdenis', whitelisted = true, startBalance = 1000, uniform = 'doctor', description = 'Wards, surgeons, a morgue that is never empty.', grades = doctorLadder() })
J('armdoc', 'Armadillo Doctor',            { short = 'Doctor', type = 'medical', category = 'medical', town = 'armadillo',  whitelisted = true, startBalance = 200, uniform = 'doctor', description = 'One doctor for the whole of New Austin.', grades = doctorLadder() })
J('undertaker', 'Undertaker', { type = 'service', category = 'medical', startBalance = 150, uniform = 'undertaker', description = 'Coffins, burials, and the paperwork of death. Every town needs one.', grades = {
    { 'Gravedigger', 1.50, { 'duty', 'stash' } },
    { 'Mortician', 2, { 'duty', 'stash', 'vehicles' } },
    { 'Undertaker', 3, boss = true },
} })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🏛️ GOVERNMENT, JUSTICE & MONEY
-- ═══════════════════════════════════════════════════════════════════════════════
J('mayor', "Office of the Mayor of Saint Denis", { short = 'Mayor', type = 'government', category = 'government', town = 'saintdenis', whitelisted = true, startBalance = 10000, description = 'Taxes, permits, ribbon-cuttings and favours.', grades = {
    { 'Clerk', 2, { 'duty', 'stash' } },
    { 'Alderman', 3, { 'duty', 'stash', 'society' } },
    { 'Deputy Mayor', 5, { 'duty', 'stash', 'society', 'hire', 'fire', 'promote' } },
    { 'Mayor', 8, boss = true },
} })
J('court', 'Territorial Court', { short = 'Court', type = 'justice', category = 'government', whitelisted = true, startBalance = 2000, description = 'Warrants, trials, hangings. The judge rides the circuit; the clerk stays.', grades = {
    { 'Bailiff', 2, { 'duty', 'stash' } },
    { 'Court Clerk', 3, { 'duty', 'stash', 'society' } },
    { 'Attorney', 5, { 'duty', 'stash' } },
    { 'Judge', 12, boss = true },
} })
J('bank', 'Lemoyne National Bank', { short = 'Bank', type = 'government', category = 'government', whitelisted = true, startBalance = 50000, uniform = 'banker', description = 'Branches in every town worth robbing. Loans, safes, wires.', grades = {
    { 'Teller', 2.50, { 'duty', 'till' } },
    { 'Clerk', 2, { 'duty', 'till', 'stash' } },
    { 'Branch Manager', 6, { 'duty', 'till', 'stash', 'society', 'hire', 'fire', 'promote' } },
    { 'Bank President', 15, boss = true },
} })
J('postal', 'U.S. Post & Telegraph', { short = 'Post', type = 'government', category = 'transport', startBalance = 500, uniform = 'postal', description = 'Letters, parcels, telegrams and the mail wagon that everyone wants to rob.', grades = {
    { 'Mail Carrier', 2.50, { 'duty', 'vehicles' } },
    { 'Telegraph Operator', 2, { 'duty', 'stash' } },
    { 'Postmaster', 4, boss = true },
} })
J('railroad', 'Central Union Railroad', { short = 'Railroad', type = 'transport', category = 'transport', startBalance = 5000, uniform = 'railroad', description = 'The line that stitched the states together. Conductors, brakemen, station agents.', grades = {
    { 'Brakeman', 2, { 'duty' } },
    { 'Station Agent', 2.50, { 'duty', 'stash', 'till' } },
    { 'Engineer', 4, { 'duty', 'stash', 'vehicles' } },
    { 'Conductor', 3.50, { 'duty', 'stash', 'vehicles', 'hire', 'promote' } },
    { 'Superintendent', 10, boss = true },
} })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔨 TRADES & SHOPS
-- ═══════════════════════════════════════════════════════════════════════════════
J('blacksmith', 'Blacksmith',      { type = 'trade', category = 'trade', startBalance = 200, uniform = 'blacksmith', description = 'Horseshoes, tools, wagon tyres, and the odd repaired revolver.', tags = { 'crafting' }, grades = shopLadder('Master Smith', 'Striker') })
J('gunsmith',   'Gunsmith',        { type = 'trade', category = 'trade', startBalance = 400, uniform = 'gunsmith', description = 'Sells, repairs, engraves. Asks no questions about the last owner.', tags = { 'crafting', 'weapons' }, grades = shopLadder('Master Gunsmith') })
J('general',    'General Store',   { type = 'trade', category = 'trade', startBalance = 300, uniform = 'clerk', description = 'Flour, tins, ammunition, and gossip.', grades = shopLadder('Storekeeper', 'Stock Boy') })
J('tailor',     'Tailor',          { type = 'trade', category = 'trade', startBalance = 200, uniform = 'tailor', description = 'Suits, dresses, and repairs to the coat you were shot in.', tags = { 'crafting' }, grades = shopLadder('Master Tailor', 'Seamstress') })
J('barber',     'Barber',          { type = 'service', category = 'service', startBalance = 100, uniform = 'barber', description = 'A shave, a haircut, and everything that happened in town this week.', grades = shopLadder('Barber', 'Lather Boy') })
J('butcher',    'Butcher',         { type = 'trade', category = 'trade', startBalance = 200, uniform = 'butcher', description = 'Buys carcasses and pelts, sells meat.', tags = { 'hunting' }, grades = shopLadder('Master Butcher', 'Cutter') })
J('baker',      'Bakery',          { type = 'trade', category = 'trade', startBalance = 150, uniform = 'baker', description = 'Up at four, bread by six.', tags = { 'cooking' }, grades = shopLadder('Baker', 'Dough Boy') })
J('saloon',     'Saloon',          { type = 'service', category = 'service', startBalance = 500, uniform = 'bartender', description = 'Whiskey, cards, rooms upstairs, and a piano that has seen things.', tags = { 'cooking' }, grades = {
    { 'Swamper', 0.75, { 'duty', 'stash' } },
    { 'Bartender', 2, { 'duty', 'stash', 'till' } },
    { 'Head Barman', 2.50, { 'duty', 'stash', 'till', 'hire', 'promote' } },
    { 'Saloon Owner', 5, boss = true },
} })
J('hotel',      'Hotel',           { type = 'service', category = 'service', startBalance = 400, uniform = 'clerk', description = 'Rooms, baths, and a register full of false names.', grades = shopLadder('Hotelier', 'Bellhop') })
J('stable',     'Stable',          { type = 'ranch', category = 'ranch', startBalance = 800, uniform = 'stablehand', description = 'Buys, sells, boards and shoes horses.', tags = { 'horses' }, grades = shopLadder('Stable Master', 'Stable Hand') })
J('carpenter',  'Carpenter',       { type = 'trade', category = 'trade', startBalance = 200, uniform = 'carpenter', description = 'Coffins, furniture, wagons and the gallows.', tags = { 'crafting' }, grades = shopLadder('Master Carpenter') })
J('photographer','Photographer',   { type = 'service', category = 'culture', startBalance = 100, description = 'Hold still. Portraits, weddings, and the occasional corpse.', grades = shopLadder('Photographer', 'Assistant') })
J('trader',     'Trading Post',    { type = 'trade', category = 'trade', startBalance = 600, description = 'Buys pelts, herbs and curiosities; sells whatever came in on the last wagon.', tags = { 'hunting' }, grades = shopLadder('Trader', 'Clerk') })
J('apothecary', 'Apothecary',      { type = 'trade', category = 'medical', startBalance = 250, description = 'Tonics, powders and pills — some of them even work.', tags = { 'herbalism' }, grades = shopLadder('Apothecary', 'Assistant') })

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⛏️ INDUSTRY, RANCH & LAND
-- ═══════════════════════════════════════════════════════════════════════════════
J('mining',   'Annesburg Mining Company', { short = 'Mining Co.', type = 'industry', category = 'industry', town = 'annesburg', startBalance = 3000, uniform = 'miner', description = 'Coal and iron, ten hours a day, paid in scrip if the company can get away with it.', tags = { 'mining' }, grades = {
    { 'Mucker', 1.75, { 'duty' } },
    { 'Miner', 2.50, { 'duty', 'stash' } },
    { 'Blaster', 3, { 'duty', 'stash', 'armory' } },
    { 'Shift Boss', 4, { 'duty', 'stash', 'armory', 'vehicles', 'hire', 'promote' } },
    { 'Mine Superintendent', 8, boss = true },
} })
J('lumber',   'Lumber Camp',   { type = 'industry', category = 'industry', startBalance = 1000, uniform = 'logger', description = 'Fell it, buck it, float it downriver.', tags = { 'forestry' }, grades = {
    { 'Swamper', 0.75, { 'duty' } },
    { 'Sawyer', 2.25, { 'duty', 'stash' } },
    { 'Faller', 3, { 'duty', 'stash', 'vehicles' } },
    { 'Camp Boss', 5, boss = true },
} })
J('oil',      'Cornwall Kerosene & Tar', { short = 'Cornwall', type = 'industry', category = 'industry', startBalance = 5000, uniform = 'oilworker', description = 'Derricks, refineries and a name that opens doors in Saint Denis.', grades = {
    { 'Roustabout', 2, { 'duty' } },
    { 'Driller', 3.50, { 'duty', 'stash' } },
    { 'Tool Pusher', 4.50, { 'duty', 'stash', 'vehicles', 'hire' } },
    { 'Field Manager', 8, boss = true },
} })
J('rancher',  'Ranch',         { type = 'ranch', category = 'ranch', defaultDuty = true, startBalance = 500, uniform = 'rancher', description = 'Cattle, horses, fences and weather.', tags = { 'horses' }, grades = {
    { 'Ranch Hand', 1, { 'duty', 'stash' } },
    { 'Wrangler', 1.25, { 'duty', 'stash', 'vehicles' } },
    { 'Foreman', 2, { 'duty', 'stash', 'vehicles', 'hire', 'promote' } },
    { 'Rancher', 4, boss = true },
} })
J('farmer',   'Farm',          { type = 'ranch', category = 'ranch', defaultDuty = true, startBalance = 300, uniform = 'farmer', description = 'Corn, wheat, sugar beet and hogs.', grades = {
    { 'Field Hand', 1, { 'duty', 'stash' } },
    { 'Ploughman', 1.25, { 'duty', 'stash', 'vehicles' } },
    { 'Farmer', 3, boss = true },
} })
J('fisherman','Fishery',       { type = 'industry', category = 'industry', defaultDuty = true, startBalance = 200, description = 'Nets on the Lannahechee, lines in Flat Iron Lake.', tags = { 'fishing' }, grades = {
    { 'Deckhand', 1.25, { 'duty', 'stash' } },
    { 'Fisherman', 2, { 'duty', 'stash', 'vehicles' } },
    { 'Skipper', 3.50, boss = true },
} })
J('hunter',   'Trapper',       { type = 'civ', category = 'industry', defaultDuty = true, society = false, hireable = false, description = 'Pelts to the trapper, meat to the butcher, and the wilderness to yourself.', tags = { 'hunting' }, grades = {
    { 'Greenhorn', 0, { 'duty' } },
    { 'Trapper', 0, { 'duty' } },
    { 'Master Trapper', 0, { 'duty' } },
} })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🚂 TRANSPORT
-- ═══════════════════════════════════════════════════════════════════════════════
J('stageline', 'Stagecoach Line', { type = 'transport', category = 'transport', startBalance = 800, uniform = 'coachman', description = 'Passengers, strongboxes and a shotgun rider.', grades = {
    { 'Stable Boy', 0.75, { 'duty' } },
    { 'Shotgun Rider', 2, { 'duty', 'armory' } },
    { 'Driver', 2.50, { 'duty', 'vehicles', 'till' } },
    { 'Line Manager', 4, boss = true },
} })
J('freight',  'Freight Company', { type = 'transport', category = 'transport', startBalance = 1000, description = 'Hauling for anyone who pays: ore, lumber, whiskey, and no questions.', grades = {
    { 'Loader', 1.50, { 'duty', 'stash' } },
    { 'Teamster', 2.50, { 'duty', 'stash', 'vehicles' } },
    { 'Dispatcher', 4, boss = true },
} })
J('ferry',    'Ferryman',       { type = 'transport', category = 'transport', startBalance = 200, description = 'Across the river, five cents a head.', grades = {
    { 'Deckhand', 1.25, { 'duty' } },
    { 'Ferryman', 2.50, boss = true },
} })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📰 PRESS, FAITH & LEARNING
-- ═══════════════════════════════════════════════════════════════════════════════
J('press',    'Saint Denis Times', { short = 'Press', type = 'press', category = 'culture', town = 'saintdenis', startBalance = 400, description = 'All the news, and some of it true.', grades = {
    { 'Newsboy', 0.25, { 'duty' } },
    { 'Reporter', 2.50, { 'duty', 'stash' } },
    { 'Editor', 5, boss = true },
} })
J('church',   'Church',            { type = 'faith', category = 'culture', startBalance = 100, uniform = 'preacher', description = 'Weddings, funerals, confessions and a roof for the lost.', grades = {
    { 'Deacon', 0.50, { 'duty', 'stash' } },
    { 'Preacher', 2, boss = true },
} })
J('school',   'Schoolhouse',       { type = 'faith', category = 'culture', startBalance = 100, description = 'Letters and sums for the children of the frontier.', grades = {
    { 'Assistant', 0.75, { 'duty' } },
    { 'Schoolteacher', 1.30, boss = true },
} })
J('theatre',  'Théâtre Râleur',    { short = 'Theatre', type = 'service', category = 'culture', town = 'saintdenis', startBalance = 600, description = 'Vaudeville, opera, and whatever fills seats.', grades = {
    { 'Stagehand', 1, { 'duty', 'stash' } },
    { 'Performer', 2, { 'duty', 'stash' } },
    { 'Impresario', 5, boss = true },
} })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🌑 UNDERWORLD — jobs with a payroll but no licence
-- ═══════════════════════════════════════════════════════════════════════════════
J('moonshiner', 'Moonshine Still', { type = 'outlaw', category = 'underworld', whitelisted = true, startBalance = 0, description = 'Mash, boil, bottle, run. Revenue agents pay by the still.', tags = { 'distilling', 'illegal' }, grades = {
    { 'Runner', 0, { 'duty', 'vehicles' } },
    { 'Cooker', 0, { 'duty', 'stash' } },
    { 'Shiner', 0, boss = true },
} })
J('fence',    'Fence',            { type = 'outlaw', category = 'underworld', whitelisted = true, startBalance = 1000, description = 'Buys what should not be sold, sells what cannot be bought.', tags = { 'illegal' }, grades = {
    { 'Runner', 0, { 'duty' } },
    { 'Fence', 0, boss = true },
} })

LXRShared.Jobs = Jobs

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 LOOKUPS
-- ═══════════════════════════════════════════════════════════════════════════════
function LXRShared.JobsOfType(jobType)
    local out = {}
    for name, j in pairs(Jobs) do if j.type == jobType then out[name] = j end end
    return out
end
function LXRShared.JobsInTown(town)
    local out = {}
    for name, j in pairs(Jobs) do if j.town == town then out[name] = j end end
    return out
end
---True when the grade of `job` (a PlayerData.job table) has permission `perm`.
function LXRShared.JobHasPerm(job, perm)
    if type(job) ~= 'table' then return false end
    if job.isboss then return true end
    local def = Jobs[job.name]
    if not def then return false end
    local g = def.grades[tostring(job.grade and job.grade.level or 0)]
    return g ~= nil and g.perms ~= nil and g.perms[perm] == true
end
