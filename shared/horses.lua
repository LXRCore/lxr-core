--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Horses (breeds, coats, stats, economy)
     ═══════════════════════════════════════════════════════════════════════════
     Two layers:
       LXRShared.HorseBreeds[breed]  — class, temperament, base stats, base
                                       price, where the breed is sold, lore
       LXRShared.Horses[model]       — one entry per coat (the ped model),
                                       inheriting the breed and adding price
                                       modifiers / rarity / gender

     Stats are 1–10 like the game's stable screen: speed, acceleration,
     health, stamina, handling, courage (how it behaves near predators and
     gunfire). Stable resources sell what `availability` lists for their
     town; `wild = true` breeds can be tamed in the open. Prices are period
     dollars (a working horse $40–90, a fine saddle horse $150–400, an
     Arabian is a rich man's toy).

     Model names are RDR2 (build 1491). `LXRShared.HorseTiers` and
     `LXRShared.HorseGenders` are the vocabulary for stables and breeding.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

LXRShared.HorseClasses = {
    draft    = { label = 'Draft Horse',   description = 'Bred to pull. Slow, unshakeable, strong.' },
    work     = { label = 'Work Horse',    description = 'Ranch and trail. Honest, hardy, cheap.' },
    riding   = { label = 'Riding Horse',  description = 'Comfortable gaits, good manners.' },
    race     = { label = 'Race Horse',    description = 'Fast and fragile.' },
    war      = { label = 'War Horse',     description = 'Fearless around gunfire, tough as boot leather.' },
    multi    = { label = 'Multi-Class',   description = 'A bit of everything, and the price to match.' },
    pack     = { label = 'Pack Animal',   description = 'Not a horse. Carries more than it should.' },
}
LXRShared.HorseTemperaments = { 'docile', 'steady', 'spirited', 'nervous', 'fierce' }
LXRShared.HorseGenders = { male = 'Stallion', female = 'Mare', gelding = 'Gelding' }
LXRShared.HorseTiers = {
    [1] = { label = 'Nag',       bondingMult = 1.2, taxMult = 0.5 },
    [2] = { label = 'Common',    bondingMult = 1.0, taxMult = 1.0 },
    [3] = { label = 'Quality',   bondingMult = 0.9, taxMult = 1.5 },
    [4] = { label = 'Superior',  bondingMult = 0.8, taxMult = 2.0 },
    [5] = { label = 'Legendary', bondingMult = 0.7, taxMult = 3.0 },
}

local Breeds = {}
LXRShared.HorseBreeds = Breeds
local function breed(key, label, class, temperament, stats, price, tier, o)
    o = o or {}
    Breeds[key] = {
        key = key, label = label, class = class, temperament = temperament,
        stats = stats, price = price, tier = tier,
        availability = o.availability or { 'valentine', 'saintdenis', 'blackwater', 'strawberry', 'tumbleweed' },
        wild = o.wild == true, origin = o.origin, description = o.description or '',
        maxSpeedMps = o.maxSpeedMps, breedable = o.breedable ~= false,
    }
end

--    key                    label                    class    temper      { spd acc hp  sta hnd cou }  price tier
breed('americanpaint',       'American Paint',        'work',  'steady',   { 4, 4, 5, 5, 5, 5 },          70,   2, { origin = 'United States', description = 'Splashy coats, calm minds. The ranch favourite.', availability = { 'valentine', 'strawberry', 'blackwater', 'tumbleweed', 'armadillo' } })
breed('americanstandardbred','American Standardbred', 'race',  'spirited', { 7, 7, 4, 5, 6, 3 },          130,  3, { origin = 'United States', description = 'Trotting-track blood. Quick off the mark.', availability = { 'saintdenis', 'valentine', 'blackwater' } })
breed('andalusian',          'Andalusian',            'war',   'fierce',   { 5, 6, 8, 7, 6, 9 },          280,  4, { origin = 'Spain', description = 'Baroque war horse. Will not flinch.', availability = { 'saintdenis', 'blackwater' } })
breed('appaloosa',           'Appaloosa',             'work',  'steady',   { 5, 5, 6, 6, 6, 6 },          90,   2, { origin = 'Nez Perce country', description = 'Spotted, sure-footed, tireless.', availability = { 'valentine', 'strawberry', 'blackwater', 'tumbleweed', 'armadillo' } })
breed('arabian',             'Arabian',               'multi', 'spirited', { 8, 9, 6, 8, 9, 7 },          650,  5, { origin = 'Arabia', description = 'The finest horse money can buy, and it knows it.', availability = { 'saintdenis' }, wild = true })
breed('ardennes',            'Ardennes',              'war',   'steady',   { 4, 5, 9, 7, 5, 9 },          160,  3, { origin = 'Belgium', description = 'A war horse built like a barrel.', availability = { 'saintdenis', 'valentine', 'strawberry' } })
breed('belgian',             'Belgian Draft',         'draft', 'docile',   { 3, 3, 8, 6, 4, 7 },          80,   2, { origin = 'Belgium', description = 'Pulls a loaded freight wagon uphill without comment.', availability = { 'valentine', 'strawberry', 'annesburg', 'rhodes' } })
breed('breton',              'Breton',                'draft', 'steady',   { 4, 4, 8, 7, 5, 8 },          140,  3, { origin = 'France', description = 'Compact draft with a war horse\'s nerve.', availability = { 'saintdenis', 'blackwater', 'valentine' } })
breed('criollo',             'Criollo',               'work',  'steady',   { 5, 6, 6, 7, 6, 6 },          110,  3, { origin = 'Argentina', description = 'Pampas horse. Endurance for days.', availability = { 'tumbleweed', 'armadillo', 'blackwater' } })
breed('dutchwarmblood',      'Dutch Warmblood',       'riding','steady',   { 5, 5, 7, 6, 7, 6 },          130,  3, { origin = 'Netherlands', description = 'Elegant and even-tempered.', availability = { 'saintdenis', 'valentine' } })
breed('gypsycob',            'Gypsy Cob',             'multi', 'docile',   { 5, 5, 7, 7, 7, 6 },          150,  3, { origin = 'British Isles', description = 'Feathered legs, patient heart. The traveller\'s horse.', availability = { 'saintdenis', 'valentine', 'rhodes' } })
breed('hungarianhalfbred',   'Hungarian Halfbred',    'war',   'spirited', { 5, 5, 8, 7, 6, 8 },          150,  3, { origin = 'Hungary', description = 'Cavalry stock from the Habsburg plains.', availability = { 'saintdenis', 'blackwater', 'valentine' } })
breed('kentuckysaddle',      'Kentucky Saddler',      'riding','docile',   { 5, 5, 5, 6, 6, 5 },          60,   2, { origin = 'Kentucky', description = 'Smooth-gaited plantation horse.', availability = { 'valentine', 'rhodes', 'strawberry', 'saintdenis', 'armadillo' } })
breed('kladruber',           'Kladruber',             'draft', 'steady',   { 4, 4, 8, 7, 6, 8 },          170,  3, { origin = 'Bohemia', description = 'Imperial carriage horse. Stately.', availability = { 'saintdenis' } })
breed('missourifoxtrotter',  'Missouri Fox Trotter',  'multi', 'spirited', { 8, 8, 7, 8, 8, 7 },          450,  4, { origin = 'Missouri', description = 'Speed of a racer, stamina of a work horse. Sought after.', availability = { 'saintdenis', 'blackwater' } })
breed('morgan',              'Morgan',                'riding','docile',   { 4, 5, 5, 5, 6, 5 },          50,   2, { origin = 'Vermont', description = 'Small, willing and everywhere.', availability = { 'valentine', 'rhodes', 'strawberry', 'blackwater', 'tumbleweed', 'armadillo', 'saintdenis' } })
breed('mustang',             'Mustang',               'multi', 'nervous',  { 6, 6, 7, 7, 6, 6 },          120,  3, { origin = 'The open range', description = 'Wild-born. Sold rarely, caught often.', availability = { 'tumbleweed', 'armadillo' }, wild = true })
breed('nokota',              'Nokota',                'race',  'spirited', { 7, 7, 5, 6, 6, 4 },          110,  3, { origin = 'Dakota badlands', description = 'Hardy racer of the northern plains.', availability = { 'valentine', 'strawberry' }, wild = true })
breed('norfolkroadster',     'Norfolk Roadster',      'race',  'spirited', { 7, 7, 5, 6, 7, 4 },          180,  3, { origin = 'England', description = 'Trotting horse of English roads.', availability = { 'saintdenis', 'blackwater' } })
breed('shire',               'Shire',                 'draft', 'docile',   { 3, 3, 9, 6, 4, 8 },          100,  2, { origin = 'England', description = 'Largest horse in the world. Brewery wagons.', availability = { 'valentine', 'saintdenis', 'annesburg' } })
breed('suffolkpunch',        'Suffolk Punch',         'draft', 'docile',   { 3, 4, 8, 7, 5, 7 },          90,   2, { origin = 'England', description = 'Chestnut, always. Farm horse.', availability = { 'valentine', 'rhodes', 'strawberry' } })
breed('tennesseewalker',     'Tennessee Walker',      'riding','docile',   { 5, 5, 5, 6, 6, 5 },          60,   2, { origin = 'Tennessee', description = 'Running walk, all day. The starter horse.', availability = { 'valentine', 'rhodes', 'strawberry', 'blackwater', 'tumbleweed', 'armadillo', 'saintdenis' }, wild = true })
breed('thoroughbred',        'Thoroughbred',          'race',  'spirited', { 8, 8, 4, 6, 7, 3 },          220,  4, { origin = 'England', description = 'Racetrack royalty. Fragile legs.', availability = { 'saintdenis', 'blackwater' } })
breed('turkoman',            'Turkoman',              'multi', 'fierce',   { 7, 7, 8, 7, 7, 9 },          500,  4, { origin = 'Turkmenistan', description = 'Metallic coat, steady in a gunfight.', availability = { 'saintdenis' } })
breed('mule',                'Mule',                  'pack',  'docile',   { 3, 3, 7, 8, 4, 6 },          35,   1, { origin = 'Everywhere', description = 'Half horse, half donkey, all stubborn. Carries plenty.', availability = { 'valentine', 'rhodes', 'strawberry', 'tumbleweed', 'armadillo', 'annesburg' }, breedable = false })
breed('donkey',              'Donkey',                'pack',  'docile',   { 2, 2, 6, 7, 3, 5 },          20,   1, { origin = 'Everywhere', description = 'Small, loud, loyal.', availability = { 'tumbleweed', 'armadillo', 'rhodes' }, breedable = false })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐎 COATS — one record per model
-- ═══════════════════════════════════════════════════════════════════════════════
local Horses = {}
LXRShared.Horses = Horses
---@param model string ped model
---@param breedKey string
---@param coat string coat label
---@param o table|nil { price = override, mult = price multiplier, rarity = 'common'|…, gender = 'male'|'female'|'gelding', tier = override, stats = { partial override } }
local function coat(model, breedKey, coat, o)
    o = o or {}
    local b = Breeds[breedKey]
    local stats = {}
    for i = 1, 6 do stats[i] = (o.stats and o.stats[i]) or b.stats[i] end
    Horses[model] = {
        model = model, hash = joaat(model), breed = breedKey, coat = coat,
        label = ('%s %s'):format(b.label, coat), class = b.class, temperament = o.temperament or b.temperament,
        price = o.price or math.floor(b.price * (o.mult or 1.0) + 0.5), sellMult = 0.45,
        tier = o.tier or b.tier, rarity = o.rarity or 'common', gender = o.gender,
        stats = { speed = stats[1], acceleration = stats[2], health = stats[3], stamina = stats[4], handling = stats[5], courage = stats[6] },
        availability = o.availability or b.availability, wild = (o.wild ~= nil) and o.wild or b.wild,
    }
end

-- American Paint
coat('a_c_horse_americanpaint_greyovero',     'americanpaint', 'Grey Overo')
coat('a_c_horse_americanpaint_overo',         'americanpaint', 'Overo')
coat('a_c_horse_americanpaint_splashedwhite', 'americanpaint', 'Splashed White', { mult = 1.15, rarity = 'uncommon' })
coat('a_c_horse_americanpaint_tobiano',       'americanpaint', 'Tobiano')
-- American Standardbred
coat('a_c_horse_americanstandardbred_black',            'americanstandardbred', 'Black')
coat('a_c_horse_americanstandardbred_buckskin',         'americanstandardbred', 'Buckskin')
coat('a_c_horse_americanstandardbred_palominodapple',   'americanstandardbred', 'Palomino Dapple', { mult = 1.2, rarity = 'uncommon' })
coat('a_c_horse_americanstandardbred_silvertailbuckskin','americanstandardbred', 'Silver Tail Buckskin', { mult = 1.2, rarity = 'uncommon' })
coat('a_c_horse_americanstandardbred_lightbuckskin',    'americanstandardbred', 'Light Buckskin', { mult = 1.1 })
-- Andalusian
coat('a_c_horse_andalusian_darkbay',  'andalusian', 'Dark Bay')
coat('a_c_horse_andalusian_perlino',  'andalusian', 'Perlino', { mult = 1.3, rarity = 'rare' })
coat('a_c_horse_andalusian_rosegray', 'andalusian', 'Rose Grey', { mult = 1.15, rarity = 'uncommon' })
-- Appaloosa
coat('a_c_horse_appaloosa_blanket',        'appaloosa', 'Blanket')
coat('a_c_horse_appaloosa_brownleopard',   'appaloosa', 'Brown Leopard')
coat('a_c_horse_appaloosa_fewspotted_pc',  'appaloosa', 'Few Spotted', { mult = 1.2, rarity = 'uncommon' })
coat('a_c_horse_appaloosa_leopard',        'appaloosa', 'Leopard', { mult = 1.1 })
coat('a_c_horse_appaloosa_leopardblanket', 'appaloosa', 'Leopard Blanket')
coat('a_c_horse_appaloosa_blacksnowflake', 'appaloosa', 'Black Snowflake', { mult = 1.25, rarity = 'rare' })
-- Arabian
coat('a_c_horse_arabian_black',            'arabian', 'Black', { mult = 1.1, rarity = 'rare' })
coat('a_c_horse_arabian_grey',             'arabian', 'Grey', { rarity = 'uncommon' })
coat('a_c_horse_arabian_rosegreybay',      'arabian', 'Rose Grey Bay', { mult = 1.2, rarity = 'rare' })
coat('a_c_horse_arabian_warpedbrindle_pc', 'arabian', 'Warped Brindle', { mult = 1.4, rarity = 'exquisite' })
coat('a_c_horse_arabian_white',            'arabian', 'White', { mult = 1.8, rarity = 'legendary', wild = true, availability = {} })
coat('a_c_horse_arabian_redchestnut',      'arabian', 'Red Chestnut', { mult = 1.15, rarity = 'rare' })
-- Ardennes
coat('a_c_horse_ardennes_bayroan',        'ardennes', 'Bay Roan')
coat('a_c_horse_ardennes_irongreyroan',   'ardennes', 'Iron Grey Roan', { mult = 1.1 })
coat('a_c_horse_ardennes_strawberryroan', 'ardennes', 'Strawberry Roan', { mult = 1.1 })
-- Belgian
coat('a_c_horse_belgian_blondchestnut', 'belgian', 'Blond Chestnut')
coat('a_c_horse_belgian_mealychestnut', 'belgian', 'Mealy Chestnut')
-- Breton
coat('a_c_horse_breton_grullodun',     'breton', 'Grullo Dun')
coat('a_c_horse_breton_mealydapplebay','breton', 'Mealy Dapple Bay')
coat('a_c_horse_breton_redroan',       'breton', 'Red Roan')
coat('a_c_horse_breton_sealbrown',     'breton', 'Seal Brown')
coat('a_c_horse_breton_sorrel',        'breton', 'Sorrel')
coat('a_c_horse_breton_steelgrey',     'breton', 'Steel Grey', { mult = 1.1, rarity = 'uncommon' })
-- Criollo
coat('a_c_horse_criollo_baybrindle',    'criollo', 'Bay Brindle', { mult = 1.15, rarity = 'uncommon' })
coat('a_c_horse_criollo_bayframeovero', 'criollo', 'Bay Frame Overo')
coat('a_c_horse_criollo_blueroanovero', 'criollo', 'Blue Roan Overo', { mult = 1.1 })
coat('a_c_horse_criollo_dun',           'criollo', 'Dun')
coat('a_c_horse_criollo_marblesabino',  'criollo', 'Marble Sabino', { mult = 1.15, rarity = 'uncommon' })
coat('a_c_horse_criollo_sorrelovero',   'criollo', 'Sorrel Overo')
-- Dutch Warmblood
coat('a_c_horse_dutchwarmblood_chocolateroan', 'dutchwarmblood', 'Chocolate Roan')
coat('a_c_horse_dutchwarmblood_sealbrown',     'dutchwarmblood', 'Seal Brown')
coat('a_c_horse_dutchwarmblood_sootybuckskin', 'dutchwarmblood', 'Sooty Buckskin', { mult = 1.1 })
-- Gypsy Cob
coat('a_c_horse_gypsycob_palominoblagdon',   'gypsycob', 'Palomino Blagdon', { mult = 1.1 })
coat('a_c_horse_gypsycob_piebald',           'gypsycob', 'Piebald')
coat('a_c_horse_gypsycob_skewbald',          'gypsycob', 'Skewbald')
coat('a_c_horse_gypsycob_splashedbay',       'gypsycob', 'Splashed Bay')
coat('a_c_horse_gypsycob_splashedpiebald',   'gypsycob', 'Splashed Piebald', { mult = 1.1 })
coat('a_c_horse_gypsycob_whiteblagdon',      'gypsycob', 'White Blagdon', { mult = 1.2, rarity = 'uncommon' })
-- Hungarian Halfbred
coat('a_c_horse_hungarianhalfbred_darkdapplegrey', 'hungarianhalfbred', 'Dark Dapple Grey')
coat('a_c_horse_hungarianhalfbred_flaxenchestnut', 'hungarianhalfbred', 'Flaxen Chestnut')
coat('a_c_horse_hungarianhalfbred_liverchestnut',  'hungarianhalfbred', 'Liver Chestnut')
coat('a_c_horse_hungarianhalfbred_piebaldtobiano', 'hungarianhalfbred', 'Piebald Tobiano', { mult = 1.1 })
-- Kentucky Saddler
coat('a_c_horse_kentuckysaddle_black',            'kentuckysaddle', 'Black')
coat('a_c_horse_kentuckysaddle_chestnutpinto',    'kentuckysaddle', 'Chestnut Pinto')
coat('a_c_horse_kentuckysaddle_grey',             'kentuckysaddle', 'Grey')
coat('a_c_horse_kentuckysaddle_silverbay',        'kentuckysaddle', 'Silver Bay')
coat('a_c_horse_kentuckysaddle_buttermilkbuckskin_pc', 'kentuckysaddle', 'Buttermilk Buckskin', { mult = 1.2, rarity = 'uncommon' })
-- Kladruber
coat('a_c_horse_kladruber_black',         'kladruber', 'Black')
coat('a_c_horse_kladruber_cremello',      'kladruber', 'Cremello', { mult = 1.2, rarity = 'uncommon' })
coat('a_c_horse_kladruber_dapplerosegrey','kladruber', 'Dapple Rose Grey')
coat('a_c_horse_kladruber_grey',          'kladruber', 'Grey')
coat('a_c_horse_kladruber_silver',        'kladruber', 'Silver', { mult = 1.15 })
coat('a_c_horse_kladruber_white',         'kladruber', 'White', { mult = 1.25, rarity = 'rare' })
-- Missouri Fox Trotter
coat('a_c_horse_missourifoxtrotter_amberchampagne', 'missourifoxtrotter', 'Amber Champagne', { rarity = 'uncommon' })
coat('a_c_horse_missourifoxtrotter_blacktovero',    'missourifoxtrotter', 'Black Tovero', { rarity = 'uncommon' })
coat('a_c_horse_missourifoxtrotter_blueroan',       'missourifoxtrotter', 'Blue Roan', { rarity = 'uncommon' })
coat('a_c_horse_missourifoxtrotter_buckskinbrindle','missourifoxtrotter', 'Buckskin Brindle', { mult = 1.15, rarity = 'rare' })
coat('a_c_horse_missourifoxtrotter_dapplegrey',     'missourifoxtrotter', 'Dapple Grey', { rarity = 'uncommon' })
coat('a_c_horse_missourifoxtrotter_sablechampagne', 'missourifoxtrotter', 'Sable Champagne', { mult = 1.1, rarity = 'rare' })
coat('a_c_horse_missourifoxtrotter_silverdapplepinto', 'missourifoxtrotter', 'Silver Dapple Pinto', { mult = 1.1, rarity = 'rare' })
-- Morgan
coat('a_c_horse_morgan_bay',           'morgan', 'Bay')
coat('a_c_horse_morgan_bayroan',       'morgan', 'Bay Roan')
coat('a_c_horse_morgan_flaxenchestnut','morgan', 'Flaxen Chestnut')
coat('a_c_horse_morgan_liverchestnut_pc', 'morgan', 'Liver Chestnut')
coat('a_c_horse_morgan_palomino',      'morgan', 'Palomino', { mult = 1.1 })
-- Mustang
coat('a_c_horse_mustang_blackovero',     'mustang', 'Black Overo')
coat('a_c_horse_mustang_buckskin',       'mustang', 'Buckskin')
coat('a_c_horse_mustang_chestnuttovero', 'mustang', 'Chestnut Tovero')
coat('a_c_horse_mustang_goldendun',      'mustang', 'Golden Dun', { mult = 1.1 })
coat('a_c_horse_mustang_grullodun',      'mustang', 'Grullo Dun')
coat('a_c_horse_mustang_reddunovero',    'mustang', 'Red Dun Overo')
coat('a_c_horse_mustang_tigerstripedbay','mustang', 'Tiger Striped Bay', { mult = 1.3, rarity = 'rare', wild = true })
coat('a_c_horse_mustang_wildbay',        'mustang', 'Wild Bay')
-- Nokota
coat('a_c_horse_nokota_blueroan',          'nokota', 'Blue Roan')
coat('a_c_horse_nokota_reversedappleroan', 'nokota', 'Reverse Dapple Roan', { mult = 1.15, rarity = 'uncommon' })
coat('a_c_horse_nokota_whiteroan',         'nokota', 'White Roan')
-- Norfolk Roadster
coat('a_c_horse_norfolkroadster_black',          'norfolkroadster', 'Black')
coat('a_c_horse_norfolkroadster_dappledbuckskin','norfolkroadster', 'Dappled Buckskin')
coat('a_c_horse_norfolkroadster_piebaldroan',    'norfolkroadster', 'Piebald Roan', { mult = 1.1 })
coat('a_c_horse_norfolkroadster_rosegrey',       'norfolkroadster', 'Rose Grey')
coat('a_c_horse_norfolkroadster_speckledgrey',   'norfolkroadster', 'Speckled Grey', { mult = 1.1 })
coat('a_c_horse_norfolkroadster_spottedtricolor','norfolkroadster', 'Spotted Tricolour', { mult = 1.2, rarity = 'uncommon' })
-- Shire
coat('a_c_horse_shire_darkbay',    'shire', 'Dark Bay')
coat('a_c_horse_shire_lightgrey',  'shire', 'Light Grey')
coat('a_c_horse_shire_ravenblack', 'shire', 'Raven Black', { mult = 1.1 })
-- Suffolk Punch
coat('a_c_horse_suffolkpunch_redchestnut', 'suffolkpunch', 'Red Chestnut')
coat('a_c_horse_suffolkpunch_sorrel',      'suffolkpunch', 'Sorrel')
-- Tennessee Walker
coat('a_c_horse_tennesseewalker_blackrabicano', 'tennesseewalker', 'Black Rabicano')
coat('a_c_horse_tennesseewalker_chestnut',      'tennesseewalker', 'Chestnut')
coat('a_c_horse_tennesseewalker_dapplebay',     'tennesseewalker', 'Dapple Bay')
coat('a_c_horse_tennesseewalker_flaxenroan',    'tennesseewalker', 'Flaxen Roan')
coat('a_c_horse_tennesseewalker_goldpalomino_pc',  'tennesseewalker', 'Gold Palomino', { mult = 1.15 })
coat('a_c_horse_tennesseewalker_mahoganybay',   'tennesseewalker', 'Mahogany Bay')
coat('a_c_horse_tennesseewalker_redroan',       'tennesseewalker', 'Red Roan')
-- Thoroughbred
coat('a_c_horse_thoroughbred_blackchestnut',      'thoroughbred', 'Black Chestnut')
coat('a_c_horse_thoroughbred_bloodbay',           'thoroughbred', 'Blood Bay')
coat('a_c_horse_thoroughbred_brindle',            'thoroughbred', 'Brindle', { mult = 1.25, rarity = 'rare' })
coat('a_c_horse_thoroughbred_dapplegrey',         'thoroughbred', 'Dapple Grey')
-- Turkoman
coat('a_c_horse_turkoman_darkbay',  'turkoman', 'Dark Bay')
coat('a_c_horse_turkoman_gold',     'turkoman', 'Gold', { mult = 1.15, rarity = 'rare' })
coat('a_c_horse_turkoman_silver',   'turkoman', 'Silver', { mult = 1.15, rarity = 'rare' })
coat('a_c_horse_turkoman_chestnut', 'turkoman', 'Chestnut')
coat('a_c_horse_turkoman_grey',     'turkoman', 'Grey')
coat('a_c_horse_turkoman_perlino',  'turkoman', 'Perlino', { mult = 1.25, rarity = 'rare' })
coat('a_c_horse_turkoman_black',    'turkoman', 'Black', { mult = 1.2, rarity = 'rare' })
-- ═══ Story & special horses — never sold; spawned by events, admins or as legendary catches ═══
breed('story', 'Story Horse', 'multi', 'steady', { 6, 6, 7, 7, 7, 7 }, 0, 5, { availability = {}, description = 'Horses with a history. Not for sale at any stable.', breedable = false })
breed('mangy', 'Mangy Nag',   'work',  'nervous', { 3, 3, 3, 3, 3, 2 }, 5, 1, { availability = {}, description = 'Half-starved, half-wild, all misery. Murfree country.', breedable = false, wild = true })
coat('a_c_horse_buell_warvets',     'story', 'Buell (Hungarian Halfbred)', { rarity = 'legendary', stats = { 6, 6, 9, 8, 6, 10 } })
coat('a_c_horse_eagleflies',        'story', "Eagle Flies' Paint",        { rarity = 'legendary', stats = { 6, 7, 6, 7, 8, 8 } })
coat('a_c_horse_gang_bill',         'story', 'Brown Jack (Suffolk Punch)', { rarity = 'exquisite', stats = { 4, 4, 8, 7, 5, 7 } })
coat('a_c_horse_gang_charles',      'story', 'Taima (Appaloosa)',          { rarity = 'exquisite', stats = { 5, 5, 6, 7, 6, 7 } })
coat('a_c_horse_gang_charles_endlesssummer', 'story', 'Falmouth (Turkoman)', { rarity = 'exquisite', stats = { 7, 7, 8, 7, 7, 9 } })
coat('a_c_horse_gang_dutch',        'story', 'The Count (Arabian)',        { rarity = 'legendary', stats = { 8, 9, 6, 8, 9, 7 } })
coat('a_c_horse_gang_hosea',        'story', 'Silver Dollar (Kladruber)',  { rarity = 'exquisite', stats = { 4, 4, 8, 7, 6, 8 } })
coat('a_c_horse_gang_javier',       'story', 'Boaz (Standardbred)',        { rarity = 'exquisite', stats = { 7, 7, 4, 5, 6, 3 } })
coat('a_c_horse_gang_john',         'story', 'Old Boy (Tennessee Walker)', { rarity = 'exquisite', stats = { 5, 5, 5, 6, 6, 5 } })
coat('a_c_horse_gang_karen',        'story', 'Old Belle (Morgan)',         { rarity = 'exquisite', stats = { 4, 5, 5, 5, 6, 5 } })
coat('a_c_horse_gang_kieran',       'story', 'Branwen (Morgan)',           { rarity = 'exquisite', stats = { 4, 5, 5, 5, 6, 5 } })
coat('a_c_horse_gang_lenny',        'story', 'Maggie (Kentucky Saddler)',  { rarity = 'exquisite', stats = { 5, 5, 5, 6, 6, 5 } })
coat('a_c_horse_gang_micah',        'story', 'Baylock (Missouri Fox Trotter)', { rarity = 'exquisite', stats = { 8, 8, 7, 8, 8, 7 } })
coat('a_c_horse_gang_sadie',        'story', 'Bob (Kentucky Saddler)',     { rarity = 'exquisite', stats = { 5, 5, 5, 6, 6, 5 } })
coat('a_c_horse_gang_sadie_endlesssummer', 'story', 'Hera (Hungarian Halfbred)', { rarity = 'exquisite', stats = { 5, 5, 8, 7, 6, 8 } })
coat('a_c_horse_gang_sean',         'story', 'Ennis (Mustang)',            { rarity = 'exquisite', stats = { 6, 6, 7, 7, 6, 6 } })
coat('a_c_horse_gang_trelawney',    'story', 'Gwydion (Andalusian)',       { rarity = 'exquisite', stats = { 5, 6, 8, 7, 6, 9 } })
coat('a_c_horse_gang_uncle',        'story', 'Nell IV (Gypsy Cob)',        { rarity = 'exquisite', stats = { 5, 5, 7, 7, 7, 6 } })
coat('a_c_horse_gang_uncle_endlesssummer', 'story', 'Nell V (Gypsy Cob)',  { rarity = 'exquisite', stats = { 5, 5, 7, 7, 7, 6 } })
coat('a_c_horse_john_endlesssummer','story', 'Rachel (Hungarian Halfbred)',{ rarity = 'exquisite', stats = { 5, 5, 8, 7, 6, 8 } })
coat('a_c_horse_winter02_01',       'story', 'Winter Grey',                { rarity = 'rare' })
coat('a_c_horse_mp_mangy_backup',   'mangy', 'Backup Nag')
coat('a_c_horse_murfreebrood_mange_01', 'mangy', 'Mange I')
coat('a_c_horse_murfreebrood_mange_02', 'mangy', 'Mange II')
coat('a_c_horse_murfreebrood_mange_03', 'mangy', 'Mange III')

-- Pack animals
coat('a_c_horsemule_01',        'mule',   'Brown')
coat('a_c_horsemulepainted_01', 'mule',   'Painted', { mult = 1.2 })
coat('a_c_donkey_01',           'donkey', 'Grey')

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 LOOKUPS
-- ═══════════════════════════════════════════════════════════════════════════════
function LXRShared.GetHorse(ref)
    if type(ref) == 'string' then
        local h = Horses[ref:lower()]
        if h then return h end
        ref = joaat(ref)
    end
    for _, h in pairs(Horses) do if h.hash == ref then return h end end
    return nil
end

---Horses a stable in `town` may sell (sorted by price).
function LXRShared.HorsesForTown(town)
    local out = {}
    for _, h in pairs(Horses) do
        for _, t in ipairs(h.availability or {}) do if t == town then out[#out + 1] = h break end end
    end
    table.sort(out, function(a, b) return a.price < b.price end)
    return out
end

function LXRShared.HorsesOfBreed(breedKey)
    local out = {}
    for _, h in pairs(Horses) do if h.breed == breedKey then out[#out + 1] = h end end
    table.sort(out, function(a, b) return a.label < b.label end)
    return out
end
