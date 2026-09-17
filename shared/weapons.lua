--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Weapons, Ammunition & Components
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore's weapon model. Every weapon item in shared/items.lua has one
     record here; the two are cross-checked by the catalog validator.

       W(model, label, category, {
           ammo      = default ammo item,          ammoTypes = { every ammo item it chambers }
           clip      = rounds in the gun,          stats = { damage, range, rate, accuracy, reload } (1–10)
           era       = first year it existed,      maker = manufacturer,
           dual      = can be dual-wielded,        slot = holster slot the weapon wheel uses,
           degrade   = condition lost per shot (%),
           components = { component keys the gunsmith can fit },
       })

     Categories (LXRShared.WeaponCategories) carry the slot, whether the
     weapon is drawn from a holster or the horse, and the default cleaning
     item. Ammo classes (LXRShared.AmmoClasses) map to the game's AMMO_*
     hashes and say what a box holds. Components (LXRShared.WeaponComponents)
     are the customisation vocabulary for a gunsmith resource: it never needs
     a hard-coded list.

     Model names are the RDR2 weapon hashes (build 1491). Anything added here
     without an in-game test is marked NOT TESTED in docs/data.md.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

LXRShared.WeaponCategories = {
    revolver = { label = 'Revolvers',   slot = 'sidearm',  onHorse = false, cleaning = 'cleaning_kit', maxCarry = 2, xpSkill = 'gunslinging' },
    pistol   = { label = 'Pistols',     slot = 'sidearm',  onHorse = false, cleaning = 'cleaning_kit', maxCarry = 2, xpSkill = 'gunslinging' },
    repeater = { label = 'Repeaters',   slot = 'longarm',  onHorse = true,  cleaning = 'cleaning_kit', maxCarry = 2, xpSkill = 'marksman' },
    rifle    = { label = 'Rifles',      slot = 'longarm',  onHorse = true,  cleaning = 'cleaning_kit', maxCarry = 2, xpSkill = 'marksman' },
    sniper   = { label = 'Sniper Rifles', slot = 'longarm', onHorse = true, cleaning = 'cleaning_kit', maxCarry = 2, xpSkill = 'marksman' },
    shotgun  = { label = 'Shotguns',    slot = 'longarm',  onHorse = true,  cleaning = 'cleaning_kit', maxCarry = 2, xpSkill = 'marksman' },
    bow      = { label = 'Bows',        slot = 'longarm',  onHorse = true,  cleaning = 'whetstone',    maxCarry = 1, xpSkill = 'hunting' },
    melee    = { label = 'Melee',       slot = 'melee',    onHorse = false, cleaning = 'whetstone',    maxCarry = 1, xpSkill = 'main' },
    thrown   = { label = 'Throwables',  slot = 'thrown',   onHorse = false, cleaning = nil,            maxCarry = 1, xpSkill = 'main' },
    kit      = { label = 'Kit',         slot = 'kit',      onHorse = false, cleaning = nil,            maxCarry = 99, xpSkill = 'main' },
}

-- ammo item → game ammo type. `box` is how many rounds one item represents.
local AmmoClasses = {}
LXRShared.AmmoClasses = AmmoClasses
local function ammoClass(item, hash, box, mods)
    AmmoClasses[item] = { item = item, hash = joaat(hash), gameName = hash, box = box or 1, mods = mods or {} }
