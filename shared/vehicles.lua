--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Wagons, Coaches, Carts & Boats
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore's vehicle model (RDR3 "vehicles" are horse-drawn or floating).

       V(model, label, category, {
           seats = passenger seats incl. driver,   draft = horses needed (0 for boats),
           storage = { slots, weight (grams) },     price = period dollars,
           speed = 1–10 relative,                   lockable = has a strongbox / doors,
           jobs = { job names that may buy it } (nil = anyone),   era = year,
           illegal = true for things no honest shop sells,
       })

     Categories (LXRShared.VehicleCategories) say whether it is a wagon or a
     boat, where it is sold and which skill it trains. Model names are RDR3
     (build 1491) — a wagon shop resource only needs `LXRShared.WagonsForShop`.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

LXRShared.VehicleCategories = {
    cart      = { label = 'Carts',         kind = 'wagon', shop = 'wagon', description = 'One horse, two wheels, a load.' },
    buggy     = { label = 'Buggies',       kind = 'wagon', shop = 'wagon', description = 'Light and quick. Doctors and courting.' },
    wagon     = { label = 'Wagons',        kind = 'wagon', shop = 'wagon', description = 'Working wagons of every trade.' },
    coach     = { label = 'Coaches',       kind = 'wagon', shop = 'wagon', description = 'Passengers in comfort, or at least in cover.' },
    utility   = { label = 'Utility',       kind = 'wagon', shop = 'wagon', description = 'Specialist rigs: oil, logs, prisoners.' },
    military  = { label = 'Armoured',      kind = 'wagon', shop = nil,     description = 'Not for sale.' },
    boat      = { label = 'Boats',         kind = 'boat',  shop = 'boat',  description = 'Rowed, paddled or steamed.' },
}

local Vehicles = {}
local function V(model, label, category, o)
    o = o or {}
    Vehicles[model] = {
        model = model, hash = joaat(model), label = label, category = category,
        kind = (LXRShared.VehicleCategories[category] or {}).kind or 'wagon',
        seats = o.seats or 2, draft = o.draft or (category == 'boat' and 0 or 1),
        storage = o.storage or { slots = 0, weight = 0 },
        price = o.price or 0, sellMult = 0.5, speed = o.speed or 5,
        lockable = o.lockable == true, jobs = o.jobs, era = o.era or 1899,
        illegal = o.illegal == true, description = o.description or '',
        -- legacy fields kept for resources that read the old RSG shape
        name = label, brand = 'Wagon', type = (LXRShared.VehicleCategories[category] or {}).kind or 'wagon',
    }
end

