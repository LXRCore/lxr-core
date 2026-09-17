-- shared utilities
local Shim = ...
T.suite('shared')

T.test('RandomStr / RandomInt lengths and charsets', function()
    for _ = 1, 20 do
        T.ok(LXRShared.RandomStr(6):match('^%a%a%a%a%a%a$'), 'alpha 6')
        T.ok(LXRShared.RandomInt(5):match('^%d%d%d%d%d$'), 'digits 5')
    end
    T.eq(LXRShared.RandomStr(0), '')
end)

T.test('SplitStr is plain (no pattern) and keeps empties', function()
    local parts = LXRShared.SplitStr('a.b..c', '.')
    T.eq(#parts, 4)
    T.eq(parts[3], '')
end)

T.test('Trim / Round / Clamp', function()
    T.eq(LXRShared.Trim('  x  '), 'x')
    T.eq(LXRShared.Trim(nil), nil)
    T.eq(LXRShared.Round(2.5), 3)
    T.eq(LXRShared.Round(-2.5), -3)
    T.eq(LXRShared.Round(3.14159, 2), 3.14)
    T.eq(LXRShared.Round(2.675, 1), 2.7)
    T.eq(LXRShared.Clamp(150, 0, 100), 100)
end)

T.test('IsFiniteNumber rejects NaN, inf, strings', function()
    T.eq(LXRShared.IsFiniteNumber(0/0), false)
    T.eq(LXRShared.IsFiniteNumber(math.huge), false)
    T.eq(LXRShared.IsFiniteNumber('5'), false)
    T.eq(LXRShared.IsFiniteNumber(5.5), true)
end)

T.test('ApplyDefaults fills missing keys only and evaluates functions lazily', function()
    local calls = 0
    local defaults = { a = 1, nested = { b = 2, gen = function() calls = calls + 1 return 'x' end } }
    local target = { a = 9, nested = { gen = 'keep' } }
    LXRShared.ApplyDefaults(target, defaults)
    T.eq(target.a, 9)
    T.eq(target.nested.b, 2)
    T.eq(target.nested.gen, 'keep')
    T.eq(calls, 0, 'generator not called when value exists')
    local t2 = LXRShared.ApplyDefaults({}, defaults)
    T.eq(t2.nested.gen, 'x')
    T.eq(calls, 1)
end)

T.test('Commas and JsonDecode fallback', function()
    T.eq(LXRShared.Commas(1234567), '1,234,567')
    T.eq(LXRShared.Commas(-1234.5), '-1,234.5')
    T.eq(#LXRShared.JsonDecode('not json'), 0)
    T.eq(LXRShared.JsonDecode('{"a":1}').a, 1)
    T.eq(LXRShared.JsonDecode(nil, 'fb'), 'fb')
end)

-- ═══ catalog integrity (items · weapons · ammo · jobs · gangs · horses · wagons · kits) ═══
T.test('catalog validates with zero problems', function()
    local problems = LXRShared.Catalog.Validate()
    if #problems > 0 then error('catalog problems:\n  ' .. table.concat(problems, '\n  ', 1, math.min(#problems, 40))) end
end)

T.test('catalog is big enough to be a framework, and every item has the LXR fields', function()
    local n = 0
    for name, def in pairs(LXRShared.Items) do
        n = n + 1
        T.ok(def.category and def.rarity and def.stack and def.value ~= nil and def.effects and def.use and def.tags, 'fields on ' .. name)
        T.ok(type(def.legal) == 'boolean', 'legal flag on ' .. name)
    end
    T.ok(n >= 400, 'items: ' .. n)
    T.ok(LXRShared.TableSize(LXRShared.WeaponsByName) >= 60, 'weapons')
    T.ok(LXRShared.TableSize(LXRShared.Jobs) >= 50, 'jobs')
    T.ok(LXRShared.TableSize(LXRShared.Gangs) >= 15, 'gangs')
    T.ok(LXRShared.TableSize(LXRShared.Horses) >= 145, 'horses')
    T.ok(LXRShared.TableSize(LXRShared.Vehicles) >= 60, 'wagons+boats')
end)

T.test('category profiles apply defaults and opts override them', function()
    local bread = LXRShared.Items.bread
    T.eq(bread.use.anim, 'eat')
    T.eq(bread.use.consume, true)
    T.eq(bread.decay.into, 'spoiled_food')
    T.eq(bread.effects.hunger, 20)
    T.eq(LXRShared.Items.spoiled_food.decay, nil, 'decay = false opts out')
    T.eq(LXRShared.Items.hardtack.decay.hours, 720, 'opts override profile')
    T.eq(LXRShared.Items.weapon_revolver_cattleman.type, 'weapon')
    T.eq(LXRShared.Items.weapon_revolver_cattleman.unique, true)
    T.eq(LXRShared.Items.moonshine.legal, false)
    T.eq(LXRShared.Items.ammo_revolver.stack, 200)
end)

T.test('weapon / ammo / horse / wagon / job / gang lookups', function()
    local w = LXRShared.GetWeapon('weapon_revolver_schofield')
    T.ok(w and w.clip == 6, 'schofield record')
    T.eq(LXRShared.GetWeapon(w.hash), w, 'hash lookup')
    T.eq(LXRShared.WeaponAcceptsAmmo('weapon_revolver_schofield', 'ammo_revolver_express'), true)
    T.eq(LXRShared.WeaponAcceptsAmmo('weapon_revolver_schofield', 'ammo_rifle'), false)
    T.ok(#LXRShared.WeaponsInCategory('revolver') >= 8, 'revolvers')
    T.eq(LXRShared.Ammo.ammo_shotgun_slug.mods.range, 1.5)

    local h = LXRShared.GetHorse('a_c_horse_arabian_white')
    T.eq(h.tier, 5)
    T.eq(h.stats.speed, 8)
    T.ok(h.price > LXRShared.Horses.a_c_horse_morgan_bay.price * 5, 'arabian expensive')
    T.ok(#LXRShared.HorsesForTown('valentine') >= 30, 'valentine stock')
    T.eq(#LXRShared.HorsesForTown('colter'), 0)

    local sold = LXRShared.WagonsForShop('wagon', nil)
    for _, v in ipairs(sold) do T.ok(v.jobs == nil and not v.illegal, 'public stock ' .. v.model) end
    local forLine = LXRShared.WagonsForShop('wagon', 'stageline')
    T.ok(#forLine > #sold, 'job stock adds the stagecoaches')
    T.eq(LXRShared.GetVehicle('coach3').draft, 4)

    T.eq(LXRShared.JobHasPerm({ name = 'vallaw', grade = { level = 1 } }, 'armory'), true)
    T.eq(LXRShared.JobHasPerm({ name = 'vallaw', grade = { level = 0 } }, 'armory'), false)
    T.eq(LXRShared.JobHasPerm({ name = 'vallaw', grade = { level = 4 } }, 'manage'), true)
    T.eq(LXRShared.GangHasPerm({ name = 'wolves', grade = { level = 2 } }, 'invite'), true)
    T.eq(LXRShared.GangsAreRivals('grays', 'braithwaites'), true)
    T.eq(LXRShared.GangsAreRivals('wolves', 'grays'), false)
    T.eq(LXRShared.Items.pelt_deer.quality, true, 'graded goods')
    T.eq(LXRShared.ItemValue('pelt_deer', 1) < LXRShared.ItemValue('pelt_deer', 3), true)
end)

T.test('Roles.BuildJob exposes grade perms', function()
    local job = LXRCore.Roles.BuildJob('sdlaw', 5)
    T.eq(job.isboss, true)
    T.eq(job.grade.perms.manage, true)
    local job0 = LXRCore.Roles.BuildJob('sdlaw', 0)
    T.eq(job0.grade.perms.duty, true)
    T.eq(job0.grade.perms.armory, nil)
end)

T.test('1899 price ledger covers every item and overrides catalog values', function()
    local unpriced = LXRShared.UnpricedItems()
    if #unpriced > 0 then error('unpriced items: ' .. table.concat(unpriced, ', ', 1, math.min(#unpriced, 30))) end
    T.eq(LXRShared.Items.bread.value, 0.05)
    T.eq(LXRShared.Items.weapon_revolver_cattleman.value, 15)
    T.eq(LXRShared.Items.gold_bar.value, 661)
    T.eq(LXRShared.HorseBreeds.thoroughbred.price, 1000)
    T.eq(LXRShared.Horses.a_c_horse_arabian_white.price, 3000)
    T.eq(LXRShared.Horses.a_c_horse_morgan_bay.price, 75)
    T.eq(LXRShared.Vehicles.coach3.price, 1250)
    T.eq(LXRShared.Prices.metals.gold, 20.67)
end)