end
ammoClass('ammo_revolver',             'AMMO_REVOLVER',              1)
ammoClass('ammo_revolver_express',     'AMMO_REVOLVER_EXPRESS',      1, { damage = 1.15 })
ammoClass('ammo_revolver_highvelocity','AMMO_REVOLVER_HIGH_VELOCITY',1, { range = 1.2 })
ammoClass('ammo_revolver_split',       'AMMO_REVOLVER_SPLIT_POINT',  1, { damage = 1.1, accuracy = 1.05 })
ammoClass('ammo_revolver_explosive',   'AMMO_REVOLVER_EXPLOSIVE',    1, { damage = 2.0 })
ammoClass('ammo_pistol',               'AMMO_PISTOL',                1)
ammoClass('ammo_pistol_express',       'AMMO_PISTOL_EXPRESS',        1, { damage = 1.15 })
ammoClass('ammo_pistol_highvelocity',  'AMMO_PISTOL_HIGH_VELOCITY',  1, { range = 1.2 })
ammoClass('ammo_pistol_split',         'AMMO_PISTOL_SPLIT_POINT',    1, { damage = 1.1 })
ammoClass('ammo_pistol_explosive',     'AMMO_PISTOL_EXPLOSIVE',      1, { damage = 2.0 })
ammoClass('ammo_repeater',             'AMMO_REPEATER',              1)
ammoClass('ammo_repeater_express',     'AMMO_REPEATER_EXPRESS',      1, { damage = 1.15 })
ammoClass('ammo_repeater_highvelocity','AMMO_REPEATER_HIGH_VELOCITY',1, { range = 1.2 })
ammoClass('ammo_repeater_split',       'AMMO_REPEATER_SPLIT_POINT',  1, { damage = 1.1 })
ammoClass('ammo_repeater_explosive',   'AMMO_REPEATER_EXPLOSIVE',    1, { damage = 2.0 })
ammoClass('ammo_rifle',                'AMMO_RIFLE',                 1)
ammoClass('ammo_rifle_express',        'AMMO_RIFLE_EXPRESS',         1, { damage = 1.15 })
ammoClass('ammo_rifle_highvelocity',   'AMMO_RIFLE_HIGH_VELOCITY',   1, { range = 1.2 })
ammoClass('ammo_rifle_split',          'AMMO_RIFLE_SPLIT_POINT',     1, { damage = 1.1 })
ammoClass('ammo_rifle_explosive',      'AMMO_RIFLE_EXPLOSIVE',       1, { damage = 2.0 })
ammoClass('ammo_rifle_elephant',       'AMMO_RIFLE_ELEPHANT',        1)
ammoClass('ammo_rifle_varmint',        'AMMO_22',                    1)
ammoClass('ammo_shotgun',              'AMMO_SHOTGUN',               1)
ammoClass('ammo_shotgun_slug',         'AMMO_SHOTGUN_SLUG',          1, { range = 1.5, damage = 1.2 })
ammoClass('ammo_shotgun_incendiary',   'AMMO_SHOTGUN_INCENDIARY',    1, { fire = true })
ammoClass('ammo_shotgun_explosive',    'AMMO_SHOTGUN_EXPLOSIVE',     1, { damage = 2.0 })
ammoClass('ammo_arrow',                'AMMO_ARROW',                 1)
ammoClass('ammo_arrow_improved',       'AMMO_ARROW_IMPROVED',        1, { damage = 1.25 })
ammoClass('ammo_arrow_smallgame',      'AMMO_ARROW_SMALL_GAME',      1, { pelt = true })
ammoClass('ammo_arrow_poison',         'AMMO_ARROW_POISON',          1, { poison = true })
ammoClass('ammo_arrow_fire',           'AMMO_ARROW_FIRE',            1, { fire = true })
ammoClass('ammo_arrow_dynamite',       'AMMO_ARROW_DYNAMITE',        1, { damage = 3.0 })
LXRShared.Ammo = AmmoClasses

