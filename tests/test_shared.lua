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
