--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Catalog Engine
     ═══════════════════════════════════════════════════════════════════════════
     The catalog is LXRCore's own data model for everything a character can
     own, ride, drive, shoot or be employed by. Every shared/*.lua data file is
     built through the definers below, so each record carries the same fields,
     the same defaults and can be validated offline (tests/test_shared.lua) and
     at boot (Config.Catalog.validateOnBoot).

     Design rules:
       • one record per thing, quality/grade live in item *info*, never as
         three copies of the same item (pelt_deer_poor/good/perfect);
       • category profiles supply sane defaults (a 'food' item already knows
         its animation, use-time and effect keys) — an owner adds a line, not
         a paragraph;
       • every cross-reference (ammo → item, kit → item, weapon → ammo,
         job → society account) is checked, so a typo is a test failure and a
         boot warning, not a silent nil three resources away;
       • 1899–1907 flavour is data: `era` (year an item/weapon existed),
         `value` in period dollars and `legal` flags drive shops, fences,
         lawmen and the economy without touching code.

     Nothing here needs editing to add content — add records to the data
     files, or register at runtime through LXRCore.Functions.AddItem / AddJob.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}
local Catalog = {}
LXRShared.Catalog = Catalog

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🗺️ WORLD — towns, regions and states used by jobs, shops, horses and wagons
-- ═══════════════════════════════════════════════════════════════════════════════

LXRShared.States = {
    newhanover  = { label = 'New Hanover',  capital = 'Valentine' },
    lemoyne     = { label = 'Lemoyne',      capital = 'Saint Denis' },
    westelizabeth = { label = 'West Elizabeth', capital = 'Blackwater' },
    ambarino    = { label = 'Ambarino',     capital = 'Colter' },
    newaustin   = { label = 'New Austin',   capital = 'Armadillo' },
}

LXRShared.Towns = {
    valentine   = { label = 'Valentine',    state = 'newhanover',    size = 'town',    lawJob = 'vallaw', doctorJob = 'valdoc', bank = 'valbank', train = true },
    annesburg   = { label = 'Annesburg',    state = 'newhanover',    size = 'town',    lawJob = 'annlaw', doctorJob = 'valdoc', bank = nil,       train = true },
    vanhorn     = { label = 'Van Horn Trading Post', state = 'newhanover', size = 'outpost', lawJob = nil, doctorJob = nil, bank = nil, train = false },
    emeraldranch = { label = 'Emerald Ranch', state = 'newhanover',  size = 'hamlet',  lawJob = nil,      doctorJob = nil,      bank = nil,       train = true },
    rhodes      = { label = 'Rhodes',       state = 'lemoyne',       size = 'town',    lawJob = 'rholaw', doctorJob = 'rhodoc', bank = 'rhobank', train = true },
    saintdenis  = { label = 'Saint Denis',  state = 'lemoyne',       size = 'city',    lawJob = 'sdlaw',  doctorJob = 'sddoc',  bank = 'sdbank',  train = true },
    lagras      = { label = 'Lagras',       state = 'lemoyne',       size = 'hamlet',  lawJob = nil,      doctorJob = nil,      bank = nil,       train = false },
    strawberry  = { label = 'Strawberry',   state = 'westelizabeth', size = 'town',    lawJob = 'strlaw', doctorJob = 'strdoc', bank = nil,       train = false },
    blackwater  = { label = 'Blackwater',   state = 'westelizabeth', size = 'town',    lawJob = 'blklaw', doctorJob = 'blkdoc', bank = 'blkbank', train = false },
    colter      = { label = 'Colter',       state = 'ambarino',      size = 'ruin',    lawJob = nil,      doctorJob = nil,      bank = nil,       train = false },
    armadillo   = { label = 'Armadillo',    state = 'newaustin',     size = 'town',    lawJob = 'armlaw', doctorJob = 'armdoc', bank = 'armbank', train = true },
    tumbleweed  = { label = 'Tumbleweed',   state = 'newaustin',     size = 'town',    lawJob = 'tumlaw', doctorJob = 'armdoc', bank = nil,       train = false },
    macfarlane  = { label = "MacFarlane's Ranch", state = 'newaustin', size = 'hamlet', lawJob = nil,    doctorJob = nil,      bank = nil,       train = false },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🏷️ RARITY — drives shop stock chance, fence prices, loot tables and UI colour
-- ═══════════════════════════════════════════════════════════════════════════════

LXRShared.Rarities = {
    common    = { label = 'Common',    tier = 1, color = '#b9b3a6', priceMult = 1.00, lootWeight = 100 },
    uncommon  = { label = 'Uncommon',  tier = 2, color = '#8fb37a', priceMult = 1.25, lootWeight = 45 },
    rare      = { label = 'Rare',      tier = 3, color = '#6f9dc9', priceMult = 1.75, lootWeight = 15 },
    exquisite = { label = 'Exquisite', tier = 4, color = '#b487d6', priceMult = 2.50, lootWeight = 4 },
    legendary = { label = 'Legendary', tier = 5, color = '#c21c37', priceMult = 4.00, lootWeight = 1 },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎬 ANIMATIONS & PROPS — named so items reference `anim = 'eat'`, not dicts
-- ═══════════════════════════════════════════════════════════════════════════════

LXRShared.Animations = {
    eat        = { dict = 'mech_inventory@eating@multi_bite@sphere_d8-2_sandwich', name = 'quick_right_hand', flag = 31, duration = 3000 },
    drink      = { dict = 'mech_inventory@drinking@multi_sip@sphere_d8-2_sandwich', name = 'quick_right_hand', flag = 31, duration = 3000 },
    drink_bottle = { dict = 'amb_rest_drunk@world_human_drinking@male_a@idle_a', name = 'idle_a', flag = 31, duration = 3500 },
    canteen    = { dict = 'amb_rest_drunk@world_human_drinking@female_a@idle_a', name = 'idle_a', flag = 31, duration = 3000 },   -- the canteen in the right hand (lxr-hud attaches the prop)
    eat_canned = { dict = 'mech_inventory@eating@canned_food@cylinder@d8-2_h10-5', name = 'left_hand', flag = 31, duration = 3500 },
    smoke      = { dict = 'amb_rest@world_human_smoke_cigar@male_a@idle_a', name = 'idle_a', flag = 31, duration = 6000 },
    heal       = { dict = 'mech_inventory@item@fallbacks@medical', name = 'base', flag = 31, duration = 4000 },
    inject     = { dict = 'mech_inventory@item@fallbacks@medical', name = 'base', flag = 31, duration = 5000 },
    read       = { dict = 'mech_inventory@item@fallbacks@paper', name = 'base', flag = 31, duration = 2500 },
    craft      = { dict = 'mech_inventory@crafting@fallbacks', name = 'full_craft_and_stow', flag = 31, duration = 5000 },
    inspect    = { dict = 'mech_inventory@item@fallbacks@generic', name = 'base', flag = 31, duration = 2000 },
    pickup     = { dict = 'mech_pickup@ground@grip', name = 'pickup_rh', flag = 31, duration = 1500 },
    feed_horse = { dict = 'mech_inventory@horse@right@feed', name = 'base', flag = 31, duration = 4000 },
    brush_horse = { dict = 'amb_work@world_human_horse_brush@male_a@idle_a', name = 'idle_a', flag = 31, duration = 8000 },
    tool       = { dict = 'amb_work@world_human_crouch_inspect@male_a@idle_a', name = 'idle_a', flag = 31, duration = 3000 },
}

LXRShared.Props = {
    bottle_beer   = { model = 'p_bottlebeer01x', bone = 'SKEL_R_Finger12', pos = vector3(0.05, 0.0, -0.06), rot = vector3(0.0, -100.0, 0.0) },
    bottle_whiskey = { model = 'p_bottlewhiskey01x', bone = 'SKEL_R_Finger12', pos = vector3(0.05, 0.0, -0.06), rot = vector3(0.0, -100.0, 0.0) },
    bottle_jar    = { model = 'p_bottlejar01x', bone = 'SKEL_R_Finger12', pos = vector3(0.05, 0.0, -0.06), rot = vector3(0.0, -100.0, 0.0) },
    canteen       = { model = 'p_canteen01x', bone = 'SKEL_R_Finger12', pos = vector3(0.05, 0.0, -0.06), rot = vector3(0.0, -100.0, 0.0) },
    mug           = { model = 'p_mugcoffee01x', bone = 'SKEL_R_Finger12', pos = vector3(0.03, 0.0, -0.05), rot = vector3(0.0, -90.0, 0.0) },
    cup_tea       = { model = 'p_cup02x', bone = 'SKEL_R_Finger12', pos = vector3(0.03, 0.0, -0.05), rot = vector3(0.0, -90.0, 0.0) },
    bread         = { model = 'p_bread05x', bone = 'SKEL_R_Finger12', pos = vector3(0.01, 0.0, -0.02), rot = vector3(0.0, 0.0, 0.0) },
    apple         = { model = 's_inv_apple01x', bone = 'SKEL_R_Finger12', pos = vector3(0.01, 0.0, -0.02), rot = vector3(0.0, 0.0, 0.0) },
    meat_cooked   = { model = 'p_cookedmeat01x', bone = 'SKEL_R_Finger12', pos = vector3(0.01, 0.0, -0.02), rot = vector3(0.0, 0.0, 0.0) },
    can           = { model = 'p_cantobacco01x', bone = 'SKEL_R_Finger12', pos = vector3(0.03, 0.0, -0.04), rot = vector3(0.0, -90.0, 0.0) },
    cigar         = { model = 'p_cigar01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    cigarette     = { model = 'p_cigarette_cs01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    pipe          = { model = 'p_pipe01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    bandage       = { model = 'p_bandage01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    syringe       = { model = 'p_syringe01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    tonic         = { model = 'p_bottlejd01x', bone = 'SKEL_R_Finger12', pos = vector3(0.05, 0.0, -0.06), rot = vector3(0.0, -100.0, 0.0) },
    paper         = { model = 'p_letter01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    book          = { model = 'p_book01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    hay           = { model = 'p_hay01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
    brush         = { model = 'p_brush01x', bone = 'SKEL_R_Finger12', pos = vector3(0.02, 0.0, 0.0), rot = vector3(0.0, 0.0, 0.0) },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 ITEM CATEGORIES — profiles with defaults; the item definer merges them
-- ═══════════════════════════════════════════════════════════════════════════════
-- Fields every item ends up with (see Catalog.Item):
--   name label weight type image unique useable shouldClose description
--   category rarity stack value sellable tradable droppable legal era tags
--   effects = { hunger thirst health stamina stress cleanliness drunk warmth
--               core_health core_stamina gold_core_health gold_core_stamina }
--   use     = { time anim prop sound consume whileDead whileCuffed cooldown
--               xp = { skill, amount } }
--   decay   = { hours, into }   -- perishables; `into` is the item it becomes
--   quality = true              -- graded goods keep info.quality (1..3) / durability
--   requires = { tool, job, skill = { name, level }, license }

LXRShared.ItemCategories = {
    currency  = { label = 'Currency',     icon = '💵', order = 1,  defaults = { useable = false, weight = 0, stack = 100000, droppable = false, tradable = true, rarity = 'common' } },
    food      = { label = 'Food',         icon = '🍞', order = 2,  defaults = { stack = 10, use = { time = 3000, anim = 'eat', consume = true }, decay = { hours = 72, into = 'spoiled_food' } } },
    meat      = { label = 'Meat & Fish',  icon = '🥩', order = 3,  defaults = { stack = 10, useable = false, quality = true, decay = { hours = 24, into = 'spoiled_meat' } } },
    drink     = { label = 'Drink',        icon = '🥃', order = 4,  defaults = { stack = 10, use = { time = 3000, anim = 'drink', consume = true } } },
    alcohol   = { label = 'Spirits',      icon = '🍺', order = 5,  defaults = { stack = 10, use = { time = 3500, anim = 'drink_bottle', consume = true, cooldown = 2000 } } },
    tobacco   = { label = 'Tobacco',      icon = '🚬', order = 6,  defaults = { stack = 20, use = { time = 6000, anim = 'smoke', consume = true } } },
    medical   = { label = 'Medical',      icon = '🩹', order = 7,  defaults = { stack = 10, use = { time = 4000, anim = 'heal', consume = true, whileDead = false } } },
    herb      = { label = 'Herbs & Plants', icon = '🌿', order = 8, defaults = { stack = 25, weight = 50, use = { time = 2500, anim = 'eat', consume = true }, decay = { hours = 168, into = 'dried_herbs' } } },
    hunting   = { label = 'Hunting',      icon = '🦌', order = 9,  defaults = { stack = 5, useable = false, quality = true } },
    material  = { label = 'Materials',    icon = '⛏️', order = 10, defaults = { stack = 50, useable = false } },
    component = { label = 'Components',   icon = '⚙️', order = 11, defaults = { stack = 50, useable = false } },
    tool      = { label = 'Tools',        icon = '🔧', order = 12, defaults = { stack = 1, unique = true, quality = true, use = { time = 1500, anim = 'inspect', consume = false } } },
    kit       = { label = 'Kits',         icon = '🎒', order = 13, defaults = { stack = 1, unique = true, use = { time = 2500, anim = 'craft', consume = false } } },
    camp      = { label = 'Camp',         icon = '⛺', order = 14, defaults = { stack = 1, unique = true, use = { time = 2500, anim = 'craft', consume = false } } },
    horse     = { label = 'Horse Care',   icon = '🐴', order = 15, defaults = { stack = 10, use = { time = 4000, anim = 'feed_horse', consume = true } } },
    tack      = { label = 'Tack & Saddles', icon = '🐎', order = 16, defaults = { stack = 1, unique = true, useable = true, quality = true } },
    wagon     = { label = 'Wagon Parts',  icon = '🛞', order = 17, defaults = { stack = 5, useable = true } },
    document  = { label = 'Documents',    icon = '📜', order = 18, defaults = { stack = 1, unique = true, weight = 20, use = { time = 2500, anim = 'read', consume = false, whileCuffed = true } } },
    key       = { label = 'Keys',         icon = '🔑', order = 19, defaults = { stack = 1, unique = true, weight = 20, useable = true } },
    personal  = { label = 'Personal',     icon = '🎩', order = 20, defaults = { stack = 1, unique = true, use = { time = 2000, anim = 'inspect', consume = false } } },
    valuable  = { label = 'Valuables',    icon = '💍', order = 21, defaults = { stack = 5, useable = false, legal = false } },
    collectible = { label = 'Collectibles', icon = '🦴', order = 22, defaults = { stack = 10, useable = false } },
    contraband = { label = 'Contraband',  icon = '🔒', order = 23, defaults = { stack = 10, legal = false } },
    fishing   = { label = 'Fishing',      icon = '🎣', order = 24, defaults = { stack = 20, useable = true } },
    ammo      = { label = 'Ammunition',   icon = '🔫', order = 25, defaults = { stack = 200, weight = 10, useable = true, use = { time = 0, consume = false } } },
    weapon    = { label = 'Weapons',      icon = '🪓', order = 26, defaults = { type = 'weapon', unique = true, stack = 1, quality = true, shouldClose = true } },
    thrown    = { label = 'Throwables',   icon = '🧨', order = 27, defaults = { type = 'weapon', stack = 10, unique = false, shouldClose = true } },
    clothing  = { label = 'Clothing',     icon = '👒', order = 28, defaults = { stack = 1, unique = true, quality = true } },
    misc      = { label = 'Miscellaneous', icon = '📦', order = 99, defaults = { stack = 10 } },
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧱 DEFINERS
-- ═══════════════════════════════════════════════════════════════════════════════

local function merge(dst, src)
    for k, v in pairs(src) do
        if type(v) == 'table' and type(dst[k]) == 'table' then merge(dst[k], v)
        elseif dst[k] == nil then dst[k] = (type(v) == 'table') and merge({}, v) or v end
    end
    return dst
end
Catalog.Merge = merge

---Define an item. `opts` overrides category defaults, which override global defaults.
---@param name string lowercase key (must equal the table key)
---@param label string
---@param weight number grams
---@param opts table|nil
function Catalog.Item(name, label, weight, opts)
    opts = opts or {}
    local category = opts.category or 'misc'
    local profile = LXRShared.ItemCategories[category] or LXRShared.ItemCategories.misc
    local rec = {
        name = name, label = label, category = category,
        weight = weight,
        description = opts.description,
        tags = opts.tags,
    }
    for k, v in pairs(opts) do if rec[k] == nil then rec[k] = v end end
    merge(rec, profile.defaults or {})
    merge(rec, {
        type = 'item', image = name .. '.png', unique = false, useable = true, shouldClose = true,
        description = '', rarity = 'common', stack = 10, value = 0, sellable = true, tradable = true,
        droppable = true, legal = true, era = 1899, tags = {}, effects = {}, use = {},
    })
    if rec.weight == nil then rec.weight = 100 end
    if rec.unique then rec.stack = 1 end
    if rec.decay == false then rec.decay = nil end   -- `decay = false` opts out of a category default
    if opts.useable == false then rec.useable = false end
    return rec
end

---Consumable shorthand: effects given inline.
function Catalog.Food(name, label, weight, effects, opts)
    opts = opts or {}; opts.category = opts.category or 'food'; opts.effects = effects
    return Catalog.Item(name, label, weight, opts)
end
function Catalog.Drink(name, label, weight, effects, opts)
    opts = opts or {}; opts.category = opts.category or 'drink'; opts.effects = effects
    return Catalog.Item(name, label, weight, opts)
end
function Catalog.Medical(name, label, weight, effects, opts)
    opts = opts or {}; opts.category = 'medical'; opts.effects = effects
    return Catalog.Item(name, label, weight, opts)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 LOOKUPS
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRShared.ItemsByCategory(category)
    local out = {}
    for name, def in pairs(LXRShared.Items or {}) do if def.category == category then out[name] = def end end
    return out
end

function LXRShared.ItemsWithTag(tag)
    local out = {}
    for name, def in pairs(LXRShared.Items or {}) do
        for _, t in ipairs(def.tags or {}) do if t == tag then out[name] = def break end end
    end
    return out
end

function LXRShared.ItemValue(name, quality)
    local def = LXRShared.Items and LXRShared.Items[name]
    if not def then return 0 end
    local mult = (LXRShared.Rarities[def.rarity] or LXRShared.Rarities.common).priceMult
    local q = tonumber(quality) or 3
    return LXRShared.Round((def.value or 0) * mult * ({ [1] = 0.4, [2] = 0.7, [3] = 1.0 })[math.max(1, math.min(3, q))], 2)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ✅ VALIDATION — returns a list of human-readable problems (empty = healthy)
-- ═══════════════════════════════════════════════════════════════════════════════

function Catalog.Validate()
    local problems = {}
    local function bad(fmt, ...) problems[#problems + 1] = fmt:format(...) end
    local S = LXRShared

    for key, def in pairs(S.Items or {}) do
        if type(def) ~= 'table' then bad('item %s is not a table', key)
        else
            if def.name ~= key then bad('item key %s != name %s', key, tostring(def.name)) end
            if key ~= key:lower() then bad('item key %s is not lowercase', key) end
            if type(def.label) ~= 'string' or def.label == '' then bad('item %s has no label', key) end
            if type(def.weight) ~= 'number' or def.weight < 0 then bad('item %s weight invalid', key) end
            if not S.ItemCategories[def.category or ''] then bad('item %s unknown category %s', key, tostring(def.category)) end
            if not S.Rarities[def.rarity or ''] then bad('item %s unknown rarity %s', key, tostring(def.rarity)) end
            if def.decay and def.decay.into and not S.Items[def.decay.into] then bad('item %s decays into missing item %s', key, def.decay.into) end
            if def.use and def.use.anim and not S.Animations[def.use.anim] then bad('item %s unknown anim %s', key, def.use.anim) end
            if def.use and def.use.prop and not S.Props[def.use.prop] then bad('item %s unknown prop %s', key, def.use.prop) end
            if def.requires and def.requires.tool and not S.Items[def.requires.tool] then bad('item %s requires missing tool %s', key, def.requires.tool) end
            if def.type == 'weapon' and def.category == 'weapon' and not (S.WeaponsByName and S.WeaponsByName[key]) then bad('weapon item %s has no weapon record', key) end
        end
    end

    for hash, w in pairs(S.Weapons or {}) do
        if not S.Items[w.name] then bad('weapon %s has no item record', w.name) end
        if w.ammo and not S.Items[w.ammo] then bad('weapon %s default ammo %s missing', w.name, w.ammo) end
        for _, a in ipairs(w.ammoTypes or {}) do if not S.Items[a] then bad('weapon %s ammo type %s missing', w.name, a) end end
        if not S.WeaponCategories[w.category or ''] then bad('weapon %s unknown category %s', w.name, tostring(w.category)) end
    end

    for name, a in pairs(S.Ammo or {}) do
        if not S.Items[name] then bad('ammo %s has no item record', name) end
        if not a.hash then bad('ammo %s has no hash', name) end
    end

    for name, j in pairs(S.Jobs or {}) do
        if j.name ~= name then bad('job key %s != name %s', name, tostring(j.name)) end
        if not j.grades or not j.grades['0'] then bad('job %s has no grade 0', name) end
        for g, grade in pairs(j.grades or {}) do
            if type(g) ~= 'string' or not g:match('^%d+$') then bad('job %s grade key %s must be a numeric string', name, tostring(g)) end
            if type(grade.payment) ~= 'number' then bad('job %s grade %s payment missing', name, tostring(g)) end
        end
        if j.town and not S.Towns[j.town] then bad('job %s unknown town %s', name, j.town) end
        if j.type and not S.JobTypes[j.type] then bad('job %s unknown type %s', name, j.type) end
    end

    for name, g in pairs(S.Gangs or {}) do
        if g.name ~= name then bad('gang key %s != name %s', name, tostring(g.name)) end
        if not g.grades or not g.grades['0'] then bad('gang %s has no grade 0', name) end
        for _, r in ipairs(g.rivals or {}) do if not S.Gangs[r] then bad('gang %s rival %s missing', name, r) end end
        for _, r in ipairs(g.allies or {}) do if not S.Gangs[r] then bad('gang %s ally %s missing', name, r) end end
    end

    for model, h in pairs(S.Horses or {}) do
        if h.model ~= model then bad('horse key %s != model %s', model, tostring(h.model)) end
        if not S.HorseBreeds[h.breed or ''] then bad('horse %s unknown breed %s', model, tostring(h.breed)) end
        if type(h.price) ~= 'number' then bad('horse %s price missing', model) end
    end

    for model, v in pairs(S.Vehicles or {}) do
        if v.model ~= model then bad('vehicle key %s != model %s', model, tostring(v.model)) end
        if not S.VehicleCategories[v.category or ''] then bad('vehicle %s unknown category %s', model, tostring(v.category)) end
    end

    if S.UnpricedItems then
        for _, name in ipairs(S.UnpricedItems()) do bad('item %s has no entry in shared/prices.lua', name) end
    end

    for kitName, kit in pairs(S.StarterKits or {}) do
        for _, e in ipairs(kit.items or {}) do if not S.Items[e.item] then bad('starter kit %s item %s missing', kitName, e.item) end end
    end
    for _, e in ipairs(S.StarterItems or {}) do if not S.Items[e.item] then bad('starter item %s missing', e.item) end end

    table.sort(problems)
    return problems
end

-- config.lua has loaded by now: let the configured temper win over the convar default
if Config and Config.UI and Config.UI.theme and LXRCore.Brand and GetConvar('lxr_theme', '') == '' then LXRCore.Brand.theme = Config.UI.theme end