-- gunsmith vocabulary (component hash names are the game's; NOT TESTED beyond the common ones)
LXRShared.WeaponComponents = {
    -- barrels / sights
    barrel_long        = { label = 'Long Barrel',          group = 'barrel', price = 8,  stat = { range = 1, accuracy = 1 }, fits = { 'revolver', 'pistol' } },
    barrel_short       = { label = 'Short Barrel',         group = 'barrel', price = 6,  stat = { rate = 1, range = -1 }, fits = { 'revolver', 'pistol' } },
    sight_improved     = { label = 'Improved Sights',      group = 'sight',  price = 6,  stat = { accuracy = 1 }, fits = { 'revolver', 'pistol', 'repeater', 'rifle', 'shotgun' } },
    scope_short        = { label = 'Short Scope',          group = 'scope',  price = 15, stat = { accuracy = 2 }, fits = { 'rifle', 'sniper', 'repeater' } },
    scope_medium       = { label = 'Medium Scope',         group = 'scope',  price = 22, stat = { accuracy = 2, range = 1 }, fits = { 'rifle', 'sniper' } },
    scope_long         = { label = 'Long Scope',           group = 'scope',  price = 30, stat = { accuracy = 3, range = 2 }, fits = { 'sniper', 'rifle' } },
    -- grips, stocks, rifling
    grip_wood          = { label = 'Wood Grip',            group = 'grip',   price = 4,  stat = {}, fits = { 'revolver', 'pistol' } },
    grip_ivory         = { label = 'Ivory Grip',           group = 'grip',   price = 25, stat = {}, fits = { 'revolver', 'pistol' }, rarity = 'rare' },
    grip_pearl         = { label = 'Pearl Grip',           group = 'grip',   price = 30, stat = {}, fits = { 'revolver', 'pistol' }, rarity = 'rare' },
    stock_improved     = { label = 'Improved Stock',       group = 'stock',  price = 10, stat = { accuracy = 1 }, fits = { 'repeater', 'rifle', 'shotgun' } },
    rifling_improved   = { label = 'Improved Rifling',     group = 'rifling',price = 12, stat = { accuracy = 1, range = 1 }, fits = { 'revolver', 'pistol', 'repeater', 'rifle', 'sniper' } },
    -- finishes
    finish_blued       = { label = 'Blued Steel',          group = 'finish', price = 5,  stat = {}, cosmetic = true },
    finish_nickel      = { label = 'Nickel Plate',         group = 'finish', price = 10, stat = {}, cosmetic = true },
    finish_silver      = { label = 'Silver Plate',         group = 'finish', price = 20, stat = {}, cosmetic = true },
    finish_gold        = { label = 'Gold Plate',           group = 'finish', price = 45, stat = {}, cosmetic = true, rarity = 'rare' },
    engraving_simple   = { label = 'Simple Engraving',     group = 'engrave',price = 8,  stat = {}, cosmetic = true },
    engraving_floral   = { label = 'Floral Engraving',     group = 'engrave',price = 18, stat = {}, cosmetic = true },
    engraving_scroll   = { label = 'Scroll Engraving',     group = 'engrave',price = 25, stat = {}, cosmetic = true },
    wrap_leather       = { label = 'Leather Wrap',         group = 'wrap',   price = 3,  stat = {}, cosmetic = true },
}

local Weapons, ByName = {}, {}
local function W(model, label, category, o)
    o = o or {}
    local rec = {
        name = model, label = label, hash = joaat(model:upper()), category = category,
        slot = (LXRShared.WeaponCategories[category] or {}).slot,
        ammo = o.ammo, ammoTypes = o.ammoTypes or (o.ammo and { o.ammo } or {}),
        clip = o.clip or 0, stats = o.stats or {}, era = o.era or 1899, maker = o.maker,
        dual = o.dual == true, degrade = o.degrade or 0.05, components = o.components or {},
        image = model .. '.png', type = category,   -- `type` kept for resources that read the old shape
        ammotype = o.ammo,                            -- legacy field name
    }
    Weapons[rec.hash] = rec
    ByName[model] = rec
    return rec
end

local REV = { 'ammo_revolver', 'ammo_revolver_express', 'ammo_revolver_highvelocity', 'ammo_revolver_split', 'ammo_revolver_explosive' }
local PIS = { 'ammo_pistol', 'ammo_pistol_express', 'ammo_pistol_highvelocity', 'ammo_pistol_split', 'ammo_pistol_explosive' }
local REP = { 'ammo_repeater', 'ammo_repeater_express', 'ammo_repeater_highvelocity', 'ammo_repeater_split', 'ammo_repeater_explosive' }
local RIF = { 'ammo_rifle', 'ammo_rifle_express', 'ammo_rifle_highvelocity', 'ammo_rifle_split', 'ammo_rifle_explosive' }
local SHG = { 'ammo_shotgun', 'ammo_shotgun_slug', 'ammo_shotgun_incendiary', 'ammo_shotgun_explosive' }
local ARR = { 'ammo_arrow', 'ammo_arrow_improved', 'ammo_arrow_smallgame', 'ammo_arrow_poison', 'ammo_arrow_fire', 'ammo_arrow_dynamite' }
local HANDGUN_PARTS = { 'barrel_long', 'barrel_short', 'sight_improved', 'grip_wood', 'grip_ivory', 'grip_pearl', 'rifling_improved', 'finish_blued', 'finish_nickel', 'finish_silver', 'finish_gold', 'engraving_simple', 'engraving_floral', 'engraving_scroll' }
local LONGARM_PARTS = { 'sight_improved', 'scope_short', 'scope_medium', 'stock_improved', 'rifling_improved', 'finish_blued', 'finish_nickel', 'engraving_simple', 'engraving_floral', 'wrap_leather' }

-- ═══ Revolvers ═══
W('weapon_revolver_cattleman',         'Cattleman Revolver',         'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1873, maker = 'Colt',            stats = { damage = 4, range = 4, rate = 5, accuracy = 5, reload = 5 }, components = HANDGUN_PARTS })
W('weapon_revolver_cattleman_mexican', 'Mexican Cattleman Revolver', 'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1873, maker = 'Colt',            stats = { damage = 4, range = 4, rate = 5, accuracy = 5, reload = 5 }, components = HANDGUN_PARTS })
W('weapon_revolver_schofield',         'Schofield Revolver',         'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1875, maker = 'Smith & Wesson',  stats = { damage = 5, range = 4, rate = 4, accuracy = 6, reload = 7 }, components = HANDGUN_PARTS })
W('weapon_revolver_doubleaction',      'Double-Action Revolver',     'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1877, maker = 'Colt',            stats = { damage = 3, range = 4, rate = 7, accuracy = 4, reload = 5 }, components = HANDGUN_PARTS })
W('weapon_revolver_doubleaction_exotic','Exotic Double-Action',      'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1877, maker = 'Colt',            stats = { damage = 3, range = 4, rate = 7, accuracy = 5, reload = 5 }, components = HANDGUN_PARTS })
W('weapon_revolver_lemat',             'LeMat Revolver',             'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 9, dual = false, era = 1861, maker = 'LeMat',          stats = { damage = 4, range = 3, rate = 5, accuracy = 4, reload = 3 }, components = HANDGUN_PARTS })
W('weapon_revolver_navy',              'Navy Revolver',              'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1851, maker = 'Colt',            stats = { damage = 5, range = 5, rate = 4, accuracy = 6, reload = 4 }, components = HANDGUN_PARTS })
W('weapon_revolver_navy_crossover',    'Navy Revolver (Engraved)',   'revolver', { ammo = 'ammo_revolver', ammoTypes = REV, clip = 6, dual = true, era = 1851, maker = 'Colt',            stats = { damage = 5, range = 5, rate = 4, accuracy = 6, reload = 4 }, components = HANDGUN_PARTS })
-- ═══ Pistols ═══
W('weapon_pistol_volcanic',            'Volcanic Pistol',            'pistol',   { ammo = 'ammo_pistol', ammoTypes = PIS, clip = 8,  dual = true, era = 1855, maker = 'Volcanic Arms',   stats = { damage = 6, range = 4, rate = 3, accuracy = 5, reload = 3 }, components = HANDGUN_PARTS })
W('weapon_pistol_mauser',              'Mauser Pistol',              'pistol',   { ammo = 'ammo_pistol', ammoTypes = PIS, clip = 10, dual = true, era = 1896, maker = 'Mauser',          stats = { damage = 3, range = 5, rate = 9, accuracy = 4, reload = 6 }, components = HANDGUN_PARTS })
W('weapon_pistol_semiauto',            'Semi-Automatic Pistol',      'pistol',   { ammo = 'ammo_pistol', ammoTypes = PIS, clip = 8,  dual = true, era = 1894, maker = 'Borchardt',       stats = { damage = 3, range = 5, rate = 8, accuracy = 5, reload = 7 }, components = HANDGUN_PARTS })
W('weapon_pistol_m1899',               'M1899 Pistol',               'pistol',   { ammo = 'ammo_pistol', ammoTypes = PIS, clip = 8,  dual = true, era = 1899, maker = 'Unknown',         stats = { damage = 4, range = 5, rate = 8, accuracy = 5, reload = 7 }, components = HANDGUN_PARTS })
-- ═══ Repeaters ═══
W('weapon_repeater_carbine',           'Carbine Repeater',           'repeater', { ammo = 'ammo_repeater', ammoTypes = REP, clip = 7,  era = 1860, maker = 'Spencer',         stats = { damage = 5, range = 5, rate = 5, accuracy = 5, reload = 4 }, components = LONGARM_PARTS })
W('weapon_repeater_winchester',        'Lancaster Repeater',         'repeater', { ammo = 'ammo_repeater', ammoTypes = REP, clip = 14, era = 1866, maker = 'Winchester',      stats = { damage = 5, range = 6, rate = 6, accuracy = 6, reload = 5 }, components = LONGARM_PARTS })
W('weapon_repeater_henry',             'Litchfield Repeater',        'repeater', { ammo = 'ammo_repeater', ammoTypes = REP, clip = 16, era = 1860, maker = 'Henry',           stats = { damage = 6, range = 6, rate = 7, accuracy = 6, reload = 4 }, components = LONGARM_PARTS })
W('weapon_repeater_evans',             'Evans Repeater',             'repeater', { ammo = 'ammo_repeater', ammoTypes = REP, clip = 26, era = 1873, maker = 'Evans',           stats = { damage = 5, range = 6, rate = 7, accuracy = 5, reload = 3 }, components = LONGARM_PARTS })
-- ═══ Rifles ═══
W('weapon_rifle_springfield',          'Springfield Rifle',          'rifle',    { ammo = 'ammo_rifle', ammoTypes = RIF, clip = 1,  era = 1873, maker = 'Springfield Armory', stats = { damage = 8, range = 8, rate = 2, accuracy = 8, reload = 4 }, components = LONGARM_PARTS })
W('weapon_rifle_boltaction',           'Bolt Action Rifle',          'rifle',    { ammo = 'ammo_rifle', ammoTypes = RIF, clip = 5,  era = 1892, maker = 'Krag–Jørgensen',   stats = { damage = 7, range = 8, rate = 4, accuracy = 8, reload = 5 }, components = LONGARM_PARTS })
W('weapon_rifle_varmint',              'Varmint Rifle',              'rifle',    { ammo = 'ammo_rifle_varmint', clip = 14, era = 1890, maker = 'Winchester',      stats = { damage = 1, range = 6, rate = 7, accuracy = 8, reload = 6 }, components = LONGARM_PARTS })
W('weapon_rifle_elephant',             'Elephant Rifle',             'rifle',    { ammo = 'ammo_rifle_elephant', clip = 2, era = 1899, maker = 'Holland & Holland', stats = { damage = 10, range = 7, rate = 2, accuracy = 6, reload = 3 }, components = LONGARM_PARTS })
W('weapon_rifle_rollingblock',         'Rolling Block Rifle',        'sniper',   { ammo = 'ammo_rifle', ammoTypes = RIF, clip = 1,  era = 1867, maker = 'Remington',       stats = { damage = 9, range = 10, rate = 1, accuracy = 9, reload = 3 }, components = { 'scope_short', 'scope_medium', 'scope_long', 'stock_improved', 'rifling_improved', 'finish_blued', 'engraving_simple', 'wrap_leather' } })
W('weapon_rifle_carcano',              'Carcano Rifle',              'sniper',   { ammo = 'ammo_rifle', ammoTypes = RIF, clip = 6,  era = 1891, maker = 'Carcano',         stats = { damage = 8, range = 10, rate = 3, accuracy = 9, reload = 5 }, components = { 'scope_short', 'scope_medium', 'scope_long', 'stock_improved', 'rifling_improved', 'finish_blued', 'engraving_simple', 'wrap_leather' } })
-- ═══ Shotguns ═══
W('weapon_shotgun_doublebarrel',       'Double-Barrelled Shotgun',   'shotgun',  { ammo = 'ammo_shotgun', ammoTypes = SHG, clip = 2, era = 1875, maker = 'Various',         stats = { damage = 9, range = 2, rate = 4, accuracy = 3, reload = 6 }, components = LONGARM_PARTS })
W('weapon_shotgun_doublebarrel_exotic','Exotic Double-Barrel',       'shotgun',  { ammo = 'ammo_shotgun', ammoTypes = SHG, clip = 2, era = 1875, maker = 'Various',         stats = { damage = 9, range = 2, rate = 4, accuracy = 4, reload = 6 }, components = LONGARM_PARTS })
W('weapon_shotgun_sawedoff',           'Sawed-Off Shotgun',          'shotgun',  { ammo = 'ammo_shotgun', ammoTypes = SHG, clip = 2, dual = true, era = 1875, maker = 'Various', stats = { damage = 8, range = 1, rate = 4, accuracy = 2, reload = 6 }, components = { 'grip_wood', 'finish_blued', 'engraving_simple' } })
W('weapon_shotgun_pump',               'Pump-Action Shotgun',        'shotgun',  { ammo = 'ammo_shotgun', ammoTypes = SHG, clip = 5, era = 1897, maker = 'Winchester',      stats = { damage = 8, range = 3, rate = 5, accuracy = 3, reload = 4 }, components = LONGARM_PARTS })
W('weapon_shotgun_repeating',          'Repeating Shotgun',          'shotgun',  { ammo = 'ammo_shotgun', ammoTypes = SHG, clip = 6, era = 1887, maker = 'Winchester',      stats = { damage = 8, range = 3, rate = 5, accuracy = 3, reload = 4 }, components = LONGARM_PARTS })
W('weapon_shotgun_semiauto',           'Semi-Auto Shotgun',          'shotgun',  { ammo = 'ammo_shotgun', ammoTypes = SHG, clip = 5, era = 1902, maker = 'Browning',        stats = { damage = 7, range = 3, rate = 8, accuracy = 3, reload = 4 }, components = LONGARM_PARTS })
-- ═══ Bows ═══
W('weapon_bow',                        'Hunting Bow',                'bow',      { ammo = 'ammo_arrow', ammoTypes = ARR, clip = 1, era = 1800, stats = { damage = 6, range = 5, rate = 3, accuracy = 6, reload = 8 }, degrade = 0.02 })
W('weapon_bow_improved',               'Improved Bow',               'bow',      { ammo = 'ammo_arrow', ammoTypes = ARR, clip = 1, era = 1800, stats = { damage = 8, range = 6, rate = 3, accuracy = 7, reload = 8 }, degrade = 0.02 })
-- ═══ Melee ═══
local function melee(model, label, dmg, era) W(model, label, 'melee', { stats = { damage = dmg, range = 1, rate = 5, accuracy = 10, reload = 10 }, era = era or 1899, degrade = 0.01 }) end
melee('weapon_melee_knife',            'Hunting Knife',       3)
melee('weapon_melee_knife_bear',       'Bear Knife',          4)
melee('weapon_melee_knife_civil_war',  'Civil War Knife',     4, 1862)
melee('weapon_melee_knife_jawbone',    'Jawbone Knife',       4)
melee('weapon_melee_knife_miner',      "Miner's Knife",       3)
melee('weapon_melee_knife_trader',     "Trader's Knife",      3)
melee('weapon_melee_knife_rustic',     'Rustic Knife',        3)
melee('weapon_melee_knife_vampire',    'Ornate Dagger',       4)
melee('weapon_melee_cleaver',          'Cleaver',             4)
melee('weapon_melee_machete',          'Machete',             5)
melee('weapon_melee_hatchet',          'Hatchet',             5)
melee('weapon_melee_hatchet_hunter',   'Hunter Hatchet',      5)
melee('weapon_melee_hatchet_hewing',   'Hewing Hatchet',      5)
melee('weapon_melee_hatchet_double_bit','Double Bit Hatchet', 6)
melee('weapon_melee_hatchet_viking',   'Viking Hatchet',      6)
melee('weapon_melee_ancient_hatchet',  'Ancient Hatchet',     6)
melee('weapon_melee_broken_sword',     'Broken Sword',        5, 1863)
melee('weapon_melee_torch',            'Torch (Weapon)',      2)
melee('weapon_melee_lantern',          'Lantern (Held)',      1)
-- ═══ Thrown ═══
local function thrown(model, label, dmg) W(model, label, 'thrown', { stats = { damage = dmg, range = 3, rate = 3, accuracy = 5, reload = 6 }, degrade = 0 }) end
thrown('weapon_thrown_throwing_knives', 'Throwing Knives',     4)
thrown('weapon_thrown_tomahawk',        'Tomahawk',            5)
thrown('weapon_thrown_tomahawk_ancient','Ancient Tomahawk',    6)
thrown('weapon_thrown_dynamite',        'Dynamite',            9)
thrown('weapon_thrown_dynamite_volatile','Volatile Dynamite',  10)
thrown('weapon_thrown_molotov',         'Fire Bottle',         6)
thrown('weapon_thrown_molotov_volatile','Volatile Fire Bottle',7)
thrown('weapon_thrown_poisonbottle',    'Poison Bottle',       5)
thrown('weapon_thrown_bolas',           'Bolas',               1)
thrown('weapon_thrown_bolas_hawkmoth',  'Hawkmoth Bolas',      2)
thrown('weapon_thrown_bolas_ironspiked','Iron Spiked Bolas',   2)
thrown('weapon_thrown_bolas_intertwined','Intertwined Bolas',  2)

LXRShared.Weapons = Weapons
LXRShared.WeaponsByName = ByName

---Resolve a weapon record from a hash, model or item name.
function LXRShared.GetWeapon(ref)
    if type(ref) == 'number' then return Weapons[ref] end
    if type(ref) == 'string' then return ByName[ref:lower()] or Weapons[joaat(ref:upper())] end
    return nil
end

---Every weapon in a category (sorted by label).
function LXRShared.WeaponsInCategory(category)
    local out = {}
    for _, w in pairs(ByName) do if w.category == category then out[#out + 1] = w end end
    table.sort(out, function(a, b) return a.label < b.label end)
    return out
end

---True when `ammoItem` can be chambered by `weaponName`.
function LXRShared.WeaponAcceptsAmmo(weaponName, ammoItem)
    local w = ByName[weaponName]
    if not w then return false end
    for _, a in ipairs(w.ammoTypes or {}) do if a == ammoItem then return true end end
    return false
end
