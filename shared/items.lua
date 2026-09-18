--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Items (1899 – 1907 frontier catalog)
     ═══════════════════════════════════════════════════════════════════════════
     Built with the catalog definers (shared/catalog.lua). Each line is one
     thing that exists in the world; the category profile fills in animation,
     use-time, decay and stack rules so a record only states what is special
     about it.

       I(name, label, grams, { category=, value=, effects=, use=, ... })
       F(name, label, grams, { hunger=, thirst=, ... }, opts)   -- food
       D(name, label, grams, { thirst=, ... }, opts)            -- drink
       M(name, label, grams, { health=, ... }, opts)            -- medical

     Conventions
       • weight is grams; `value` is the 1899 retail price in dollars and
         cents and is set by shared/prices.lua (the price ledger) — inline
         values here are placeholders that the ledger overrides;
       • graded goods (pelts, meat, fish, tools, weapons) carry
         info.quality (1 poor / 2 good / 3 perfect) — never three items;
       • `legal = false` marks contraband: lawmen may seize, fences buy,
         shops refuse;
       • `era` is the first year the item plausibly existed — shops filter
         with Config.Catalog.year so a 1899 server never sells a 1905 gun.

     Add items here or at runtime: LXRCore.Functions.AddItem(name, data).
     Keys must equal `name` and be lowercase (validated by tests + boot).
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}
local C = LXRShared.Catalog
local I, F, D, M = C.Item, C.Food, C.Drink, C.Medical

