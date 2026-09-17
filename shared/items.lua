--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Items
     ═══════════════════════════════════════════════════════════════════════════
     Shape (RSG/QBR compatible, read by inventory resources):
       key = { name, label, weight (grams), type ('item'|'weapon'), image,
               unique, useable, shouldClose, description, category?, decay?,
               combinable? }
     Keys must equal `name` and be lowercase. Add items here or at runtime:
       LXRCore.Functions.AddItem(name, data) / AddItems({ ... })
     Starter items given on character creation live in LXRShared.StarterItems.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

local function item(name, label, weight, opts)
    opts = opts or {}
    return {
        name = name,
        label = label,
        weight = weight or 100,
        type = opts.type or 'item',
        image = opts.image or (name .. '.png'),
        unique = opts.unique == true,
        useable = opts.useable ~= false,
        shouldClose = opts.shouldClose ~= false,
        description = opts.description or '',
        category = opts.category,
        decay = opts.decay,
        combinable = opts.combinable,
    }
end

LXRShared.Items = {
    -- ═══ Money as items (only used when Config.Money.EnableMoneyItems) ═══
    dollar        = item('dollar', 'Dollar', 0, { useable = false, category = 'money', description = 'Cash dollar' }),
    cent          = item('cent', 'Cent', 0, { useable = false, category = 'money', description = 'Cash cent' }),
    blood_dollar  = item('blood_dollar', 'Blood Dollar', 0, { useable = false, category = 'money', description = 'Tainted money' }),
    blood_cent    = item('blood_cent', 'Blood Cent', 0, { useable = false, category = 'money', description = 'Tainted money' }),
    gold          = item('gold', 'Gold', 100, { useable = false, category = 'money', description = 'Gold nugget' }),

    -- ═══ Consumables ═══
    water         = item('water', 'Water', 200, { category = 'drink', description = 'Fresh water', decay = 0 }),
    coffee        = item('coffee', 'Coffee', 200, { category = 'drink', description = 'Hot coffee' }),
    beer          = item('beer', 'Beer', 300, { category = 'drink', description = 'Cold beer' }),
    whiskey       = item('whiskey', 'Whiskey', 300, { category = 'drink', description = 'Strong whiskey' }),
    bread         = item('bread', 'Bread', 200, { category = 'food', description = 'A loaf of bread' }),
    apple         = item('apple', 'Apple', 100, { category = 'food', description = 'A crisp apple' }),
    cooked_meat   = item('cooked_meat', 'Cooked Meat', 300, { category = 'food', description = 'Cooked game meat' }),
    raw_meat      = item('raw_meat', 'Raw Meat', 300, { category = 'food', description = 'Raw game meat', useable = false }),
    stew          = item('stew', 'Stew', 400, { category = 'food', description = 'Hearty stew' }),
    canned_beans  = item('canned_beans', 'Canned Beans', 300, { category = 'food', description = 'Canned beans' }),

    -- ═══ Medical ═══
    bandage       = item('bandage', 'Bandage', 100, { category = 'medical', description = 'Stops bleeding' }),
    health_cure   = item('health_cure', 'Health Cure', 200, { category = 'medical', description = 'Restores health' }),
    tonic         = item('tonic', 'Tonic', 200, { category = 'medical', description = 'Restores stamina' }),

    -- ═══ Tools ═══
    lantern       = item('lantern', 'Lantern', 500, { category = 'tool', description = 'Portable lantern' }),
    lockpick      = item('lockpick', 'Lockpick', 100, { category = 'tool', description = 'Opens locks, sometimes' }),
    pickaxe       = item('pickaxe', 'Pickaxe', 2000, { category = 'tool', description = 'Mining tool' }),
    axe           = item('axe', 'Axe', 2000, { category = 'tool', description = 'Wood cutting axe' }),
    fishingrod    = item('fishingrod', 'Fishing Rod', 800, { category = 'tool', description = 'Fishing rod' }),
    binoculars    = item('binoculars', 'Binoculars', 400, { category = 'tool', description = 'See far away' }),
    bedroll       = item('bedroll', 'Bedroll', 1500, { category = 'tool', description = 'Sleep anywhere' }),
    rope          = item('rope', 'Rope', 500, { category = 'tool', description = 'Sturdy rope' }),
    lasso         = item('lasso', 'Lasso', 600, { category = 'tool', description = 'Catch animals and outlaws' }),
    handcuffs     = item('handcuffs', 'Handcuffs', 400, { category = 'tool', description = 'Iron handcuffs' }),
    handcuffs_key = item('handcuffs_key', 'Handcuffs Key', 50, { category = 'tool', description = 'Opens handcuffs' }),
    campfire_kit  = item('campfire_kit', 'Campfire Kit', 1000, { category = 'tool', description = 'Build a campfire' }),

    -- ═══ Documents ═══
    id_card       = item('id_card', 'Identification', 50, { unique = true, category = 'document', description = 'Personal papers' }),
    wanted_poster = item('wanted_poster', 'Wanted Poster', 50, { unique = true, category = 'document', description = 'Bounty notice' }),
    telegram      = item('telegram', 'Telegram', 20, { unique = true, category = 'document', description = 'A telegram' }),

    -- ═══ Materials ═══
    wood          = item('wood', 'Wood', 500, { useable = false, category = 'material', description = 'Firewood' }),
    iron_ore      = item('iron_ore', 'Iron Ore', 800, { useable = false, category = 'material', description = 'Raw iron ore' }),
    iron_bar      = item('iron_bar', 'Iron Bar', 1000, { useable = false, category = 'material', description = 'Smelted iron' }),
    gold_ore      = item('gold_ore', 'Gold Ore', 800, { useable = false, category = 'material', description = 'Raw gold ore' }),
    coal          = item('coal', 'Coal', 500, { useable = false, category = 'material', description = 'Coal' }),
    leather       = item('leather', 'Leather', 400, { useable = false, category = 'material', description = 'Tanned leather' }),
    pelt_deer     = item('pelt_deer', 'Deer Pelt', 1500, { useable = false, category = 'pelt', description = 'Deer pelt' }),
    pelt_wolf     = item('pelt_wolf', 'Wolf Pelt', 1500, { useable = false, category = 'pelt', description = 'Wolf pelt' }),
    herb_yarrow   = item('herb_yarrow', 'Yarrow', 50, { useable = false, category = 'herb', description = 'Medicinal herb' }),
    herb_ginseng  = item('herb_ginseng', 'Ginseng', 50, { useable = false, category = 'herb', description = 'Restorative root' }),

    -- ═══ Ammunition ═══
    ammo_revolver = item('ammo_revolver', 'Revolver Ammo', 50, { category = 'ammo', description = 'Box of revolver rounds' }),
    ammo_pistol   = item('ammo_pistol', 'Pistol Ammo', 50, { category = 'ammo', description = 'Box of pistol rounds' }),
    ammo_rifle    = item('ammo_rifle', 'Rifle Ammo', 80, { category = 'ammo', description = 'Box of rifle rounds' }),
    ammo_repeater = item('ammo_repeater', 'Repeater Ammo', 80, { category = 'ammo', description = 'Box of repeater rounds' }),
    ammo_shotgun  = item('ammo_shotgun', 'Shotgun Shells', 100, { category = 'ammo', description = 'Box of shells' }),
    ammo_arrow    = item('ammo_arrow', 'Arrow', 200, { category = 'ammo', description = 'Arrows' }),

    -- ═══ Weapons (type 'weapon' — inventory resources create serial/quality in info) ═══
    weapon_revolver_cattleman = item('weapon_revolver_cattleman', 'Cattleman Revolver', 1000, { type = 'weapon', unique = true, category = 'weapon', description = 'Reliable sidearm' }),
    weapon_revolver_schofield = item('weapon_revolver_schofield', 'Schofield Revolver', 1000, { type = 'weapon', unique = true, category = 'weapon', description = 'Top-break revolver' }),
    weapon_pistol_volcanic    = item('weapon_pistol_volcanic', 'Volcanic Pistol', 1000, { type = 'weapon', unique = true, category = 'weapon', description = 'Lever-action pistol' }),
    weapon_repeater_carbine   = item('weapon_repeater_carbine', 'Carbine Repeater', 3000, { type = 'weapon', unique = true, category = 'weapon', description = 'Fast repeater' }),
    weapon_rifle_springfield  = item('weapon_rifle_springfield', 'Springfield Rifle', 3500, { type = 'weapon', unique = true, category = 'weapon', description = 'Single-shot rifle' }),
    weapon_shotgun_doublebarrel = item('weapon_shotgun_doublebarrel', 'Double-Barrel Shotgun', 3500, { type = 'weapon', unique = true, category = 'weapon', description = 'Close-range power' }),
    weapon_bow                = item('weapon_bow', 'Bow', 1500, { type = 'weapon', unique = true, category = 'weapon', description = 'Silent hunting bow' }),
    weapon_melee_knife        = item('weapon_melee_knife', 'Hunting Knife', 500, { type = 'weapon', unique = true, category = 'weapon', description = 'Sharp knife' }),
    weapon_melee_hatchet      = item('weapon_melee_hatchet', 'Hatchet', 800, { type = 'weapon', unique = true, category = 'weapon', description = 'Throwing hatchet' }),
}

-- Items granted once when a character is created (used by multicharacter).
LXRShared.StarterItems = {
    { item = 'water', amount = 2 },
    { item = 'bread', amount = 2 },
    { item = 'bandage', amount = 1 },
    { item = 'id_card', amount = 1 },
}