-- ═══ Carts ═══
V('cart01', 'Farm Cart',        'cart',  { price = 35,  seats = 1, storage = { slots = 10, weight = 60000 },  speed = 4, description = 'Two wheels and a mule\'s worth of patience.' })
V('cart02', 'Delivery Cart',    'cart',  { price = 45,  seats = 2, storage = { slots = 12, weight = 70000 },  speed = 4 })
V('cart03', 'Market Cart',      'cart',  { price = 50,  seats = 2, storage = { slots = 15, weight = 80000 },  speed = 4 })
V('cart04', 'Covered Cart',     'cart',  { price = 60,  seats = 2, storage = { slots = 15, weight = 80000 },  speed = 4, description = 'A canvas hood keeps the rain off the goods.' })
V('cart05', 'Hay Cart',         'cart',  { price = 40,  seats = 1, storage = { slots = 8,  weight = 100000 }, speed = 3 })
V('cart06', 'Water Cart',       'cart',  { price = 55,  seats = 1, storage = { slots = 4,  weight = 40000 },  speed = 3, description = 'A barrel on wheels.' })
V('cart07', 'Vendor Cart',      'cart',  { price = 65,  seats = 1, storage = { slots = 20, weight = 60000 },  speed = 3, description = 'Sell from the tailboard.' })
V('cart08', 'Timber Cart',      'cart',  { price = 50,  seats = 1, storage = { slots = 6,  weight = 150000 }, speed = 3, jobs = { 'lumber', 'carpenter' } })
-- ═══ Buggies ═══
V('buggy01', 'Buggy',           'buggy', { price = 110, seats = 2, storage = { slots = 4, weight = 20000 }, speed = 7, description = 'Light, fast, respectable.' })
V('buggy02', 'Doctor\'s Buggy', 'buggy', { price = 140, seats = 2, storage = { slots = 6, weight = 25000 }, speed = 7, jobs = { 'valdoc', 'rhodoc', 'strdoc', 'blkdoc', 'sddoc', 'armdoc' } })
V('buggy03', 'Fine Buggy',      'buggy', { price = 190, seats = 2, storage = { slots = 4, weight = 20000 }, speed = 7, description = 'Lacquered, upholstered, and the envy of the street.' })
-- ═══ Wagons ═══
V('wagon02x',  'Farm Wagon',     'wagon', { price = 150, seats = 2, draft = 2, storage = { slots = 30, weight = 250000 }, speed = 4 })
V('wagon03x',  'Supply Wagon',   'wagon', { price = 175, seats = 2, draft = 2, storage = { slots = 35, weight = 300000 }, speed = 4, lockable = true })
V('wagon04x',  'Hay Wagon',      'wagon', { price = 160, seats = 2, draft = 2, storage = { slots = 20, weight = 350000 }, speed = 3, jobs = { 'rancher', 'farmer', 'stable' } })
V('wagon05x',  'Covered Wagon',  'wagon', { price = 220, seats = 4, draft = 2, storage = { slots = 40, weight = 300000 }, speed = 4, lockable = true, description = 'The prairie schooner. Home for a family on the move.' })
V('wagon06x',  'Delivery Wagon', 'wagon', { price = 200, seats = 2, draft = 2, storage = { slots = 40, weight = 320000 }, speed = 4, lockable = true, jobs = { 'freight', 'general', 'postal' } })
V('wagontraveller01x', 'Traveller Wagon', 'wagon', { price = 320, seats = 4, draft = 2, storage = { slots = 45, weight = 300000 }, speed = 4, lockable = true, description = 'A house on wheels: bunk, stove, and everything you own.' })
V('wagondairy01x',     'Dairy Wagon',     'wagon', { price = 180, seats = 2, draft = 1, storage = { slots = 25, weight = 200000 }, speed = 4, jobs = { 'farmer', 'rancher', 'general' } })
V('wagonwork01x',      'Work Wagon',      'wagon', { price = 190, seats = 2, draft = 2, storage = { slots = 35, weight = 300000 }, speed = 4, jobs = { 'carpenter', 'blacksmith', 'lumber', 'mining' } })
V('wagondoc01x',       'Medicine Wagon',  'wagon', { price = 260, seats = 2, draft = 2, storage = { slots = 30, weight = 200000 }, speed = 5, jobs = { 'apothecary', 'valdoc', 'rhodoc', 'strdoc', 'blkdoc', 'sddoc', 'armdoc' }, description = 'Tonics on the shelves, a table in the back.' })
V('wagoncircus01x',    'Circus Wagon',    'wagon', { price = 400, seats = 2, draft = 2, storage = { slots = 40, weight = 300000 }, speed = 4, jobs = { 'theatre' }, description = 'Painted and loud.' })
V('wagoncircus02x',    'Menagerie Wagon', 'wagon', { price = 450, seats = 2, draft = 2, storage = { slots = 20, weight = 400000 }, speed = 3, jobs = { 'theatre' } })
V('chuckwagon000x',    'Chuck Wagon',     'wagon', { price = 280, seats = 2, draft = 2, storage = { slots = 40, weight = 250000 }, speed = 4, jobs = { 'rancher', 'saloon', 'freight' }, description = 'A kitchen on the trail.' })
V('chuckwagon002x',    'Chuck Wagon (Covered)', 'wagon', { price = 300, seats = 2, draft = 2, storage = { slots = 40, weight = 250000 }, speed = 4, jobs = { 'rancher', 'saloon', 'freight' } })
V('supplywagon',       'Freight Wagon',   'wagon', { price = 340, seats = 2, draft = 4, storage = { slots = 60, weight = 600000 }, speed = 3, lockable = true, jobs = { 'freight', 'mining', 'oil', 'railroad' } })
V('supplywagon2',      'Heavy Freight Wagon', 'wagon', { price = 420, seats = 2, draft = 4, storage = { slots = 80, weight = 800000 }, speed = 3, lockable = true, jobs = { 'freight', 'mining', 'oil', 'railroad' } })
V('gatchuck',          'Gatling Wagon',   'military', { price = 0, seats = 3, draft = 2, storage = { slots = 10, weight = 100000 }, speed = 4, illegal = true, description = 'A Gatling gun on a wagon bed. Army property, allegedly.' })
V('gatchuck_2',        'Gatling Wagon (Covered)', 'military', { price = 0, seats = 3, draft = 2, storage = { slots = 10, weight = 100000 }, speed = 4, illegal = true })
-- ═══ Coaches ═══
V('coach2',        'Coach',            'coach', { price = 300, seats = 4, draft = 2, storage = { slots = 15, weight = 100000 }, speed = 6, lockable = true })
V('coach3',        'Stagecoach',       'coach', { price = 380, seats = 6, draft = 4, storage = { slots = 25, weight = 150000 }, speed = 6, lockable = true, jobs = { 'stageline' }, description = 'Six inside, two up top, strongbox under the seat.' })
V('coach4',        'Private Coach',    'coach', { price = 450, seats = 4, draft = 2, storage = { slots = 15, weight = 100000 }, speed = 6, lockable = true })
V('coach5',        'Luxury Coach',     'coach', { price = 650, seats = 4, draft = 2, storage = { slots = 15, weight = 100000 }, speed = 6, lockable = true, description = 'Leather, brass, a driver in livery.' })
V('coach6',        'Hearse',           'coach', { price = 350, seats = 2, draft = 2, storage = { slots = 6,  weight = 200000 }, speed = 5, jobs = { 'undertaker', 'church' } })
V('stagecoach001x','Stagecoach (Red)', 'coach', { price = 400, seats = 6, draft = 4, storage = { slots = 25, weight = 150000 }, speed = 6, lockable = true, jobs = { 'stageline' } })
V('stagecoach002x','Stagecoach (Green)','coach',{ price = 400, seats = 6, draft = 4, storage = { slots = 25, weight = 150000 }, speed = 6, lockable = true, jobs = { 'stageline' } })
V('stagecoach003x','Stagecoach (Blue)','coach', { price = 400, seats = 6, draft = 4, storage = { slots = 25, weight = 150000 }, speed = 6, lockable = true, jobs = { 'stageline' } })
V('stagecoach004x','Stagecoach (Black)','coach',{ price = 420, seats = 6, draft = 4, storage = { slots = 25, weight = 150000 }, speed = 6, lockable = true, jobs = { 'stageline' } })
V('stagecoach005x','Stagecoach (Yellow)','coach',{ price = 420, seats = 6, draft = 4, storage = { slots = 25, weight = 150000 }, speed = 6, lockable = true, jobs = { 'stageline' } })
V('stagecoach006x','Mail Coach',       'coach', { price = 500, seats = 4, draft = 4, storage = { slots = 40, weight = 200000 }, speed = 6, lockable = true, jobs = { 'postal', 'stageline' } })
-- ═══ Utility ═══
V('huntercart01',   'Hunter\'s Cart',   'utility', { price = 90,  seats = 1, draft = 1, storage = { slots = 20, weight = 200000 }, speed = 4, description = 'Racks for carcasses, hooks for pelts.' })
V('logwagon',       'Log Wagon',        'utility', { price = 260, seats = 2, draft = 4, storage = { slots = 10, weight = 900000 }, speed = 2, jobs = { 'lumber' } })
V('oilwagon01x',    'Oil Wagon',        'utility', { price = 320, seats = 2, draft = 2, storage = { slots = 6,  weight = 500000 }, speed = 3, jobs = { 'oil' } })
V('oilwagon02x',    'Oil Wagon (Large)','utility', { price = 380, seats = 2, draft = 4, storage = { slots = 8,  weight = 800000 }, speed = 3, jobs = { 'oil' } })
V('utillitywagon',  'Utility Wagon',    'utility', { price = 200, seats = 2, draft = 2, storage = { slots = 30, weight = 300000 }, speed = 4, jobs = { 'railroad', 'mining', 'oil', 'carpenter' } })
V('policewagon01x', 'Prison Wagon',     'utility', { price = 0,   seats = 6, draft = 2, storage = { slots = 10, weight = 100000 }, speed = 5, lockable = true, jobs = { 'vallaw', 'rholaw', 'strlaw', 'annlaw', 'armlaw', 'tumlaw', 'blklaw', 'sdlaw', 'usmarshal', 'prison' }, description = 'Barred and bolted.' })
V('wagonprison01x', 'Prison Transport', 'utility', { price = 0,   seats = 8, draft = 4, storage = { slots = 10, weight = 100000 }, speed = 4, lockable = true, jobs = { 'prison', 'usmarshal', 'sdlaw', 'blklaw' } })
V('wagonarmoured01x','Armoured Wagon',  'military',{ price = 0,   seats = 3, draft = 4, storage = { slots = 20, weight = 300000 }, speed = 3, lockable = true, jobs = { 'bank', 'usmarshal', 'pinkerton' }, description = 'Iron plates and a strongbox. Bank payroll runs.' })
V('warwagon01x',    'War Wagon',        'military',{ price = 0,   seats = 4, draft = 4, storage = { slots = 20, weight = 300000 }, speed = 3, illegal = true })
V('warwagon02x',    'War Wagon (Covered)', 'military', { price = 0, seats = 4, draft = 4, storage = { slots = 20, weight = 300000 }, speed = 3, illegal = true })
-- ═══ Boats ═══
V('canoe',          'Canoe',            'boat', { price = 30,  seats = 2, storage = { slots = 6,  weight = 40000 },  speed = 4 })
V('canoetreetrunk', 'Dugout Canoe',     'boat', { price = 20,  seats = 1, storage = { slots = 4,  weight = 30000 },  speed = 3 })
V('rowboat',        'Rowboat',          'boat', { price = 50,  seats = 3, storage = { slots = 10, weight = 60000 },  speed = 4 })
V('rowboatswamp',   'Swamp Rowboat',    'boat', { price = 45,  seats = 3, storage = { slots = 10, weight = 60000 },  speed = 4 })
V('pirogue',        'Pirogue',          'boat', { price = 40,  seats = 2, storage = { slots = 8,  weight = 50000 },  speed = 5, description = 'Bayou flat-bottom. Silent.' })
V('pirogue2',       'Pirogue (Long)',   'boat', { price = 55,  seats = 3, storage = { slots = 12, weight = 70000 },  speed = 5 })
V('skiff',          'Skiff',            'boat', { price = 80,  seats = 4, storage = { slots = 15, weight = 100000 }, speed = 5 })
V('keelboat',       'Keelboat',         'boat', { price = 250, seats = 6, storage = { slots = 40, weight = 400000 }, speed = 4, lockable = true, jobs = { 'freight', 'fisherman', 'ferry' } })
V('steamboat',      'Steam Launch',     'boat', { price = 900, seats = 6, storage = { slots = 30, weight = 300000 }, speed = 7, lockable = true, era = 1880, description = 'Coal-fired. Loud, proud, and fast on the Lannahechee.' })
V('steamboat02x',   'Steamboat',        'boat', { price = 1500, seats = 10, storage = { slots = 60, weight = 600000 }, speed = 6, lockable = true, era = 1880, jobs = { 'ferry', 'freight' } })
V('boatsteam02x',   'River Steamer',    'boat', { price = 2500, seats = 12, storage = { slots = 80, weight = 800000 }, speed = 6, lockable = true, era = 1880, jobs = { 'ferry', 'freight', 'railroad' } })

LXRShared.Vehicles = Vehicles
LXRShared.Wagons = Vehicles -- LXR-native alias

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 LOOKUPS
-- ═══════════════════════════════════════════════════════════════════════════════
function LXRShared.GetVehicle(ref)
    if type(ref) == 'string' then
        local v = Vehicles[ref:lower()]
        if v then return v end
        ref = joaat(ref)
    end
    for _, v in pairs(Vehicles) do if v.hash == ref then return v end end
    return nil
end

---Vehicles a shop of `kind` ('wagon' | 'boat') may sell to a player with `job` (name or nil).
function LXRShared.WagonsForShop(kind, job)
    local out = {}
    for _, v in pairs(Vehicles) do
        local cat = LXRShared.VehicleCategories[v.category]
        if cat and cat.shop == kind and not v.illegal and v.price > 0 then
            local ok = v.jobs == nil
            if not ok and job then for _, j in ipairs(v.jobs) do if j == job then ok = true break end end end
            if ok then out[#out + 1] = v end
        end
    end
    table.sort(out, function(a, b) return a.price < b.price end)
    return out
end