local Items = {}
local function add(rec) Items[rec.name] = rec end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💵 CURRENCY
-- ═══════════════════════════════════════════════════════════════════════════════
add(I('dollar',        'Dollar',              0,   { category = 'currency', value = 1,    description = 'United States banknote.' }))
add(I('cent',          'Cent',                0,   { category = 'currency', value = 0.01, description = 'Copper coin.' }))
add(I('blood_dollar',  'Marked Dollar',       0,   { category = 'currency', value = 0.6,  legal = false, description = 'Bills with serials the banks are looking for. Fences take them at a cut.' }))
add(I('gold_nugget',   'Gold Nugget',         20,  { category = 'currency', value = 12,   rarity = 'uncommon', stack = 100, description = 'Raw placer gold, straight from the pan.' }))
add(I('gold_dust',     'Gold Dust',           5,   { category = 'currency', value = 2,    stack = 500, description = 'Fine gold dust in a paper twist.' }))
add(I('gold_bar',      'Gold Bar',            1000,{ category = 'currency', value = 500,  rarity = 'rare', stack = 10, droppable = true, description = 'A stamped bullion bar. Heavy, and heavily wanted.' }))
add(I('silver_bar',    'Silver Bar',          1000,{ category = 'currency', value = 60,   rarity = 'uncommon', stack = 10, description = 'A stamped silver bar.' }))
add(I('bank_note',     'Bank Note ($100)',    5,   { category = 'currency', value = 100,  rarity = 'uncommon', stack = 50, description = 'A hundred-dollar bearer note.' }))
add(I('confederate_bill', 'Confederate Bill', 5,   { category = 'collectible', value = 0.25, description = 'Worthless since 1865. Some folks in Lemoyne still refuse to believe it.', useable = false }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🍞 FOOD — baked, preserved, fresh, cooked
-- ═══════════════════════════════════════════════════════════════════════════════
add(F('bread',        'Loaf of Bread',       250, { hunger = 20 },                { value = 0.05, use = { prop = 'bread' }, description = 'Day-old bread from the general store.' }))
add(F('biscuit',      'Biscuit',             60,  { hunger = 8 },                 { value = 0.02, description = 'A hard baking-soda biscuit.' }))
add(F('cornbread',    'Cornbread',           200, { hunger = 18 },                { value = 0.05, description = 'Skillet cornbread, southern style.' }))
add(F('hardtack',     'Hardtack',            100, { hunger = 10, stress = 2 },    { value = 0.03, decay = { hours = 720, into = 'spoiled_food' }, description = 'Army cracker. Keeps for years, tastes like it too.' }))
add(F('cracker',      'Crackers',            80,  { hunger = 6 },                 { value = 0.02, stack = 20, description = 'Salted soda crackers.' }))
add(F('apple',        'Apple',               120, { hunger = 8, thirst = 4 },     { value = 0.03, use = { prop = 'apple' }, tags = { 'horse_treat', 'fruit' }, decay = { hours = 120, into = 'spoiled_food' }, description = 'A crisp red apple. Horses love them.' }))
add(F('pear',         'Pear',                130, { hunger = 8, thirst = 5 },     { value = 0.04, tags = { 'fruit' }, description = 'A ripe pear from an orchard in Lemoyne.' }))
add(F('peach',        'Peach',               130, { hunger = 8, thirst = 6 },     { value = 0.05, tags = { 'fruit' }, description = 'Sweet Georgia peach, shipped by rail.' }))
add(F('orange',       'Orange',              150, { hunger = 6, thirst = 8 },     { value = 0.08, rarity = 'uncommon', tags = { 'fruit' }, description = 'A rare treat this far north.' }))
add(F('carrot',       'Carrot',              80,  { hunger = 5 },                 { value = 0.02, tags = { 'horse_treat', 'vegetable' }, decay = { hours = 240, into = 'spoiled_food' }, description = 'Garden carrot. Good for you, better for your horse.' }))
add(F('potato',       'Potato',              200, { hunger = 10 },                { value = 0.02, tags = { 'vegetable' }, decay = { hours = 480, into = 'spoiled_food' }, description = 'A humble spud.' }))
add(F('onion',        'Onion',               120, { hunger = 3 },                 { value = 0.02, tags = { 'vegetable' }, decay = { hours = 480, into = 'spoiled_food' }, description = 'Yellow onion.' }))
add(F('corn',         'Ear of Corn',         200, { hunger = 10 },                { value = 0.02, tags = { 'vegetable', 'horse_treat' }, description = 'Sweet corn on the cob.' }))
add(F('tomato',       'Tomato',              120, { hunger = 5, thirst = 3 },     { value = 0.03, tags = { 'vegetable' }, decay = { hours = 96, into = 'spoiled_food' }, description = 'A ripe tomato.' }))
add(F('egg',          'Egg',                 60,  { hunger = 5 },                 { value = 0.02, stack = 24, decay = { hours = 336, into = 'spoiled_food' }, description = 'A hen egg.' }))
add(F('boiled_egg',   'Boiled Egg',          60,  { hunger = 10 },                { value = 0.04, description = 'A hard-boiled egg with a pinch of salt.' }))
add(F('cheese',       'Wedge of Cheese',     200, { hunger = 15 },                { value = 0.12, decay = { hours = 336, into = 'spoiled_food' }, description = 'Sharp farmhouse cheese.' }))
add(F('butter',       'Butter',              200, { hunger = 4 },                 { value = 0.15, useable = false, tags = { 'ingredient' }, decay = { hours = 168, into = 'spoiled_food' }, description = 'Churned butter, wrapped in cloth.' }))
add(F('jerky',        'Beef Jerky',          100, { hunger = 15, thirst = -3 },   { value = 0.15, decay = { hours = 1440, into = 'spoiled_food' }, description = 'Dried and salted. Trail food.' }))
add(F('salted_meat',  'Salted Meat',         300, { hunger = 18, thirst = -5 },   { value = 0.2, decay = { hours = 720, into = 'spoiled_meat' }, description = 'Pork preserved in salt.' }))
add(F('bacon',        'Bacon',               200, { hunger = 4 },                 { value = 0.15, useable = false, tags = { 'ingredient' }, description = 'Raw sliced bacon.' }))
add(F('bacon_cooked', 'Fried Bacon',         180, { hunger = 22, stress = -3 },   { value = 0.25, use = { prop = 'meat_cooked' }, description = 'Crisp bacon from a hot skillet.' }))
add(F('sausage',      'Sausage',             150, { hunger = 20 },                { value = 0.12, description = 'Smoked pork sausage.' }))
add(F('oatmeal',      'Bowl of Oatmeal',     300, { hunger = 22, warmth = 5 },    { value = 0.05, description = 'Hot oats with a little molasses.' }))
add(F('stew_beef',    'Beef Stew',           400, { hunger = 40, thirst = 10, stress = -5, core_health = 10 }, { value = 0.35, description = 'Thick beef stew from the saloon kitchen.' }))
add(F('stew_venison', 'Venison Stew',        400, { hunger = 45, thirst = 10, stress = -5, core_health = 15 }, { value = 0.4, rarity = 'uncommon', description = 'Camp stew of venison, potato and wild onion.' }))
add(F('stew_bean',    'Bean Stew',           400, { hunger = 35, thirst = 8 },    { value = 0.2, description = 'Beans, bacon and molasses.' }))
add(F('chili',        'Bowl of Chili',       400, { hunger = 38, warmth = 10, stress = -4 }, { value = 0.3, description = 'New Austin chili. Not for the faint of stomach.' }))
add(F('pie_apple',    'Apple Pie',           350, { hunger = 30, stress = -8 },   { value = 0.4, rarity = 'uncommon', description = 'A whole apple pie, still warm.' }))
add(F('pie_meat',     'Meat Pie',            350, { hunger = 35, stress = -4 },   { value = 0.4, description = 'Minced beef in a lard crust.' }))
add(F('canned_beans', 'Canned Beans',        400, { hunger = 25 },                { value = 0.1, use = { prop = 'can' }, decay = { hours = 4320, into = 'spoiled_food' }, description = 'Baked beans in a tin. Bring a knife.' }))
add(F('canned_corn',  'Canned Sweetcorn',    400, { hunger = 20 },                { value = 0.1, use = { prop = 'can' }, decay = { hours = 4320, into = 'spoiled_food' }, description = 'Tinned corn.' }))
add(F('canned_peaches', 'Canned Peaches',    450, { hunger = 18, thirst = 12, stress = -3 }, { value = 0.15, use = { prop = 'can' }, decay = { hours = 4320, into = 'spoiled_food' }, description = 'Peaches in syrup. A luxury on the trail.' }))
add(F('canned_salmon', 'Canned Salmon',      400, { hunger = 28 },                { value = 0.18, use = { prop = 'can' }, decay = { hours = 4320, into = 'spoiled_food' }, description = 'Pacific salmon in a tin.' }))
add(F('canned_meat',  'Canned Corned Beef',  400, { hunger = 30 },                { value = 0.15, use = { prop = 'can' }, decay = { hours = 4320, into = 'spoiled_food' }, description = 'Corned beef, army surplus.' }))
add(F('candy_stick',  'Peppermint Stick',    30,  { hunger = 2, stress = -5 },    { value = 0.01, stack = 25, description = 'Red-and-white peppermint candy.' }))
add(F('chocolate',    'Chocolate Bar',       80,  { hunger = 8, stress = -6, stamina = 5 }, { value = 0.1, rarity = 'uncommon', description = 'Milk chocolate. Melts in summer.' }))
add(F('honey',        'Jar of Honey',        350, { hunger = 10, stamina = 10 },  { value = 0.25, use = { prop = 'bottle_jar' }, decay = { hours = 8760, into = 'spoiled_food' }, description = 'Wildflower honey.' }))
add(F('peanuts',      'Bag of Peanuts',      120, { hunger = 8 },                 { value = 0.05, stack = 20, description = 'Roasted peanuts in a paper bag.' }))
add(F('smoked_fish',  'Smoked Fish',         250, { hunger = 25, thirst = -3 },   { value = 0.2, decay = { hours = 336, into = 'spoiled_meat' }, description = 'Cold-smoked over alder.' }))
add(F('spoiled_food', 'Spoiled Food',        200, { hunger = 5, health = -20 },   { value = 0, rarity = 'common', decay = false, description = 'Gone off. Pigs might eat it.', tags = { 'spoiled' } }))
add(F('spoiled_meat', 'Rotten Meat',         300, { hunger = 5, health = -40 },   { value = 0, decay = false, description = 'Green and crawling. Bait, at best.', tags = { 'spoiled', 'bait' } }))

-- ingredients (not eaten as-is)
add(I('flour',        'Bag of Flour',        1000,{ category = 'food', value = 0.05, useable = false, stack = 20, decay = false, tags = { 'ingredient' }, description = 'Wheat flour.' }))
add(I('sugar',        'Bag of Sugar',        1000,{ category = 'food', value = 0.06, useable = false, stack = 20, decay = false, tags = { 'ingredient' }, description = 'Cane sugar.' }))
add(I('salt',         'Salt',                500, { category = 'food', value = 0.02, useable = false, stack = 20, decay = false, tags = { 'ingredient', 'preserving' }, description = 'Rock salt for curing and cooking.' }))
add(I('pepper',       'Black Pepper',        100, { category = 'food', value = 0.1, useable = false, stack = 20, decay = false, tags = { 'ingredient', 'seasoning' }, description = 'Ground peppercorn.' }))
add(I('coffee_beans', 'Coffee Beans',        500, { category = 'food', value = 0.25, useable = false, stack = 20, decay = false, tags = { 'ingredient' }, description = 'Roasted Arbuckle beans.' }))
add(I('rice',         'Bag of Rice',         1000,{ category = 'food', value = 0.06, useable = false, stack = 20, decay = false, tags = { 'ingredient' }, description = 'Louisiana rice.' }))
add(I('lard',         'Tin of Lard',         500, { category = 'food', value = 0.08, useable = false, stack = 10, decay = false, tags = { 'ingredient' }, description = 'Rendered pork fat.' }))
add(I('molasses',     'Molasses',            500, { category = 'food', value = 0.1, useable = false, stack = 10, decay = false, tags = { 'ingredient' }, description = 'Thick cane syrup.' }))
add(I('yeast',        'Yeast Cake',          50,  { category = 'food', value = 0.05, useable = false, stack = 20, decay = { hours = 336, into = 'spoiled_food' }, tags = { 'ingredient', 'distilling' }, description = 'Compressed yeast.' }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🥩 MEAT & FISH — raw is graded, cooked is not; species drive fishing/hunting
-- ═══════════════════════════════════════════════════════════════════════════════
local function meat(name, label, w, value, desc)      add(I(name, label, w, { category = 'meat', value = value, description = desc, tags = { 'raw_meat' } })) end
local function cooked(name, label, w, fx, value, desc) add(F(name, label, w, fx, { category = 'food', value = value, use = { prop = 'meat_cooked' }, decay = { hours = 48, into = 'spoiled_meat' }, description = desc })) end

meat('meat_big_game',   'Big Game Meat',      600, 0.6,  'Bear, bison, moose or elk. A feast, cooked right.')
meat('meat_venison',    'Venison',            500, 0.4,  'Deer meat, still warm.')
meat('meat_mutton',     'Mutton',             400, 0.3,  'From a bighorn or a farm sheep.')
meat('meat_beef',       'Prime Beef',         500, 0.5,  'Cut from a steer.')
meat('meat_pork',       'Pork',               450, 0.4,  'Boar or farm pig.')
meat('meat_gamey',      'Gamey Meat',         300, 0.2,  'Rabbit, squirrel, raccoon — whatever was small and unlucky.')
meat('meat_stringy',    'Stringy Meat',       250, 0.1,  'Coyote, wolf, cougar. Edible, barely.')
meat('meat_plump_bird', 'Plump Bird',         300, 0.3,  'Turkey, goose, duck or pheasant.')
meat('meat_gristly',    'Gristly Meat',       200, 0.08, 'Crow, buzzard, seagull. Only if you must.')
meat('meat_gator',      'Alligator Meat',     500, 0.35, 'Tastes like chicken, they say.')
meat('meat_tender',     'Tender Meat',        250, 0.25, 'Fawn, kid, lamb.')
meat('fish_flaky',      'Flaky Fish',         250, 0.15, 'Trout, perch, bluegill.')
meat('fish_succulent',  'Succulent Fish',     400, 0.3,  'Salmon, bass, pike.')
meat('fish_gritty',     'Gritty Fish',        350, 0.12, 'Catfish, bullhead, gar.')

cooked('meat_big_game_cooked',   'Roasted Big Game',    500, { hunger = 45, core_health = 20, stress = -5 }, 1.0,  'Seared over a camp fire.')
cooked('meat_venison_cooked',    'Roasted Venison',     400, { hunger = 40, core_health = 15 },              0.8,  'Venison with a crust of salt.')
cooked('meat_mutton_cooked',     'Roasted Mutton',      350, { hunger = 35, core_health = 10 },              0.6,  'Fatty and filling.')
cooked('meat_beef_cooked',       'Grilled Steak',       400, { hunger = 42, core_health = 15, stress = -4 }, 0.9,  'A proper steak.')
cooked('meat_pork_cooked',       'Roast Pork',          380, { hunger = 40, core_health = 12 },              0.7,  'Crackling and all.')
cooked('meat_gamey_cooked',      'Roasted Small Game',  250, { hunger = 25, core_health = 8 },               0.4,  'Better than it sounds.')
cooked('meat_stringy_cooked',    'Roasted Stringy Meat',200, { hunger = 18, core_health = 4 },               0.2,  'Chewy.')
cooked('meat_plump_bird_cooked', 'Roasted Bird',        250, { hunger = 32, core_health = 10 },              0.6,  'Crisp skin, juicy meat.')
cooked('meat_gristly_cooked',    'Roasted Gristly Meat',180, { hunger = 12, core_health = 2, stress = 2 },   0.15, 'You have eaten worse. Probably.')
cooked('meat_gator_cooked',      'Fried Alligator',     400, { hunger = 36, core_health = 10 },              0.7,  'Bayou delicacy.')
cooked('meat_tender_cooked',     'Roasted Tender Meat', 220, { hunger = 28, core_health = 12 },              0.5,  'Melts in the mouth.')
cooked('fish_flaky_cooked',      'Pan-Fried Fish',      220, { hunger = 28, core_health = 8 },               0.4,  'Crisp and flaky.')
cooked('fish_succulent_cooked',  'Grilled Salmon',      350, { hunger = 38, core_health = 14, stress = -3 }, 0.7,  'Rich, pink and perfect.')
cooked('fish_gritty_cooked',     'Fried Catfish',       300, { hunger = 30, core_health = 6 },               0.3,  'Cornmeal-crusted.')

-- whole fish (fishing resources hand these out; a butcher or the player fillets them)
local function fish(name, label, w, value, rarity, water, desc)
    add(I(name, label, w, { category = 'meat', value = value, rarity = rarity or 'common', tags = { 'fish', water }, description = desc, decay = { hours = 36, into = 'spoiled_meat' } }))
end
fish('fish_bluegill',        'Bluegill',           300,  0.25, 'common',   'lake',  'Small and eager. Bread crumbs work.')
fish('fish_perch',           'Perch',              350,  0.3,  'common',   'lake',  'Striped panfish.')
fish('fish_rock_bass',       'Rock Bass',          400,  0.3,  'common',   'river', 'Red-eyed and stubborn.')
fish('fish_chain_pickerel',  'Chain Pickerel',     700,  0.5,  'common',   'swamp', 'Toothy pike cousin.')
fish('fish_redfin_pickerel', 'Redfin Pickerel',    500,  0.45, 'common',   'swamp', 'Small pickerel of the bayou.')
fish('fish_bullhead',        'Bullhead Catfish',   800,  0.5,  'common',   'swamp', 'Bottom feeder. Cheese bait.')
fish('fish_smallmouth_bass', 'Smallmouth Bass',    1500, 0.9,  'uncommon', 'river', 'Bronze fighter of clear rivers.')
fish('fish_largemouth_bass', 'Largemouth Bass',    2500, 1.4,  'uncommon', 'lake',  'Big mouth, bigger appetite.')
fish('fish_steelhead',       'Steelhead Trout',    3000, 1.8,  'uncommon', 'river', 'Sea-run rainbow trout.')
fish('fish_sockeye',         'Sockeye Salmon',     3500, 2.2,  'rare',     'river', 'Red-fleshed northern salmon.')
fish('fish_northern_pike',   'Northern Pike',      5000, 2.6,  'rare',     'lake',  'Water wolf.')
fish('fish_channel_catfish', 'Channel Catfish',    6000, 2.4,  'rare',     'swamp', 'Whiskered giant.')
fish('fish_longnose_gar',    'Longnose Gar',       7000, 2.5,  'rare',     'swamp', 'Armoured prehistoric leftover.')
fish('fish_muskie',          'Muskie',             9000, 3.5,  'exquisite','lake',  'The fish of ten thousand casts.')
fish('fish_lake_sturgeon',   'Lake Sturgeon',      12000,4.5,  'exquisite','lake',  'Older than the state it swims in.')

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🥃 DRINK — water, hot drinks, soft drinks
-- ═══════════════════════════════════════════════════════════════════════════════
add(D('water',        'Bottle of Water',     500, { thirst = 30 },                 { value = 0.02, use = { prop = 'bottle_jar' }, description = 'Clean well water.' }))
add(I('canteen',      'Canteen',             400, { category = 'tool', value = 1.5, quality = true, useable = true, use = { time = 3000, anim = 'drink', prop = 'canteen', consume = false }, effects = { thirst = 25 }, tags = { 'refillable' }, description = 'Tin canteen. Refill at any river, well or trough. Holds 5 draughts (info.charges).' }))
add(D('coffee',       'Cup of Coffee',       250, { thirst = 15, stamina = 15, stress = -3 }, { value = 0.05, use = { prop = 'mug' }, description = 'Black, hot and strong.' }))
add(D('tea',          'Cup of Tea',          250, { thirst = 18, stress = -6 },    { value = 0.05, use = { prop = 'cup_tea' }, description = 'Black tea with a slice of lemon, Saint Denis style.' }))
add(D('milk',         'Bottle of Milk',      500, { thirst = 20, hunger = 8 },     { value = 0.05, use = { prop = 'bottle_jar' }, decay = { hours = 48, into = 'spoiled_food' }, description = 'Fresh from the dairy wagon.' }))
add(D('lemonade',     'Lemonade',            400, { thirst = 28, stress = -4 },    { value = 0.05, use = { prop = 'bottle_jar' }, description = 'Sweet and sour.' }))
add(D('sarsaparilla', 'Sarsaparilla',        400, { thirst = 25, stress = -3 },    { value = 0.05, use = { prop = 'bottle_beer' }, description = 'Root soda. The temperance choice.' }))
add(D('ginger_beer',  'Ginger Beer',         400, { thirst = 25, stamina = 5 },    { value = 0.06, use = { prop = 'bottle_beer' }, description = 'Brewed ginger, non-alcoholic. Mostly.' }))
add(D('cider',        'Apple Cider',         400, { thirst = 22, drunk = 5 },      { value = 0.08, use = { prop = 'bottle_beer' }, category = 'alcohol', description = 'Farm cider, lightly hard.' }))
add(D('broth',        'Bone Broth',          300, { thirst = 15, hunger = 12, core_health = 8, warmth = 8 }, { value = 0.1, use = { prop = 'mug' }, description = 'Simmered all night.' }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🍺 SPIRITS — drunk builds up; the HUD / status resource reads `drunk`
-- ═══════════════════════════════════════════════════════════════════════════════
local function booze(name, label, w, fx, value, opts)
    opts = opts or {}; opts.category = 'alcohol'; opts.value = value; opts.effects = fx
    add(I(name, label, w, opts))
end
booze('beer',          'Bottle of Beer',      500, { thirst = 20, drunk = 8, stress = -5 },   0.05, { use = { prop = 'bottle_beer' }, description = 'Lager from the Valentine brewery.' })
booze('whiskey',       'Whiskey',             500, { thirst = 5, drunk = 25, stress = -10, warmth = 10 }, 0.25, { use = { prop = 'bottle_whiskey' }, description = 'Rye whiskey. Rough but honest.' })
booze('whiskey_fine',  'Fine Whiskey',        500, { thirst = 5, drunk = 22, stress = -15, core_health = 5 }, 1.5, { rarity = 'uncommon', use = { prop = 'bottle_whiskey' }, description = 'Kentucky bourbon, twelve years in the barrel.' })
booze('bourbon',       'Bourbon',             500, { thirst = 5, drunk = 24, stress = -12 }, 0.6,  { use = { prop = 'bottle_whiskey' }, description = 'Sweet corn whiskey.' })
booze('rum',           'Rum',                 500, { thirst = 5, drunk = 26, stress = -8, warmth = 12 }, 0.4, { use = { prop = 'bottle_whiskey' }, description = 'Dark rum off a Saint Denis freighter.' })
booze('gin',           'Gin',                 500, { thirst = 8, drunk = 24, stress = -8 },  0.4,  { use = { prop = 'bottle_whiskey' }, description = 'Juniper spirit.' })
booze('brandy',        'Brandy',              500, { thirst = 5, drunk = 22, stress = -14, warmth = 8 }, 1.2, { rarity = 'uncommon', use = { prop = 'bottle_whiskey' }, description = 'French brandy. For gentlemen and those pretending.' })
booze('wine',          'Bottle of Wine',      750, { thirst = 15, drunk = 15, stress = -10 }, 0.8, { use = { prop = 'bottle_whiskey' }, description = 'Red wine from a Lemoyne plantation.' })
booze('absinthe',      'Absinthe',            500, { thirst = 0, drunk = 40, stress = -20, health = -5 }, 2.5, { rarity = 'rare', use = { prop = 'bottle_whiskey' }, description = 'The green fairy. Popular in Saint Denis parlours.' })
booze('mint_julep',    'Mint Julep',          300, { thirst = 18, drunk = 12, stress = -8 }, 0.2, { use = { prop = 'mug' }, description = 'Bourbon, sugar, mint, crushed ice.' })
booze('moonshine',     'Moonshine',           500, { thirst = 0, drunk = 45, stress = -12, health = -8 }, 0.5, { legal = false, use = { prop = 'bottle_jar' }, tags = { 'contraband' }, description = 'Corn liquor from a hidden still. Untaxed and unforgiving.' })
booze('moonshine_fine','Aged Moonshine',      500, { thirst = 0, drunk = 40, stress = -18, core_stamina = 10 }, 1.5, { legal = false, rarity = 'uncommon', use = { prop = 'bottle_jar' }, tags = { 'contraband' }, description = 'Smooth as a river stone. Still illegal.' })
booze('moonshine_berry','Berry Moonshine',    500, { thirst = 5, drunk = 38, stress = -16, core_health = 8 }, 1.8, { legal = false, rarity = 'uncommon', use = { prop = 'bottle_jar' }, tags = { 'contraband' }, description = 'Infused with wild berries.' })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🚬 TOBACCO
-- ═══════════════════════════════════════════════════════════════════════════════
add(I('cigarette',    'Cigarette',           5,   { category = 'tobacco', value = 0.01, stack = 50, effects = { stress = -8, stamina = -2 }, use = { prop = 'cigarette' }, description = 'Hand-rolled.' }))
add(I('cigar',        'Cigar',               15,  { category = 'tobacco', value = 0.1, effects = { stress = -14, stamina = -3 }, use = { prop = 'cigar', time = 9000 }, description = 'A fat Cuban.' }))
add(I('cigar_fine',   'Premium Cigar',       15,  { category = 'tobacco', value = 0.5, rarity = 'uncommon', effects = { stress = -20 }, use = { prop = 'cigar', time = 9000 }, description = 'Hand-rolled in Havana, sold in Saint Denis.' }))
add(I('pipe_tobacco', 'Pipe Tobacco',        100, { category = 'tobacco', value = 0.15, stack = 10, effects = { stress = -10 }, use = { prop = 'pipe', time = 8000 }, requires = { tool = 'pipe' }, description = 'Virginia leaf in a tin. Needs a pipe.' }))
add(I('chewing_tobacco', 'Chewing Tobacco',  100, { category = 'tobacco', value = 0.1, stack = 10, effects = { stress = -6, thirst = -4 }, use = { anim = 'eat', time = 2000 }, description = 'A plug of chew.' }))
add(I('snuff',        'Snuff',               50,  { category = 'tobacco', value = 0.12, stack = 10, effects = { stress = -6, stamina = 4 }, use = { anim = 'inspect', time = 1500 }, description = 'Powdered tobacco in a tin.' }))
add(I('tobacco_leaf', 'Tobacco Leaf',        50,  { category = 'material', value = 0.03, stack = 50, description = 'Cured leaf, ready for rolling.', tags = { 'crafting' } }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🩹 MEDICAL — 1899 medicine: tonics, opiates, bandages and honest doctoring
-- ═══════════════════════════════════════════════════════════════════════════════
add(M('bandage',        'Bandage',            80,  { health = 15 },                       { value = 0.1, use = { prop = 'bandage' }, description = 'Cloth strip. Stops the bleeding, if not the pain.' }))
add(M('bandage_clean',  'Sterile Dressing',   80,  { health = 30 },                       { value = 0.4, rarity = 'uncommon', use = { prop = 'bandage' }, description = 'Boiled linen and carbolic. Doctor grade.' }))
add(M('splint',         'Splint',             300, { health = 10 },                       { value = 0.3, use = { time = 6000 }, tags = { 'medic' }, description = 'Two boards and a strap. Fixes a broken limb (status resource).' }))
add(M('stitching_kit',  'Suture Kit',         150, { health = 40 },                       { value = 1.0, rarity = 'uncommon', use = { time = 8000 }, requires = { job = 'medical' }, description = 'Catgut and a curved needle. For doctors.' }))
add(M('health_tonic',   'Health Tonic',       300, { health = 50, core_health = 20 },     { value = 0.5, use = { prop = 'tonic', anim = 'drink' }, description = "Dr. Hackett's Restorative. Works, mostly." }))
add(M('health_tonic_potent', 'Potent Health Tonic', 300, { health = 100, core_health = 50 }, { value = 1.5, rarity = 'uncommon', use = { prop = 'tonic', anim = 'drink' }, description = 'Double strength. Tastes like turpentine.' }))
add(M('stamina_tonic',  'Stamina Tonic',      300, { stamina = 50, core_stamina = 25 },   { value = 0.5, use = { prop = 'tonic', anim = 'drink' }, description = 'Coca-leaf tonic. Puts spring in the step.' }))
add(M('miracle_tonic',  'Miracle Tonic',      300, { health = 100, stamina = 100, core_health = 100, core_stamina = 100, gold_core_health = 30 }, { value = 5, rarity = 'rare', use = { prop = 'tonic', anim = 'drink' }, description = 'Every core, all at once. Sold by a man who left town quickly.' }))
add(M('snake_oil',      'Snake Oil',          300, { stress = -5 },                       { value = 0.2, use = { prop = 'tonic', anim = 'drink' }, description = "Cures nothing. Sells everywhere." }))
add(M('laudanum',       'Laudanum',           200, { health = 25, stress = -30, stamina = -10 }, { value = 0.6, use = { prop = 'tonic', anim = 'drink' }, tags = { 'opiate', 'addictive' }, description = 'Tincture of opium. A little kills pain; a lot kills you.' }))
add(M('morphine',       'Morphine Vial',      60,  { health = 60, stress = -40, stamina = -20 }, { value = 2, rarity = 'uncommon', use = { prop = 'syringe', anim = 'inject' }, requires = { job = 'medical' }, tags = { 'opiate', 'addictive' }, description = 'Hypodermic morphine. Doctors only.' }))
add(M('chloroform',     'Chloroform',         250, { stamina = -100 },                    { value = 1.5, legal = false, rarity = 'uncommon', use = { anim = 'inspect', time = 3000 }, tags = { 'contraband' }, description = 'A rag and a bottle. Frowned upon outside surgery.' }))
add(M('smelling_salts', 'Smelling Salts',     50,  { stamina = 30 },                      { value = 0.3, use = { anim = 'inspect', time = 1500, whileDead = true }, description = 'Ammonia salts. Brings the fainted round.' }))
add(M('quinine',        'Quinine Pills',      50,  { health = 20 },                       { value = 0.5, stack = 20, use = { anim = 'eat', time = 1500 }, tags = { 'fever' }, description = 'For swamp fever out of Lagras.' }))
add(M('cough_syrup',    'Cough Syrup',        250, { health = 10, stress = -5 },          { value = 0.3, use = { prop = 'tonic', anim = 'drink' }, description = 'Honey, whiskey and something unlabelled.' }))
add(M('iodine',         'Iodine',             100, { health = 8 },                        { value = 0.25, use = { anim = 'heal', time = 2500 }, tags = { 'medic' }, description = 'Antiseptic tincture. Stings.' }))
add(M('castor_oil',     'Castor Oil',         200, { health = 5, hunger = -10 },          { value = 0.15, use = { prop = 'tonic', anim = 'drink' }, description = 'Grandmother swore by it.' }))
add(M('bitters',        'Herbal Bitters',     250, { health = 12, stress = -6, hunger = 4 }, { value = 0.35, use = { prop = 'tonic', anim = 'drink' }, description = 'Gentian and wormwood. Digestif.' }))
add(M('ginseng_elixir', 'Ginseng Elixir',     250, { core_health = 40, core_stamina = 20 }, { value = 1.2, rarity = 'uncommon', use = { prop = 'tonic', anim = 'drink' }, description = 'Brewed from American ginseng. Fortifies the cores.' }))
add(M('poison_antidote','Antidote',           100, { health = 20 },                       { value = 1.0, rarity = 'uncommon', use = { prop = 'tonic', anim = 'drink' }, tags = { 'cure_poison' }, description = 'Clears snakebite and oleander poisoning.' }))
add(I('medical_bag',    'Medical Bag',        2500,{ category = 'kit', value = 15, rarity = 'uncommon', description = 'A physician\'s bag: instruments, dressings, vials. Enables surgery.', tags = { 'medic' } }))
add(I('leeches',        'Jar of Leeches',     300, { category = 'medical', value = 0.3, effects = { health = 5, stress = 5 }, use = { time = 6000 }, description = 'Bloodletting is still practised. Mostly by the old doctor in Strawberry.' }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🌿 HERBS, ROOTS, BERRIES & MUSHROOMS — gathered; herbalism xp on pick
-- ═══════════════════════════════════════════════════════════════════════════════
local function herb(name, label, fx, value, opts)
    opts = opts or {}; opts.category = 'herb'; opts.value = value; opts.effects = fx
    opts.use = opts.use or {}; opts.use.xp = opts.use.xp or { skill = 'herbalism', amount = 1 }
    add(I(name, label, opts.weight or 50, opts))
end
herb('yarrow',            'Yarrow',            { health = 10 },                 0.1,  { description = 'White clusters. Staunches wounds.', tags = { 'medicinal' } })
herb('ginseng_american',  'American Ginseng',  { core_health = 15 },            0.4,  { rarity = 'uncommon', description = 'Forked root, worth its weight to a Saint Denis apothecary.', tags = { 'medicinal' } })
herb('ginseng_alaskan',   'Alaskan Ginseng',   { core_health = 25 },            0.8,  { rarity = 'rare', description = 'Found only in the high country of Ambarino.', tags = { 'medicinal' } })
herb('burdock_root',      'Burdock Root',      { health = 8, hunger = 5 },      0.08, { description = 'Bitter root. Cleanses the blood, they say.', tags = { 'medicinal' } })
herb('sage_common',       'Common Sage',       { stamina = 8 },                 0.06, { description = 'Grey-green leaves. Seasoning and tonic.', tags = { 'seasoning' } })
herb('sage_desert',       'Desert Sage',       { stamina = 10 },                0.08, { description = 'Grows in the New Austin scrub.', tags = { 'seasoning' } })
herb('sage_hummingbird',  'Hummingbird Sage',  { stamina = 12 },                0.12, { rarity = 'uncommon', description = 'Red-flowered, Lemoyne forests.', tags = { 'seasoning' } })
herb('oleander_sage',     'Oleander Sage',     { health = -40 },                0.15, { description = 'Every part is poison. Arrow-makers want it.', tags = { 'poison' }, use = { anim = 'inspect' } })
herb('wild_carrot',       'Wild Carrot',       { hunger = 6 },                  0.03, { description = 'Queen Anne\'s lace root.', tags = { 'horse_treat' } })
herb('indian_tobacco',    'Indian Tobacco',    { stress = -5, stamina = -2 },   0.08, { description = 'Lobelia. Smoked, chewed, or brewed.', tags = { 'medicinal' } })
herb('red_raspberry',     'Red Raspberry',     { hunger = 5, thirst = 4 },      0.04, { description = 'Sweet wild berries.', tags = { 'fruit', 'distilling' } })
herb('blackberry',        'Blackberry',        { hunger = 5, thirst = 4 },      0.04, { description = 'Bramble berries. Purple fingers.', tags = { 'fruit', 'distilling' } })
herb('wintergreen_berry', 'Wintergreen Berry', { stamina = 6, thirst = 3 },     0.05, { description = 'Minty red berries under the snow line.', tags = { 'fruit' } })
herb('huckleberry',       'Evergreen Huckleberry', { hunger = 5, thirst = 4 },  0.05, { description = 'Dark and tart.', tags = { 'fruit', 'distilling' } })
herb('currant_black',     'Black Currant',     { hunger = 4, thirst = 4 },      0.05, { description = 'Tart clusters.', tags = { 'fruit', 'distilling' } })
herb('currant_golden',    'Golden Currant',    { hunger = 4, thirst = 5 },      0.06, { description = 'Yellow, honey-sweet.', tags = { 'fruit' } })
herb('milkweed',          'Milkweed',          { core_stamina = 6 },            0.05, { description = 'Sticky sap, tough fibre.', tags = { 'crafting' } })
herb('vanilla_flower',    'Vanilla Flower',    { stress = -6 },                 0.12, { rarity = 'uncommon', description = 'Orchid of the bayou.', tags = { 'seasoning' } })
herb('violet_snowdrop',   'Violet Snowdrop',   { core_health = 6 },             0.08, { description = 'Blooms through the snow.', tags = { 'medicinal' } })
herb('wild_mint',         'Wild Mint',         { thirst = 6, stress = -4 },     0.04, { description = 'Cool leaves. Tea and juleps.', tags = { 'seasoning' } })
herb('wild_feverfew',     'Wild Feverfew',     { health = 6, stress = -3 },     0.06, { description = 'Daisy-like. For headaches and fevers.', tags = { 'medicinal' } })
herb('english_mace',      'English Mace',      { stamina = 6 },                 0.06, { description = 'Yellow, sweet-smelling.', tags = { 'seasoning' } })
herb('creeping_thyme',    'Creeping Thyme',    { hunger = 2 },                  0.04, { description = 'Ground-hugging herb.', tags = { 'seasoning' } })
herb('oregano',           'Oregano',           { hunger = 2 },                  0.04, { description = 'Mediterranean, gone wild in Lemoyne.', tags = { 'seasoning' } })
herb('prairie_poppy',     'Prairie Poppy',     { stress = -10 },                0.1,  { description = 'Orange bloom of the plains.', tags = { 'medicinal' } })
herb('bitterweed',        'Bitterweed',        { health = 4 },                  0.04, { description = 'Yellow and bitter as its name.', tags = { 'medicinal' } })
herb('harrietum',         'Harrietum Officinalis', { core_health = 20, stress = -15 }, 1.0, { rarity = 'rare', description = 'The naturalist\'s prize. Found in the high east.', tags = { 'medicinal' } })
herb('acuna_orchid',      "Acuna's Star Orchid", { stress = -12 },              1.5,  { rarity = 'rare', description = 'Rare bayou orchid, prized by collectors.', tags = { 'collectible' } })
herb('chanterelle',       'Chanterelles',      { hunger = 8 },                  0.1,  { description = 'Golden trumpet mushrooms.', tags = { 'mushroom' } })
herb('ram_head',          "Ram's Head",        { hunger = 10, core_health = 5 },0.15, { rarity = 'uncommon', description = 'Hen-of-the-woods. Grows on oak.', tags = { 'mushroom' } })
herb('parasol_mushroom',  'Parasol Mushroom',  { hunger = 8 },                  0.1,  { description = 'Tall and edible.', tags = { 'mushroom' } })
herb('bay_bolete',        'Bay Bolete',        { hunger = 9 },                  0.1,  { description = 'Brown cap, blue bruise.', tags = { 'mushroom' } })
add(I('dried_herbs',      'Dried Herbs',       30,  { category = 'herb', value = 0.02, decay = false, useable = false, description = 'Whatever this was, it is potpourri now. Tea makers still take it.', tags = { 'spoiled' } }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🦌 HUNTING — one pelt per animal, quality in info; trophies and by-products
-- ═══════════════════════════════════════════════════════════════════════════════
local function pelt(name, label, w, value, rarity, desc)
    add(I(name, label, w, { category = 'hunting', value = value, rarity = rarity or 'common', description = desc, tags = { 'pelt' }, decay = { hours = 96, into = 'ruined_pelt' } }))
end
add(I('ruined_pelt',   'Ruined Pelt',        1000, { category = 'hunting', value = 0.05, description = 'Left too long. Good for rags.', useable = false }))
pelt('pelt_deer',      'Deer Pelt',          2000, 1.5,  'common',    'Buck or doe hide.')
pelt('pelt_elk',       'Elk Pelt',           4000, 3.0,  'uncommon',  'Thick, heavy elk hide.')
pelt('pelt_moose',     'Moose Pelt',         6000, 5.0,  'rare',      'The largest hide on the continent.')
pelt('pelt_pronghorn', 'Pronghorn Hide',     1500, 1.4,  'common',    'Fast animal, fine hide.')
pelt('pelt_bighorn',   'Bighorn Hide',       2500, 2.5,  'uncommon',  'Mountain sheep.')
pelt('pelt_bison',     'Bison Pelt',         8000, 6.0,  'rare',      'Enormous. There are few bison left.')
pelt('pelt_bear',      'Bear Pelt',          7000, 6.5,  'rare',      'Black or grizzly. A rug for a governor.')
pelt('pelt_cougar',    'Cougar Pelt',        2500, 4.0,  'uncommon',  'Tawny mountain lion hide.')
pelt('pelt_panther',   'Panther Pelt',       2500, 6.0,  'rare',      'Black cat of the Lemoyne swamps.')
pelt('pelt_wolf',      'Wolf Pelt',          2000, 2.0,  'common',    'Grey wolf. The land of them.')
pelt('pelt_coyote',    'Coyote Pelt',        1200, 0.8,  'common',    'Scrappy prairie dog-cousin.')
pelt('pelt_fox',       'Fox Pelt',           800,  1.2,  'common',    'Red, grey or silver.')
pelt('pelt_boar',      'Boar Hide',          3000, 1.8,  'common',    'Bristly wild pig.')
pelt('pelt_beaver',    'Beaver Pelt',        1000, 1.6,  'common',    'Made and unmade the fur trade.')
pelt('pelt_rabbit',    'Rabbit Pelt',        200,  0.3,  'common',    'Soft and small.')
pelt('pelt_raccoon',   'Raccoon Pelt',       600,  0.7,  'common',    'Masked bandit hide. Hats.')
pelt('pelt_badger',    'Badger Pelt',        700,  0.9,  'common',    'Coarse, striped.')
pelt('pelt_muskrat',   'Muskrat Pelt',       300,  0.5,  'common',    'Marsh rodent.')
pelt('pelt_skunk',     'Skunk Pelt',         400,  0.5,  'common',    'Striped and, unfortunately, aromatic.')
pelt('pelt_opossum',   'Opossum Pelt',       400,  0.4,  'common',    'Grey and greasy.')
pelt('pelt_squirrel',  'Squirrel Pelt',      100,  0.15, 'common',    'Tiny.')
pelt('pelt_goat',      'Goat Hide',          1500, 1.0,  'common',    'From a farm goat.')
pelt('hide_cow',       'Cow Hide',           5000, 2.5,  'common',    'Steer hide for saddles and boots.')
pelt('hide_gator',     'Alligator Skin',     4000, 4.5,  'uncommon',  'Bayou leather. Saint Denis boot-makers pay well.')
pelt('hide_snake',     'Snake Skin',         200,  0.6,  'common',    'Patterned skin, hatbands.')
pelt('pelt_sheep',     'Sheep Fleece',       2000, 1.0,  'common',    'Wool on the hide.')

local function trophy(name, label, w, value, rarity, desc, tags)
    add(I(name, label, w, { category = 'hunting', value = value, rarity = rarity or 'common', quality = false, description = desc, tags = tags or { 'trophy' } }))
end
trophy('antlers',          'Antlers',              1500, 1.0, 'common',   'A rack of deer antlers.')
trophy('antlers_elk',      'Elk Antlers',          3000, 2.5, 'uncommon', 'Six points, maybe more.')
trophy('antlers_moose',    'Moose Antlers',        6000, 5.0, 'rare',     'Palmate and enormous.')
trophy('horn_bighorn',     'Bighorn Horn',         2000, 2.0, 'uncommon', 'Curled ram horn.')
trophy('horn_bison',       'Bison Horn',           1000, 1.5, 'uncommon', 'Black and polished.')
trophy('tooth_bear',       'Bear Tooth',           50,   1.0, 'uncommon', 'A canine the length of a finger.', { 'trophy', 'talisman' })
trophy('claw_bear',        'Bear Claw',            60,   1.2, 'uncommon', 'For necklaces and bragging.', { 'trophy', 'talisman' })
trophy('fang_cougar',      'Cougar Fang',          30,   1.5, 'uncommon', 'Long and curved.', { 'trophy', 'talisman' })
trophy('tooth_gator',      'Alligator Tooth',      40,   0.8, 'common',   'Bayou souvenir.', { 'trophy', 'talisman' })
trophy('tail_beaver',      'Beaver Tail',          300,  0.5, 'common',   'Flat and scaly. Some cook it.')
trophy('feather_eagle',    'Eagle Feather',        5,    2.0, 'rare',     'Illegal to sell, valued by everyone.', { 'trophy', 'feather' })
trophy('feather_hawk',     'Hawk Feather',         5,    0.8, 'uncommon', 'Barred brown feather.', { 'trophy', 'feather' })
trophy('feather_owl',      'Owl Feather',          5,    0.8, 'uncommon', 'Soft-edged, silent.', { 'trophy', 'feather' })
trophy('feather_turkey',   'Turkey Feather',       5,    0.1, 'common',   'Bronze tail feather. Arrow fletching.', { 'feather', 'crafting' })
trophy('feather_crow',     'Crow Feather',         5,    0.05,'common',   'Black and glossy.', { 'feather', 'crafting' })
trophy('feather_heron',    'Heron Plume',          5,    1.5, 'rare',     'Ladies\' hats in Saint Denis are the ruin of herons.', { 'feather' })
trophy('feather_egret',    'Egret Plume',          5,    1.8, 'rare',     'The most fashionable feather in the country.', { 'feather' })
trophy('feather_spoonbill','Spoonbill Plume',      5,    2.2, 'rare',     'Pink and precious.', { 'feather' })
add(I('animal_fat',    'Animal Fat',          300, { category = 'material', value = 0.05, stack = 20, description = 'Rendered for candles, soap and pemmican.', tags = { 'crafting' } }))
add(I('bone',          'Bones',               300, { category = 'material', value = 0.02, stack = 30, description = 'Buttons, handles, glue and broth.', tags = { 'crafting' } }))
add(I('sinew',         'Sinew',               50,  { category = 'material', value = 0.08, stack = 30, description = 'Dried tendon. Bow strings and bindings.', tags = { 'crafting' } }))
add(I('gut_string',    'Gut String',          30,  { category = 'material', value = 0.1, stack = 30, description = 'Twisted intestine. Fiddles and sutures.', tags = { 'crafting' } }))
add(I('carcass_small', 'Small Carcass',       2000,{ category = 'hunting', value = 0.4, stack = 3, description = 'Rabbit, squirrel or bird — whole. Butchers pay more for the whole animal.' }))
add(I('carcass_medium','Medium Carcass',      8000,{ category = 'hunting', value = 1.2, stack = 1, unique = true, description = 'Fox, coyote, beaver. Carried over a shoulder or on a horse.' }))
add(I('carcass_bird',  'Bird Carcass',        1500,{ category = 'hunting', value = 0.5, stack = 3, description = 'Duck, goose, turkey or pheasant, undressed.' }))
add(I('hunting_license', 'Hunting License',   20,  { category = 'document', value = 2, description = 'State hunting permit, valid one season. Wardens ask.', tags = { 'license' } }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- ⛏️ MATERIALS & COMPONENTS — mining, forestry, smithing, tanning, distilling
-- ═══════════════════════════════════════════════════════════════════════════════
local function mat(name, label, w, value, desc, opts)
    opts = opts or {}; opts.category = opts.category or 'material'; opts.value = value; opts.description = desc
    add(I(name, label, w, opts))
end
mat('wood',          'Firewood',          1000, 0.03, 'Split logs.', { tags = { 'fuel' } })
mat('wood_plank',    'Plank',             1500, 0.1,  'Sawn pine board.', { tags = { 'building' } })
mat('log',           'Log',               8000, 0.2,  'A felled trunk section. Needs a saw or a sawmill.', { stack = 5 })
mat('charcoal',      'Charcoal',          400,  0.04, 'Burned wood. Forges and gunpowder.', { tags = { 'fuel', 'gunpowder' } })
mat('coal',          'Coal',              800,  0.05, 'Annesburg coal.', { tags = { 'fuel' } })
mat('stone',         'Stone',             1500, 0.02, 'Quarried rock.', { tags = { 'building' } })
mat('clay',          'Clay',              800,  0.03, 'River clay. Bricks and pots.', { tags = { 'building' } })
mat('sand',          'Sand',              800,  0.01, 'For mortar and glass.', { tags = { 'building' } })
mat('iron_ore',      'Iron Ore',          1200, 0.15, 'Red-brown ore.', { tags = { 'ore' } })
mat('iron_bar',      'Iron Bar',          1000, 0.6,  'Smelted iron. Tools, horseshoes, nails.', { tags = { 'ingot' } })
mat('steel_bar',     'Steel Bar',         1000, 1.5,  'Carbon steel. Blades and gun parts.', { rarity = 'uncommon', tags = { 'ingot' } })
mat('copper_ore',    'Copper Ore',        1200, 0.2,  'Green-streaked ore.', { tags = { 'ore' } })
mat('copper_bar',    'Copper Bar',        1000, 0.8,  'Smelted copper. Stills and casings.', { tags = { 'ingot' } })
mat('silver_ore',    'Silver Ore',        1200, 0.8,  'Galena with silver.', { rarity = 'uncommon', tags = { 'ore' } })
mat('gold_ore',      'Gold Ore',          1200, 2.5,  'Quartz veined with gold.', { rarity = 'uncommon', tags = { 'ore' } })
mat('lead_ore',      'Lead Ore',          1200, 0.15, 'Heavy grey ore.', { tags = { 'ore' } })
mat('lead_bar',      'Lead Bar',          1000, 0.5,  'Soft lead. Bullets.', { tags = { 'ingot', 'ammo_craft' } })
mat('tin_bar',       'Tin Bar',           1000, 0.6,  'For cans and solder.', { tags = { 'ingot' } })
mat('sulfur',        'Sulfur',            300,  0.2,  'Yellow brimstone. Gunpowder and matches.', { tags = { 'gunpowder' } })
mat('saltpeter',     'Saltpeter',         300,  0.25, 'Potassium nitrate, scraped from cave floors.', { tags = { 'gunpowder' } })
mat('gunpowder',     'Gunpowder',         200,  0.5,  'Black powder. Keep dry, keep away from cigars.', { category = 'component', tags = { 'ammo_craft', 'explosive' } })
mat('brass_casing',  'Brass Casings',     100,  0.01,  'Empty cartridge brass.', { category = 'component', stack = 100, tags = { 'ammo_craft' } })
mat('primer',        'Primers',           20,   0.01,  'Percussion caps for reloading.', { category = 'component', stack = 100, tags = { 'ammo_craft' } })
mat('bullet_mold',   'Bullet Mould',      600,  2.0,  'Cast-iron mould for casting lead.', { category = 'tool', quality = true })
mat('blasting_cap',  'Blasting Cap',      20,   0.4,  'Detonator. Miners and outlaws.', { category = 'component', stack = 50, tags = { 'explosive' } })
mat('fuse',          'Fuse Cord',         100,  0.1,  'Slow-burning cord, by the yard.', { category = 'component', stack = 50, tags = { 'explosive' } })
mat('leather',       'Leather',           600,  0.5,  'Tanned hide.', { tags = { 'crafting' } })
mat('leather_fine',  'Fine Leather',      600,  1.5,  'Tanned from a perfect hide.', { rarity = 'uncommon', tags = { 'crafting' } })
mat('leather_strip', 'Leather Strips',    100,  0.1,  'Cut for straps and lacing.', { stack = 100, tags = { 'crafting' } })
mat('rawhide',       'Rawhide',           800,  0.3,  'Untanned, stiff as board.', { tags = { 'crafting' } })
mat('cloth',         'Cloth',             300,  0.2,  'Bolt of cotton.', { tags = { 'crafting' } })
mat('wool',          'Wool',              300,  0.25, 'Carded fleece.', { tags = { 'crafting' } })
mat('linen',         'Linen',             300,  0.4,  'Fine flax cloth. Bandages and shirts.', { tags = { 'crafting' } })
mat('thread',        'Thread',            20,   0.05, 'Spool of cotton thread.', { stack = 100, tags = { 'crafting' } })
mat('twine',         'Twine',             100,  0.05, 'Hemp string.', { stack = 100, tags = { 'crafting' } })
mat('rope',          'Rope',              800,  0.3,  'Fifty feet of hemp rope.', { stack = 10, tags = { 'crafting' } })
mat('canvas',        'Canvas',            800,  0.6,  'Heavy sailcloth. Tents and wagon covers.', { tags = { 'crafting' } })
mat('nails',         'Nails',             200,  0.1,  'A pound of cut nails.', { stack = 100, tags = { 'building' } })
mat('glass_bottle',  'Empty Bottle',      200,  0.02, 'Reusable glass bottle.', { stack = 20, tags = { 'crafting', 'distilling' } })
mat('glass_jar',     'Mason Jar',         250,  0.03, 'Screw-top jar. Moonshine and preserves.', { stack = 20, tags = { 'crafting', 'distilling' } })
mat('tin_can',       'Empty Tin',         80,   0.01, 'Rinse before use.', { stack = 30 })
mat('tallow',        'Tallow',            300,  0.05, 'Rendered fat, set hard.', { tags = { 'crafting' } })
mat('beeswax',       'Beeswax',           200,  0.2,  'From a wild hive.', { tags = { 'crafting' } })
mat('lamp_oil',      'Lamp Oil',          500,  0.15, 'Kerosene for lanterns.', { tags = { 'fuel' } })
mat('gun_oil',       'Gun Oil',           150,  0.25, 'Keeps the action clean.', { category = 'tool', quality = true, useable = true, use = { anim = 'craft', time = 5000 }, tags = { 'weapon_care' } })
mat('tar',           'Pitch',             500,  0.1,  'Pine tar for boats and torches.', { tags = { 'crafting' } })
mat('paper',         'Paper',             20,   0.02, 'Writing paper.', { stack = 100, tags = { 'crafting' } })
mat('ink',           'Ink',               100,  0.1,  'Bottle of iron-gall ink.', { stack = 10 })
mat('corn_mash',     'Corn Mash',         1500, 0.3,  'Fermenting corn and sugar. Stage one of moonshine.', { legal = false, decay = { hours = 72, into = 'spoiled_food' }, tags = { 'distilling', 'contraband' } })
mat('sugar_beet',    'Sugar Beet',        400,  0.03, 'Grown in Lemoyne fields.', { tags = { 'vegetable', 'distilling' } })
mat('hops',          'Hops',              100,  0.1,  'Bitter cones for beer.', { tags = { 'distilling' } })
mat('barley',        'Barley',            1000, 0.05, 'Malting barley.', { tags = { 'distilling' } })
mat('hay_bale',      'Hay Bale',          8000, 0.2,  'For stables.', { stack = 5, tags = { 'horse_feed' } })
mat('oats_sack',     'Sack of Oats',      5000, 0.3,  'Horse feed by the sack.', { stack = 5, tags = { 'horse_feed' } })
-- seed packets: what lxr-farming plants (0.01–0.03 a packet in 1899; the crop is worth more than the seed)
mat('seed_corn',     'Corn Seed',         100,  0.02, 'A paper packet of seed corn.', { stack = 50, tags = { 'seed' } })
mat('seed_potato',   'Seed Potatoes',     400,  0.02, 'Sprouted eyes, ready to cut and plant.', { stack = 50, tags = { 'seed' } })
mat('seed_carrot',   'Carrot Seed',       50,   0.01, 'Tiny seed in a paper packet.', { stack = 50, tags = { 'seed' } })
mat('seed_tomato',   'Tomato Seed',       50,   0.02, 'Saved from the best fruit of last year.', { stack = 50, tags = { 'seed' } })
mat('seed_tobacco',  'Tobacco Seed',      50,   0.03, 'Virginia leaf. Needs a long summer.', { stack = 50, tags = { 'seed' } })
mat('seed_sugar_beet', 'Sugar Beet Seed', 100,  0.02, 'Lemoyne beet seed.', { stack = 50, tags = { 'seed' } })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 TOOLS — graded (durability) and mostly unique
-- ═══════════════════════════════════════════════════════════════════════════════
local function tool(name, label, w, value, desc, opts)
    opts = opts or {}; opts.category = opts.category or 'tool'; opts.value = value; opts.description = desc
    add(I(name, label, w, opts))
end
tool('lantern',        'Lantern',            700,  1.2,  'Kerosene lantern. Hangs on the belt or the saddle.', { tags = { 'light' } })
tool('torch',          'Torch',              500,  0.1,  'Pitch-soaked rag on a stick. Burns an hour.', { unique = false, stack = 5, quality = false, tags = { 'light' } })
tool('candle',         'Candle',             80,   0.03, 'Tallow candle.', { unique = false, stack = 20, quality = false, tags = { 'light' } })
tool('matches',        'Box of Matches',     30,   0.02, 'Strike-anywhere matches.', { unique = false, stack = 20, quality = false, tags = { 'fire' } })
tool('flint_steel',    'Flint and Steel',    150,  0.3,  'Never runs out, always frustrating.', { tags = { 'fire' } })
tool('lockpick',       'Lockpick',           50,   0.5,  'Bent wire and patience. Breaks.', { unique = false, stack = 10, legal = false, tags = { 'contraband' } })
tool('lockpick_fine',  'Locksmith\'s Picks', 150,  3.0,  'A proper set in a leather roll.', { rarity = 'uncommon', legal = false, tags = { 'contraband' } })
tool('pickaxe',        'Pickaxe',            2500, 1.5,  'Miner\'s pick.', { tags = { 'mining' } })
tool('shovel',         'Shovel',             2000, 0.8,  'Digs graves, ditches and treasure.', {})
tool('hoe',            'Hoe',                1800, 0.6,  'Breaks ground for planting.', { tags = { 'farming' } })
tool('gold_pan',       'Gold Pan',           600,  0.5,  'Tin pan for the gravel bars. Patience sold separately.', { tags = { 'mining' } })
tool('axe',            'Felling Axe',        2500, 1.5,  'Double-bit felling axe.', { tags = { 'forestry' } })
tool('saw',            'Bucksaw',            1500, 1.2,  'Crosscut saw for planks.', { tags = { 'forestry' } })
tool('hammer',         'Hammer',             800,  0.5,  'Claw hammer.', { tags = { 'building' } })
tool('hammer_smith',   'Smith\'s Hammer',    1500, 1.5,  'Cross-peen forge hammer.', { tags = { 'smithing' } })
tool('tongs',          'Tongs',              800,  0.6,  'Forge tongs.', { tags = { 'smithing' } })
tool('chisel',         'Chisel',             300,  0.4,  'Cold chisel.', { tags = { 'smithing' } })
tool('whetstone',      'Whetstone',          300,  0.3,  'Sharpens knives, axes and tempers.', { unique = false, stack = 5, tags = { 'weapon_care' } })
tool('cleaning_kit',   'Gun Cleaning Kit',   600,  1.0,  'Rod, brushes, patches and oil. Restores weapon condition.', { tags = { 'weapon_care' }, use = { anim = 'craft', time = 6000 } })
tool('sewing_kit',     'Sewing Kit',         200,  0.5,  'Needles, thread, thimble.', { tags = { 'tailoring' } })
tool('handcuffs',      'Handcuffs',          400,  1.75, 'Iron nippers with a key. Bean pattern.', { unique = false, stack = 2, tags = { 'law' } })
tool('skinning_knife', 'Skinning Knife',     300,  1.0,  'Curved blade for hides. Not a weapon, technically.', { tags = { 'hunting' } })
tool('binoculars',     'Binoculars',         500,  3.0,  'Field glasses.', {})
tool('spyglass',       'Spyglass',           400,  2.5,  'Brass telescope.', {})
tool('camera',         'Camera',             1500, 12.0, 'Folding Kodak. Takes photographs.', { rarity = 'uncommon', era = 1888 })
tool('compass',        'Compass',            100,  1.0,  'Brass compass.', {})
tool('map_region',     'Territory Map',      50,   0.5,  'Folded survey map of the five states.', { quality = false, category = 'document', unique = false })
tool('pocket_watch',   'Pocket Watch',       100,  4.0,  'Keeps decent time.', { category = 'personal' })
tool('pocket_watch_gold', 'Gold Pocket Watch', 120, 25.0, 'Engraved. Someone will miss it.', { category = 'valuable', rarity = 'rare', useable = false, legal = true })
tool('whistle',        'Whistle',            30,   0.2,  'Tin whistle. Horses, dogs and lawmen answer.', {})
tool('bucket',         'Bucket',             1200, 0.3,  'Wooden pail.', {})
tool('cooking_pot',    'Cooking Pot',        1500, 0.8,  'Cast-iron pot. Stews.', { tags = { 'cooking' } })
tool('skillet',        'Skillet',            1200, 0.6,  'Cast-iron pan. Steaks and bacon.', { tags = { 'cooking' } })
tool('kettle',         'Kettle',             800,  0.5,  'For tea, broth and coffee.', { tags = { 'cooking' } })
tool('coffee_pot',     'Coffee Pot',         700,  0.5,  'Enamel percolator.', { tags = { 'cooking' } })
tool('mortar_pestle',  'Mortar and Pestle',  1000, 0.8,  'Grinds herbs to powder.', { tags = { 'herbalism' } })
tool('still_kit',      'Copper Still',       12000,25.0, 'Boiler, coil and thump keg. Illegal without a licence nobody has.', { legal = false, rarity = 'uncommon', category = 'kit', tags = { 'distilling', 'contraband' } })
tool('gold_pan',       'Gold Pan',           600,  0.8,  'Tin pan for placer gold.', { tags = { 'mining' } })
tool('gold_scale',     'Assayer\'s Scale',   800,  4.0,  'Brass balance for weighing gold.', { tags = { 'mining' } })
tool('bear_trap',      'Bear Trap',          4000, 3.0,  'Iron jaws. Legal, mostly.', { unique = false, stack = 3, tags = { 'hunting' } })
tool('snare',          'Snare',              200,  0.2,  'Wire loop for rabbits.', { unique = false, stack = 10, quality = false, tags = { 'hunting' } })
tool('toolbox',        'Toolbox',            5000, 4.0,  'Wrenches, files, spare bolts. Repairs wagons.', { category = 'kit', tags = { 'wagon' } })
tool('wagon_repair_kit','Wagon Repair Kit',  3000, 2.0,  'Axle grease, spokes, a strap or two.', { unique = false, stack = 3, quality = false, category = 'wagon' })
tool('wagon_wheel',    'Wagon Wheel',        15000,3.5,  'Spoked oak wheel with iron tyre.', { unique = false, stack = 2, quality = false, category = 'wagon' })
tool('journal',        'Journal',            300,  0.8,  'Leather-bound. Your own words in it.', { category = 'personal', use = { anim = 'read' } })
tool('pencil',         'Pencil',             10,   0.02, 'Graphite pencil.', { unique = false, stack = 10, quality = false })
tool('blindfold',      'Blindfold',          60,   0.15, 'A strip of dark cloth. Ties behind the head.', { category = 'personal', unique = false, stack = 5, tags = { 'restraint' } })
tool('playing_cards',  'Deck of Cards',      100,  0.2,  'Fifty-two, if nobody has palmed one.', { category = 'personal' })
tool('dice',           'Dice',               20,   0.1,  'Bone dice. Loaded? Who can say.', { category = 'personal' })
tool('dominoes',       'Dominoes',           400,  0.5,  'A full set in a wooden box.', { category = 'personal' })
tool('harmonica',      'Harmonica',          80,   0.8,  'Hohner mouth organ.', { category = 'personal', tags = { 'instrument' } })
tool('banjo',          'Banjo',              2000, 6.0,  'Five-string.', { category = 'personal', tags = { 'instrument' } })
tool('fiddle',         'Fiddle',             1200, 8.0,  'A country violin.', { category = 'personal', tags = { 'instrument' } })
tool('guitar',         'Guitar',             2500, 7.0,  'Six-string parlour guitar.', { category = 'personal', tags = { 'instrument' } })
tool('pipe',           'Smoking Pipe',       80,   0.5,  'Briar pipe.', { category = 'personal' })
tool('flask',          'Hip Flask',          200,  1.0,  'Holds four drams (info.charges).', { category = 'personal', tags = { 'refillable' } })
tool('umbrella',       'Umbrella',           600,  1.0,  'Black silk. Saint Denis weather.', { category = 'personal' })
tool('bedroll',        'Bedroll',            2500, 1.5,  'Wool blanket and canvas. Sleep anywhere.', { category = 'camp' })
tool('tent',           'Tent',               9000, 6.0,  'Canvas wall tent for two.', { category = 'camp' })
tool('campfire_kit',   'Campfire Kit',       1500, 0.5,  'Kindling, stones and a tripod.', { category = 'camp', unique = false, stack = 3 })
tool('camp_stove',     'Camp Stove',         6000, 4.0,  'Sheet-iron stove with a pipe.', { category = 'camp' })
tool('camp_chair',     'Folding Chair',      3000, 1.0,  'Canvas and oak.', { category = 'camp' })
tool('camp_table',     'Folding Table',      5000, 1.5,  'For maps and card games.', { category = 'camp' })
tool('lockbox',        'Lockbox',            4000, 5.0,  'Iron strongbox. Opens with its own key (info.id).', { category = 'kit' })
tool('safe_kit',       'Iron Safe',          45000, 32.0, 'A hundred pounds of iron with a dial. Stands where you put it.', { category = 'kit', tags = { 'placeable' } })
tool('satchel_upgrade','Satchel Upgrade',    500,  8.0,  'Sturdier stitching, more pockets. +10 slots.', { category = 'kit', unique = false, stack = 1, quality = false })
tool('saddlebag_upgrade','Saddlebag Upgrade',1500, 12.0, 'Deeper saddlebags. +weight on the horse.', { category = 'kit', unique = false, stack = 1, quality = false })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎣 FISHING
-- ═══════════════════════════════════════════════════════════════════════════════
tool('fishingrod',      'Fishing Rod',        900,  2.0,  'Split-cane rod and reel.', { category = 'tool', tags = { 'fishing' } })
add(I('bait_worm',      'Worms',              50,  { category = 'fishing', value = 0.02, stack = 50, description = 'Dug from a wet bank. Panfish.', tags = { 'bait' } }))
add(I('bait_cricket',   'Crickets',           30,  { category = 'fishing', value = 0.03, stack = 50, description = 'Chirping in a tin. Bass and trout.', tags = { 'bait' } }))
add(I('bait_cheese',    'Cheese Bait',        50,  { category = 'fishing', value = 0.03, stack = 50, description = 'Catfish cannot resist it.', tags = { 'bait' } }))
add(I('bait_bread',     'Bread Bait',         30,  { category = 'fishing', value = 0.01, stack = 50, description = 'Rolled crumb. Bluegill and perch.', tags = { 'bait' } }))
add(I('lure_river',     'River Lure',         30,  { category = 'fishing', value = 0.6, stack = 5, quality = true, description = 'Spinner for moving water.', tags = { 'lure', 'river' } }))
add(I('lure_lake',      'Lake Lure',          30,  { category = 'fishing', value = 0.6, stack = 5, quality = true, description = 'Plug for still water.', tags = { 'lure', 'lake' } }))
add(I('lure_swamp',     'Swamp Lure',         30,  { category = 'fishing', value = 0.6, stack = 5, quality = true, description = 'Weedless spoon for the bayou.', tags = { 'lure', 'swamp' } }))
add(I('lure_special',   'Special Lure',       30,  { category = 'fishing', value = 3.0, stack = 1, rarity = 'rare', quality = true, description = 'Hand-tied. The big ones notice.', tags = { 'lure' } }))
add(I('fishing_license','Fishing License',    20,  { category = 'document', value = 1, description = 'State fishing permit.', tags = { 'license' } }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐴 HORSE CARE & TACK
-- ═══════════════════════════════════════════════════════════════════════════════
local function horsecare(name, label, w, fx, value, desc, opts)
    opts = opts or {}; opts.category = 'horse'; opts.value = value; opts.description = desc; opts.effects = fx
    add(I(name, label, w, opts))
end
horsecare('hay',           'Hay',              1000, { horse_hunger = 25, horse_bond = 1 },  0.05, 'An armful of dry hay.', { use = { prop = 'hay' } })
horsecare('oats',          'Oats',             500,  { horse_hunger = 35, horse_stamina = 10, horse_bond = 2 }, 0.1, 'Rolled oats in a nosebag.')
horsecare('sugar_cube',    'Sugar Cubes',      20,   { horse_hunger = 5, horse_bond = 4 },   0.02, 'A treat. Bonding.', { stack = 50 })
horsecare('horse_tonic',   'Horse Stimulant',  300,  { horse_stamina = 60, horse_core_stamina = 30 }, 0.8, 'For a hard ride.', { use = { anim = 'drink', prop = 'tonic' } })
horsecare('horse_meds',    'Horse Medicine',   300,  { horse_health = 60, horse_core_health = 30 }, 0.8, 'Veterinary tonic.', { use = { anim = 'drink', prop = 'tonic' } })
horsecare('horse_reviver', 'Horse Reviver',    300,  { horse_revive = 1 }, 3.0, 'Brings a downed horse back to its feet. Once.', { rarity = 'uncommon', use = { anim = 'inject', prop = 'syringe' } })
horsecare('horse_brush',   'Horse Brush',      200,  { horse_clean = 100, horse_bond = 3 }, 0.4, 'Curry comb and dandy brush.', { category = 'tool', use = { anim = 'brush_horse', prop = 'brush', time = 8000, consume = false } })
horsecare('hoof_pick',     'Hoof Pick',        100,  { horse_health = 5, horse_bond = 1 },  0.2,  'Cleans stones from hooves.', { category = 'tool', use = { anim = 'brush_horse', time = 5000, consume = false } })
horsecare('horseshoe',     'Horseshoes',       800,  { horse_health = 10 },                 0.5,  'Set of four. Farriers fit them.', { stack = 8, use = { anim = 'craft', time = 6000 } })
local function tack(name, label, w, value, slot, stats, desc, rarity)
    add(I(name, label, w, { category = 'tack', value = value, rarity = rarity or 'common', description = desc, tags = { 'tack', slot }, tack = { slot = slot, stats = stats } }))
end
tack('saddle_basic',     'Worn Saddle',          6000, 8,   'saddle',   { stamina = 0, health = 0, speed = 0 },     'A rancher\'s hand-me-down. It works.')
tack('saddle_leather',   'Leather Saddle',       6500, 18,  'saddle',   { stamina = 2, health = 2 },                'Plain, well-made.')
tack('saddle_western',   'Western Saddle',       7000, 35,  'saddle',   { stamina = 4, health = 3, speed = 1 },     'Tooled leather, deep seat.', 'uncommon')
tack('saddle_mcclellan', 'McClellan Saddle',     5500, 30,  'saddle',   { stamina = 5, health = 1, speed = 2 },     'Army pattern. Light, hard.', 'uncommon')
tack('saddle_ornate',    'Ornate Saddle',        7500, 120, 'saddle',   { stamina = 6, health = 5, speed = 2 },     'Silver conchos, hand-stitched. A statement.', 'rare')
tack('saddlebag_small',  'Small Saddlebags',     1500, 5,   'saddlebag',{ storage = 10 },                           'Two leather pouches.')
tack('saddlebag_large',  'Large Saddlebags',     2500, 15,  'saddlebag',{ storage = 25 },                           'Deep double bags.', 'uncommon')
tack('stirrups_basic',   'Iron Stirrups',        1200, 3,   'stirrups', { stamina = 1 },                            'Plain iron.')
tack('stirrups_fine',    'Brass Stirrups',       1200, 10,  'stirrups', { stamina = 3, speed = 1 },                 'Polished brass.', 'uncommon')
tack('blanket_horse',    'Saddle Blanket',       1500, 2,   'blanket',  { health = 1 },                             'Wool pad under the saddle.')
tack('blanket_navajo',   'Navajo Blanket',       1500, 12,  'blanket',  { health = 3 },                             'Woven pattern, thick and warm.', 'uncommon')
tack('bridle_basic',     'Bridle',               800,  3,   'bridle',   { handling = 1 },                           'Leather bridle and bit.')
tack('bridle_fine',      'Fine Bridle',          800,  12,  'bridle',   { handling = 3 },                           'Braided reins, silver bit.', 'uncommon')
tack('horse_lantern',    'Saddle Lantern',       700,  2,   'lantern',  {},                                         'Hooks on the saddle horn.')
tack('horse_bedroll',    'Saddle Bedroll',       2500, 2,   'bedroll',  {},                                         'Rolled behind the cantle.')
add(I('horse_deed',      'Horse Ownership Papers', 20, { category = 'document', value = 0, description = 'Bill of sale and brand registration for one horse (info.horseId).', tags = { 'deed' } }))
add(I('horse_brand',     'Branding Iron',      1500,{ category = 'tool', value = 4, description = 'Your mark, in iron.', tags = { 'ranch' } }))
add(I('lasso',           'Lasso',              700, { category = 'tool', value = 1.5, description = 'Forty feet of braided rawhide.', tags = { 'ranch' } }))
add(I('lasso_reinforced','Reinforced Lasso',   900, { category = 'tool', value = 4.0, rarity = 'uncommon', description = 'Wire-cored. Holds a bull.', tags = { 'ranch' } }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📜 DOCUMENTS & KEYS — unique, carry their data in info
-- ═══════════════════════════════════════════════════════════════════════════════
local function doc(name, label, value, desc, opts)
    opts = opts or {}; opts.category = 'document'; opts.value = value; opts.description = desc
    add(I(name, label, opts.weight or 20, opts))
end
doc('id_card',            'Identification Papers', 0,   'Name, birth date and a photograph, if you could afford one.', { droppable = false, use = { whileDead = true } })
doc('birth_certificate',  'Birth Certificate',   0,   'Registered with the county.')
doc('marriage_certificate','Marriage Certificate', 0,  'Witnessed and signed.')
doc('land_deed',          'Land Deed',           0,   'Title to a parcel of land (info.propertyId).', { tags = { 'deed' } })
doc('property_deed',      'Property Deed',       0,   'Title to a house or business (info.propertyId).', { tags = { 'deed' } })
doc('wagon_deed',         'Wagon Registration',  0,   'Ownership of a wagon (info.wagonId).', { tags = { 'deed' } })
doc('business_license',   'Business License',    5,   'Permit to trade in a town (info.town).', { tags = { 'license' } })
doc('mining_claim',       'Mining Claim',        10,  'Registered claim to a stretch of ground (info.claimId).', { tags = { 'deed' } })
doc('telegram',           'Telegram',            0,   'STOP. Read it. STOP.')
doc('letter',             'Letter',              0,   'A folded letter.', { unique = false, stack = 10 })
doc('letter_sealed',      'Sealed Letter',       0,   'Wax seal unbroken. Someone is trusting the mail.', { unique = false, stack = 10 })
doc('envelope',           'Envelope',            0.01,'Blank envelope.', { unique = false, stack = 20, useable = false })
doc('stamp',              'Postage Stamp',       0.02,'Two-cent Washington.', { unique = false, stack = 50, useable = false })
doc('wanted_poster',      'Wanted Poster',       0,   'Dead or alive (info.target, info.reward).', { tags = { 'bounty' } })
doc('bounty_warrant',     'Bounty Warrant',      0,   'Signed by a judge. Makes it legal (info.target).', { tags = { 'bounty' } })
doc('arrest_warrant',     'Arrest Warrant',      0,   'For a lawman to serve.', { tags = { 'law' } })
doc('search_warrant',     'Search Warrant',      0,   'Permits a lawman to search a property.', { tags = { 'law' } })
doc('pardon',             'Governor\'s Pardon',  0,   'Clears a record. Rare as honest politicians.', { rarity = 'legendary' })
doc('train_ticket',       'Train Ticket',        0.5, 'One seat, one direction (info.to).', { unique = false, stack = 10 })
doc('stagecoach_ticket',  'Stagecoach Ticket',   0.3, 'A place on the next coach (info.to).', { unique = false, stack = 10 })
doc('ferry_ticket',       'Ferry Ticket',        0.1, 'Across the river.', { unique = false, stack = 10 })
doc('bank_book',          'Bank Passbook',       0,   'Your ledger with the bank (info.account).', { droppable = false })
doc('cheque',             'Cheque',              0,   'Drawn on a named bank (info.amount, info.bank). Cash it there.', { unique = false, stack = 10 })
doc('iou',                'I.O.U.',              0,   'A promise, and a name.', { unique = false, stack = 10 })
doc('newspaper',          'Newspaper',           0.02,'The Saint Denis Times, or whatever is local.', { unique = false, stack = 5, effects = { stress = -2 } })
doc('treasure_map',       'Treasure Map',        0,   'X marks something (info.step).', { rarity = 'rare' })
doc('contract',           'Contract',            0,   'Terms, signatures, witnesses (info.terms).')
doc('will',               'Last Will and Testament', 0, 'Who gets the horse.')
doc('prescription',       'Prescription',        0,   'A doctor\'s note for the apothecary (info.item).')
doc('bill_of_sale',       'Bill of Sale',        0,   'Proof you bought it, honest.', { unique = false, stack = 10 })
doc('photograph',         'Photograph',          0,   'A moment, fixed in silver.', { category = 'personal', effects = { stress = -5 } })
doc('book',               'Book',                0.5, 'A novel or a treatise (info.title).', { use = { anim = 'read', prop = 'book', time = 6000 }, effects = { stress = -8 } })
doc('bible',              'Bible',               0.5, 'King James.', { use = { anim = 'read', prop = 'book', time = 6000 }, effects = { stress = -10 } })
doc('sheet_music',        'Sheet Music',         0.1, 'A tune for the fiddle (info.song).', { unique = false, stack = 10 })
local function key(name, label, desc) add(I(name, label, 20, { category = 'key', value = 0, description = desc })) end
key('key_house',    'House Key',    'Opens a door somewhere (info.id).')
key('key_wagon',    'Wagon Key',    'For the lock on a wagon strongbox (info.wagonId).')
key('key_lockbox',  'Lockbox Key',  'Matches one lockbox (info.id).')
key('key_cell',     'Cell Key',     'Sheriff\'s office cell key (info.town).')
key('key_ring',     'Key Ring',     'Holds several keys (info.keys).')
key('key_safe',     'Safe Key',     'Bank or business safe (info.id).')

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💍 VALUABLES, COLLECTIBLES & CONTRABAND — fence economy
-- ═══════════════════════════════════════════════════════════════════════════════
local function valuable(name, label, w, value, rarity, desc, legal)
    add(I(name, label, w, { category = 'valuable', value = value, rarity = rarity, description = desc, legal = legal == true, tags = { 'fence' } }))
end
valuable('ring_gold',        'Gold Ring',          10,  6,   'uncommon', 'Plain gold band.', true)
valuable('ring_silver',      'Silver Ring',        10,  2,   'common',   'Silver band.', true)
valuable('ring_wedding',     'Wedding Ring',       10,  8,   'uncommon', 'Engraved inside. Somebody\'s.', false)
valuable('necklace_pearl',   'Pearl Necklace',     50,  25,  'rare',     'A string of real pearls.', false)
valuable('necklace_gold',    'Gold Necklace',      40,  12,  'uncommon', 'Fine chain.', false)
valuable('locket',           'Locket',             20,  5,   'uncommon', 'Opens on a tiny portrait.', false)
valuable('brooch',           'Cameo Brooch',       20,  7,   'uncommon', 'Carved shell profile.', false)
valuable('earrings_silver',  'Silver Earrings',    10,  3,   'common',   'A pair.', false)
valuable('earrings_diamond', 'Diamond Earrings',   10,  40,  'rare',     'They catch the lamplight.', false)
valuable('cufflinks',        'Gold Cufflinks',     15,  6,   'uncommon', 'Monogrammed.', false)
valuable('bracelet',         'Gold Bracelet',      30,  10,  'uncommon', 'Heavy links.', false)
valuable('tiara',            'Tiara',              100, 80,  'exquisite','Someone in Saint Denis is furious.', false)
valuable('silverware',       'Silverware',         800, 15,  'uncommon', 'A set of sterling cutlery.', false)
valuable('candlestick_silver','Silver Candlestick',600, 10,  'uncommon', 'From a church, probably.', false)
valuable('painting',         'Oil Painting',       2000,50,  'rare',     'A landscape in a gilt frame.', false)
valuable('vase',             'Porcelain Vase',     1500,20,  'uncommon', 'Chinese export ware.', false)
valuable('music_box',        'Music Box',          800, 15,  'uncommon', 'Plays a waltz, once wound.', false)
valuable('watch_chain',      'Watch Chain',        30,  4,   'common',   'Gold-plated.', false)
valuable('coin_gold_old',    'Old Gold Coin',      10,  15,  'rare',     'Spanish doubloon, or near enough.', true)
valuable('coin_silver_old',  'Old Silver Coin',    10,  4,   'uncommon', 'Worn Liberty dollar.', true)
valuable('stolen_goods',     'Stolen Goods',       2000,8,   'common',   'A bundle of somebody else\'s things.', false)
valuable('jewelry_box',      'Jewelry Box',        1500,30,  'rare',     'Locked. Rattles pleasantly.', false)

local function collectible(name, label, w, value, rarity, desc, tags)
    add(I(name, label, w, { category = 'collectible', value = value, rarity = rarity, description = desc, tags = tags or { 'collectible' } }))
end
collectible('cigarette_card',    'Cigarette Card',     2,   0.1, 'common',   'One of a set of twelve (info.set, info.no).', { 'collectible', 'card' })
collectible('arrowhead',         'Arrowhead',          20,  0.5, 'common',   'Flint point, old as the hills.', { 'collectible', 'relic' })
collectible('dinosaur_bone',     'Dinosaur Bone',      3000,5.0, 'rare',     'A palaeontologist in Saint Denis pays for these.', { 'collectible', 'fossil' })
collectible('fossil_shell',      'Fossil Shell',       300, 1.0, 'uncommon', 'Ammonite in limestone.', { 'collectible', 'fossil' })
collectible('egg_bird',          'Bird Egg',           40,  0.8, 'uncommon', 'Blown and labelled (info.species).', { 'collectible' })
collectible('coin_collection',   'Rare Coin',          10,  3.0, 'rare',     'Numismatists want it (info.year).', { 'collectible' })
collectible('meteorite',         'Meteorite Fragment', 500, 10,  'exquisite','Fell from the sky. Heavy for its size.', { 'collectible' })
collectible('tarot_card',        'Tarot Card',         2,   1.0, 'uncommon', 'One card of a Saint Denis deck (info.card).', { 'collectible', 'card' })
collectible('bottle_old',        'Antique Bottle',     300, 0.4, 'common',   'Green glass, hand-blown.', { 'collectible' })
collectible('button_military',   'Military Button',    5,   0.3, 'common',   'Union or Confederate. Ask nobody in Rhodes.', { 'collectible', 'relic' })

add(I('opium',        'Opium',               50,  { category = 'contraband', value = 4, rarity = 'uncommon', effects = { stress = -50, stamina = -30, health = -5 }, use = { anim = 'smoke', prop = 'pipe', time = 10000 }, requires = { tool = 'opium_pipe' }, tags = { 'contraband', 'opiate', 'addictive' }, description = 'Black tar from the Saint Denis dens.' }))
add(I('opium_pipe',   'Opium Pipe',          200, { category = 'contraband', value = 2, unique = true, useable = false, description = 'Long bamboo pipe with a clay bowl.', tags = { 'contraband' } }))
add(I('cocaine_gum',  'Cocaine Gum',         30,  { category = 'contraband', value = 1.5, effects = { stamina = 40, stress = -10, health = -3 }, use = { anim = 'eat', time = 1500 }, tags = { 'contraband', 'addictive' }, description = 'Sold as a tonic gum. Legal until it isn\'t.', legal = true }))
add(I('counterfeit_bill', 'Counterfeit Bills', 5, { category = 'contraband', value = 0.3, rarity = 'uncommon', useable = false, stack = 100, tags = { 'contraband' }, description = 'Well-printed. Bank tellers know the difference.' }))
add(I('counterfeit_plate', 'Printing Plate',  2000,{ category = 'contraband', value = 40, rarity = 'rare', unique = true, useable = false, tags = { 'contraband' }, description = 'Engraved plate for twenty-dollar notes. A hanging offence.' }))
add(I('mail_bag',     'Mail Bag',            3000,{ category = 'contraband', value = 10, unique = true, useable = false, tags = { 'contraband', 'robbery' }, description = 'US Mail. Robbing it is a federal crime.' }))
add(I('bank_bag',     'Bank Bag',            5000,{ category = 'contraband', value = 25, unique = true, useable = false, tags = { 'contraband', 'robbery' }, description = 'Canvas bag stencilled with a bank\'s name (info.bank, info.amount).' }))
add(I('strongbox',    'Strongbox',           15000,{ category = 'contraband', value = 40, unique = true, useable = true, tags = { 'contraband', 'robbery' }, use = { anim = 'craft', time = 8000 }, description = 'Wells Fargo strongbox. Needs dynamite or a key.' }))

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔫 AMMUNITION — classes match shared/weapons.lua; variants are real cartridges
-- ═══════════════════════════════════════════════════════════════════════════════
local function ammo(name, label, value, desc, opts)
    opts = opts or {}; opts.category = 'ammo'; opts.value = value; opts.description = desc
    add(I(name, label, opts.weight or 10, opts))
end
ammo('ammo_revolver',            'Revolver Cartridges',        0.02, '.45 Colt, box of fifty.')
ammo('ammo_revolver_express',    'Express Revolver Cartridges', 0.04, 'Heavier powder charge.', { rarity = 'uncommon' })
ammo('ammo_revolver_highvelocity','High Velocity Revolver Cartridges', 0.04, 'Flat-shooting.', { rarity = 'uncommon' })
ammo('ammo_revolver_split',      'Split Point Revolver Cartridges', 0.03, 'Notched lead. Hand-made.', { rarity = 'uncommon' })
ammo('ammo_revolver_explosive',  'Explosive Revolver Cartridges', 0.15, 'Illegal, and it shows.', { rarity = 'rare', legal = false })
ammo('ammo_pistol',              'Pistol Cartridges',          0.02, '.30 Mauser and the like.')
ammo('ammo_pistol_express',      'Express Pistol Cartridges',  0.04, 'Heavier charge.', { rarity = 'uncommon' })
ammo('ammo_pistol_highvelocity', 'High Velocity Pistol Cartridges', 0.04, 'Flat and fast.', { rarity = 'uncommon' })
ammo('ammo_pistol_split',        'Split Point Pistol Cartridges', 0.03, 'Notched.', { rarity = 'uncommon' })
ammo('ammo_pistol_explosive',    'Explosive Pistol Cartridges', 0.15, 'Illegal.', { rarity = 'rare', legal = false })
ammo('ammo_repeater',            'Repeater Cartridges',        0.03, '.44-40, box of fifty.')
ammo('ammo_repeater_express',    'Express Repeater Cartridges', 0.05, 'Heavier charge.', { rarity = 'uncommon' })
ammo('ammo_repeater_highvelocity','High Velocity Repeater Cartridges', 0.05, 'Flat and fast.', { rarity = 'uncommon' })
ammo('ammo_repeater_split',      'Split Point Repeater Cartridges', 0.04, 'Notched.', { rarity = 'uncommon' })
ammo('ammo_repeater_explosive',  'Explosive Repeater Cartridges', 0.2, 'Illegal.', { rarity = 'rare', legal = false })
ammo('ammo_rifle',               'Rifle Cartridges',           0.04, '.30-06 and .45-70, box of twenty.')
ammo('ammo_rifle_express',       'Express Rifle Cartridges',   0.06, 'Heavier charge.', { rarity = 'uncommon' })
ammo('ammo_rifle_highvelocity',  'High Velocity Rifle Cartridges', 0.06, 'Long range.', { rarity = 'uncommon' })
ammo('ammo_rifle_split',         'Split Point Rifle Cartridges', 0.05, 'Notched.', { rarity = 'uncommon' })
ammo('ammo_rifle_explosive',     'Explosive Rifle Cartridges', 0.25, 'Illegal.', { rarity = 'rare', legal = false })
ammo('ammo_rifle_elephant',      'Elephant Rifle Cartridges',  0.5,  '.600 Nitro. Box of ten.', { rarity = 'rare', weight = 30 })
ammo('ammo_rifle_varmint',       'Varmint Cartridges',         0.02, '.22 rimfire, box of a hundred.')
ammo('ammo_shotgun',             'Buckshot Shells',            0.05, '12-gauge, box of twenty-five.', { weight = 20 })
ammo('ammo_shotgun_slug',        'Slug Shells',                0.08, 'One heavy ball.', { rarity = 'uncommon', weight = 20 })
ammo('ammo_shotgun_incendiary',  'Incendiary Shells',          0.2,  'Phosphorus. Sets fires.', { rarity = 'rare', legal = false, weight = 20 })
ammo('ammo_shotgun_explosive',   'Explosive Shells',           0.3,  'Illegal.', { rarity = 'rare', legal = false, weight = 20 })
ammo('ammo_arrow',               'Arrows',                     0.05, 'Fletched hunting arrows.', { weight = 30, stack = 50 })
ammo('ammo_arrow_improved',      'Improved Arrows',            0.1,  'Steel broadheads.', { rarity = 'uncommon', weight = 30, stack = 50 })
ammo('ammo_arrow_smallgame',     'Small Game Arrows',          0.06, 'Blunt tips. Leaves the pelt whole.', { weight = 25, stack = 50 })
ammo('ammo_arrow_poison',        'Poison Arrows',              0.15, 'Oleander tips.', { rarity = 'uncommon', weight = 30, stack = 50, legal = false })
ammo('ammo_arrow_fire',          'Fire Arrows',                0.15, 'Pitch-wrapped.', { rarity = 'uncommon', weight = 35, stack = 50 })
ammo('ammo_arrow_dynamite',      'Dynamite Arrows',            0.4,  'Somebody thought this was a good idea.', { rarity = 'rare', weight = 60, stack = 20, legal = false })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🪓 WEAPONS — one item per weapon record in shared/weapons.lua
-- ═══════════════════════════════════════════════════════════════════════════════
local function weaponItem(name, label, w, value, desc, opts)
    opts = opts or {}; opts.category = 'weapon'; opts.value = value; opts.description = desc
    add(I(name, label, w, opts))
end
-- revolvers
weaponItem('weapon_revolver_cattleman',        'Cattleman Revolver',        1100, 30,  'Colt Single Action Army. The gun that won the West, and lost it.')
weaponItem('weapon_revolver_cattleman_mexican','Mexican Cattleman Revolver',1100, 45,  'Engraved and nickel-plated, from south of the border.', { rarity = 'uncommon' })
weaponItem('weapon_revolver_schofield',        'Schofield Revolver',        1100, 42,  'Smith & Wesson top-break. Fast to reload.')
weaponItem('weapon_revolver_doubleaction',     'Double-Action Revolver',    1000, 55,  'Colt Lightning. No hammer-cocking.')
weaponItem('weapon_revolver_doubleaction_exotic','Exotic Double-Action',    1000, 90,  'Gold inlay, ivory grips.', { rarity = 'rare' })
weaponItem('weapon_revolver_lemat',            'LeMat Revolver',            1300, 75,  'Nine chambers and a shotgun barrel. Confederate design.', { rarity = 'uncommon', era = 1861 })
weaponItem('weapon_revolver_navy',             'Navy Revolver',             1100, 60,  'Colt 1851 pattern, converted to cartridge.', { rarity = 'uncommon' })
weaponItem('weapon_revolver_navy_crossover',   'Navy Revolver (Engraved)',  1100, 85,  'Presentation piece.', { rarity = 'rare' })
-- pistols
weaponItem('weapon_pistol_volcanic',           'Volcanic Pistol',           1000, 35,  'Lever-action pistol. Old, but hits hard.', { era = 1855 })
weaponItem('weapon_pistol_mauser',             'Mauser Pistol',             1200, 95,  'C96 Broomhandle, ten rounds, German.', { rarity = 'uncommon', era = 1896 })
weaponItem('weapon_pistol_semiauto',           'Semi-Automatic Pistol',     900,  110, 'Borchardt C-93. The future, awkwardly.', { rarity = 'uncommon', era = 1894 })
weaponItem('weapon_pistol_m1899',              'M1899 Pistol',              1000, 120, 'Compact semi-automatic. Saint Denis gunsmith special.', { rarity = 'rare', era = 1899 })
-- repeaters
weaponItem('weapon_repeater_carbine',          'Carbine Repeater',          2800, 60,  'Spencer carbine. Cavalry surplus.', { era = 1860 })
weaponItem('weapon_repeater_winchester',       'Lancaster Repeater',        3000, 80,  'Winchester 1866 “Yellow Boy”.', { era = 1866 })
weaponItem('weapon_repeater_henry',            'Litchfield Repeater',       3200, 130, 'Henry rifle. Sixteen rounds, load on Sunday, shoot all week.', { rarity = 'uncommon', era = 1860 })
weaponItem('weapon_repeater_evans',            'Evans Repeater',            3500, 180, 'Twenty-six round rotary magazine.', { rarity = 'rare', era = 1873 })
-- rifles
weaponItem('weapon_rifle_springfield',         'Springfield Rifle',         3800, 90,  'Trapdoor Springfield. One shot, make it count.', { era = 1873 })
weaponItem('weapon_rifle_boltaction',          'Bolt Action Rifle',         3600, 150, 'Krag–Jørgensen. Five rounds, army issue.', { rarity = 'uncommon', era = 1892 })
weaponItem('weapon_rifle_rollingblock',        'Rolling Block Rifle',       4200, 160, 'Remington sniper rifle with a brass scope.', { rarity = 'uncommon', era = 1867 })
weaponItem('weapon_rifle_carcano',             'Carcano Rifle',             3800, 220, 'Italian bolt-action with a long scope.', { rarity = 'rare', era = 1891 })
weaponItem('weapon_rifle_varmint',             'Varmint Rifle',             2200, 40,  '.22 Winchester. Rabbits and birds, pelt intact.', { era = 1890 })
weaponItem('weapon_rifle_elephant',            'Elephant Rifle',            5500, 380, '.600 Nitro Express double rifle. Overkill for anything on this continent.', { rarity = 'exquisite', era = 1899 })
-- shotguns
weaponItem('weapon_shotgun_doublebarrel',      'Double-Barrelled Shotgun',  3400, 65,  'Side-by-side twelve gauge.')
weaponItem('weapon_shotgun_doublebarrel_exotic','Exotic Double-Barrel',     3400, 140, 'Damascus barrels, engraved locks.', { rarity = 'rare' })
weaponItem('weapon_shotgun_sawedoff',          'Sawed-Off Shotgun',         2200, 55,  'Cut down to fit under a coat.', { legal = false })
weaponItem('weapon_shotgun_pump',              'Pump-Action Shotgun',       3600, 130, 'Winchester 1897. Five in the tube.', { rarity = 'uncommon', era = 1897 })
weaponItem('weapon_shotgun_repeating',         'Repeating Shotgun',         3600, 160, 'Lever-action Winchester 1887.', { rarity = 'uncommon', era = 1887 })
weaponItem('weapon_shotgun_semiauto',          'Semi-Auto Shotgun',         3800, 240, 'Browning Auto-5. Brand new and terrifying.', { rarity = 'rare', era = 1902 })
-- bows
weaponItem('weapon_bow',                       'Hunting Bow',               1400, 25,  'Ash self-bow. Silent.')
weaponItem('weapon_bow_improved',              'Improved Bow',              1500, 60,  'Laminated with sinew. Stronger draw.', { rarity = 'uncommon' })
-- melee
weaponItem('weapon_melee_knife',               'Hunting Knife',             450,  5,   'Six-inch blade, stag handle.')
weaponItem('weapon_melee_knife_bear',          'Bear Knife',                600,  25,  'Bear-tooth handle.', { rarity = 'uncommon' })
weaponItem('weapon_melee_knife_civil_war',     'Civil War Knife',           500,  20,  'A veteran\'s blade.', { rarity = 'uncommon', era = 1862 })
weaponItem('weapon_melee_knife_jawbone',       'Jawbone Knife',             500,  30,  'Handle carved from a jaw.', { rarity = 'rare' })
weaponItem('weapon_melee_knife_miner',         'Miner\'s Knife',            450,  8,   'Short and thick.')
weaponItem('weapon_melee_knife_trader',        'Trader\'s Knife',           450,  12,  'Skinning blade with a fine edge.')
weaponItem('weapon_melee_knife_rustic',        'Rustic Knife',              450,  6,   'Hand-forged.')
weaponItem('weapon_melee_knife_vampire',       'Ornate Dagger',             500,  40,  'Silver-chased. Saint Denis has stories.', { rarity = 'rare' })
weaponItem('weapon_melee_cleaver',             'Cleaver',                   900,  4,   'Butcher\'s tool.')
weaponItem('weapon_melee_machete',             'Machete',                   900,  8,   'For the bayou brush.')
weaponItem('weapon_melee_hatchet',             'Hatchet',                   800,  6,   'Camp hatchet.')
weaponItem('weapon_melee_hatchet_hunter',      'Hunter Hatchet',            800,  14,  'Balanced for throwing.', { rarity = 'uncommon' })
weaponItem('weapon_melee_hatchet_hewing',      'Hewing Hatchet',            900,  10,  'Flat-ground carpenter\'s hatchet.')
weaponItem('weapon_melee_hatchet_double_bit',  'Double Bit Hatchet',        1000, 12,  'Two edges.')
weaponItem('weapon_melee_hatchet_viking',      'Viking Hatchet',            1000, 35,  'Bearded axe head. Old world.', { rarity = 'rare' })
weaponItem('weapon_melee_ancient_hatchet',     'Ancient Hatchet',           900,  40,  'Stone-age relic, still sharp.', { rarity = 'rare' })
weaponItem('weapon_melee_broken_sword',        'Broken Sword',              1200, 15,  'Half a cavalry sabre.', { rarity = 'uncommon' })
weaponItem('weapon_melee_torch',               'Torch (Weapon)',            600,  0.2, 'Lit and swung.')
weaponItem('weapon_melee_lantern',             'Lantern (Held)',            700,  1.2, 'A lantern, in the hand.')
-- thrown
local function thrown(name, label, w, value, desc, opts)
    opts = opts or {}; opts.category = 'thrown'; opts.value = value; opts.description = desc
    add(I(name, label, w, opts))
end
thrown('weapon_thrown_throwing_knives', 'Throwing Knives', 200, 1.0,  'Balanced blades, set of five.', { stack = 10 })
thrown('weapon_thrown_tomahawk',        'Tomahawk',        600, 3.0,  'Trade axe, thrown.', { stack = 5 })
thrown('weapon_thrown_tomahawk_ancient','Ancient Tomahawk',600, 12.0, 'Relic, better balanced than it looks.', { stack = 5, rarity = 'rare' })
thrown('weapon_thrown_dynamite',        'Dynamite',        400, 1.5,  'Nobel\'s gift to miners and bank robbers.', { stack = 10, legal = false, tags = { 'explosive' } })
thrown('weapon_thrown_dynamite_volatile','Volatile Dynamite', 400, 3.0, 'Double charge, half the fuse.', { stack = 10, legal = false, rarity = 'uncommon', tags = { 'explosive' } })
thrown('weapon_thrown_molotov',         'Fire Bottle',     500, 0.5,  'Moonshine and a rag.', { stack = 10, legal = false })
thrown('weapon_thrown_molotov_volatile','Volatile Fire Bottle', 500, 1.0, 'Burns hotter, longer.', { stack = 10, legal = false, rarity = 'uncommon' })
thrown('weapon_thrown_poisonbottle',    'Poison Bottle',   300, 1.5,  'Oleander vapour. Nasty.', { stack = 10, legal = false, rarity = 'uncommon' })
thrown('weapon_thrown_bolas',           'Bolas',           500, 2.0,  'Weighted cords. Trips a running man or animal.', { stack = 5 })
thrown('weapon_thrown_bolas_hawkmoth',  'Hawkmoth Bolas',  500, 6.0,  'Bladed weights.', { stack = 5, rarity = 'uncommon' })
thrown('weapon_thrown_bolas_ironspiked','Iron Spiked Bolas', 600, 6.0, 'Spiked weights.', { stack = 5, rarity = 'uncommon' })
thrown('weapon_thrown_bolas_intertwined','Intertwined Bolas', 500, 6.0, 'Braided cords.', { stack = 5, rarity = 'uncommon' })

-- ═══════════════════════════════════════════════════════════════════════════════
-- 👒 CLOTHING & MISC
-- ═══════════════════════════════════════════════════════════════════════════════
add(I('outfit_bundle',  'Bundle of Clothes',  2500,{ category = 'clothing', value = 3, description = 'An outfit wrapped in paper (info.outfit). Wear it at a wardrobe.' }))
add(I('hat',            'Hat',                300, { category = 'clothing', value = 2, description = 'A hat (info.drawable). Every head needs one.' }))
add(I('mask',           'Bandana',            50,  { category = 'clothing', value = 0.3, quality = false, description = 'Over the face, and nobody knows you. Nobody.', legal = true }))
add(I('poncho',         'Poncho',             800, { category = 'clothing', value = 2, description = 'Wool poncho. Rain and cold.' }))
add(I('soap',           'Bar of Soap',        100, { category = 'misc', value = 0.05, effects = { cleanliness = 40 }, use = { anim = 'inspect', time = 4000, consume = true }, description = 'Lye soap. Use it, please.' }))
add(I('towel',          'Towel',              300, { category = 'misc', value = 0.1, useable = false, description = 'Cotton towel.' }))
add(I('bottle_perfume', 'Perfume',            150, { category = 'misc', value = 1.5, rarity = 'uncommon', effects = { cleanliness = 10, stress = -3 }, use = { anim = 'inspect', time = 2000, consume = true, cooldown = 30000 }, description = 'French, or pretending.' }))
add(I('empty_sack',     'Burlap Sack',        200, { category = 'misc', value = 0.05, useable = false, stack = 20, description = 'Holds grain, potatoes or loot.' }))
add(I('crate',          'Wooden Crate',       5000,{ category = 'misc', value = 0.3, useable = false, stack = 5, description = 'Shipping crate (info.contents).' }))
add(I('parcel',         'Parcel',             1500,{ category = 'misc', value = 0, unique = true, useable = false, description = 'Wrapped in brown paper, addressed (info.to).' }))
add(I('trinket',        'Trinket',            50,  { category = 'misc', value = 0.2, useable = false, description = 'A small carved something.' }))

LXRShared.Items = Items

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🎒 STARTER KITS — chosen at character creation (lxr-creator shows them)
-- ═══════════════════════════════════════════════════════════════════════════════
LXRShared.StarterKits = {
    drifter = {
        label = 'Drifter', description = 'You arrived on the last train with a bedroll and a bad reputation.',
        cash = 15,
        items = { { item = 'id_card', amount = 1 }, { item = 'canteen', amount = 1 }, { item = 'bread', amount = 2 }, { item = 'jerky', amount = 2 }, { item = 'bedroll', amount = 1 }, { item = 'matches', amount = 1 }, { item = 'weapon_melee_knife', amount = 1 } },
    },
    rancher = {
        label = 'Ranch Hand', description = 'Raised on cattle and early mornings.',
        cash = 20,
        items = { { item = 'id_card', amount = 1 }, { item = 'canteen', amount = 1 }, { item = 'biscuit', amount = 4 }, { item = 'lasso', amount = 1 }, { item = 'horse_brush', amount = 1 }, { item = 'apple', amount = 3 }, { item = 'weapon_melee_knife', amount = 1 } },
    },
    hunter = {
        label = 'Trapper', description = 'You know the woods better than the towns.',
        cash = 10,
        items = { { item = 'id_card', amount = 1 }, { item = 'canteen', amount = 1 }, { item = 'jerky', amount = 3 }, { item = 'skinning_knife', amount = 1 }, { item = 'snare', amount = 3 }, { item = 'hunting_license', amount = 1 }, { item = 'weapon_bow', amount = 1 }, { item = 'ammo_arrow', amount = 20 } },
    },
    immigrant = {
        label = 'Immigrant', description = 'Off the boat at Saint Denis with a trunk and a dictionary.',
        cash = 30,
        items = { { item = 'id_card', amount = 1 }, { item = 'water', amount = 2 }, { item = 'bread', amount = 2 }, { item = 'cheese', amount = 1 }, { item = 'photograph', amount = 1 }, { item = 'sewing_kit', amount = 1 } },
    },
    veteran = {
        label = 'Veteran', description = 'You served. You would rather not talk about it.',
        cash = 12,
        items = { { item = 'id_card', amount = 1 }, { item = 'canteen', amount = 1 }, { item = 'hardtack', amount = 4 }, { item = 'canned_beans', amount = 1 }, { item = 'bandage', amount = 2 }, { item = 'flask', amount = 1 }, { item = 'weapon_melee_knife_civil_war', amount = 1 } },
    },
    prospector = {
        label = 'Prospector', description = 'There is gold in those hills. There must be.',
        cash = 8,
        items = { { item = 'id_card', amount = 1 }, { item = 'canteen', amount = 1 }, { item = 'canned_beans', amount = 2 }, { item = 'gold_pan', amount = 1 }, { item = 'pickaxe', amount = 1 }, { item = 'lantern', amount = 1 } },
    },
    physician = {
        label = 'Physician', description = 'A diploma from back East, and a bag.',
        cash = 40,
        items = { { item = 'id_card', amount = 1 }, { item = 'water', amount = 2 }, { item = 'bread', amount = 1 }, { item = 'medical_bag', amount = 1 }, { item = 'bandage_clean', amount = 3 }, { item = 'iodine', amount = 1 } },
    },
    outlaw = {
        label = 'Outlaw', description = 'The poster does not do you justice.',
        cash = 5,
        items = { { item = 'canteen', amount = 1 }, { item = 'jerky', amount = 2 }, { item = 'whiskey', amount = 1 }, { item = 'mask', amount = 1 }, { item = 'lockpick', amount = 2 }, { item = 'weapon_revolver_cattleman', amount = 1 }, { item = 'ammo_revolver', amount = 12 } },
    },
}
LXRShared.DefaultStarterKit = 'drifter'
-- flat list for resources that only know the old shape
LXRShared.StarterItems = LXRShared.StarterKits[LXRShared.DefaultStarterKit].items
