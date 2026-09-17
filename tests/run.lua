--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Offline test runner
     Usage (from the lxr-core folder):  lua tests/run.lua [filter]
     Loads the real server modules through tests/lib/fxshim.lua and runs every
     tests/test_*.lua. Exit code 1 on any failure (CI-friendly).
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

package.path = './?.lua;./?/init.lua;' .. package.path
local Shim = require('tests.lib.fxshim')
Config = nil
Shim.bootCore()

T = { passed = 0, failed = 0, failures = {} }
local filter = arg and arg[1]

function T.eq(actual, expected, msg)
    if actual ~= expected then
        error(('%s — expected %s, got %s'):format(msg or 'assertion', tostring(expected), tostring(actual)), 2)
    end
end
function T.ok(v, msg) if not v then error((msg or 'expected truthy') .. ' — got ' .. tostring(v), 2) end end
function T.near(a, b, eps, msg) if math.abs(a - b) > (eps or 1e-6) then error(('%s — %s !~ %s'):format(msg or 'near', a, b), 2) end end

local currentSuite = ''
function T.suite(name) currentSuite = name end
function T.test(name, fn)
    if filter and not (currentSuite .. ' ' .. name):find(filter, 1, true) then return end
    local ok, err = xpcall(fn, debug.traceback)
    if ok then
        T.passed = T.passed + 1
        io.write(('  ^ ok   %s / %s\n'):format(currentSuite, name))
    else
        T.failed = T.failed + 1
        T.failures[#T.failures + 1] = ('%s / %s\n%s'):format(currentSuite, name, err)
        io.write(('  x FAIL %s / %s\n'):format(currentSuite, name))
    end
end

-- fresh-state helpers shared by suites
function T.newPlayer(src, license, name)
    Shim.addPlayer(src, license or ('license:' .. src), name)
    return src
end

local files = {
    'tests/test_shared.lua', 'tests/test_locale.lua', 'tests/test_database.lua', 'tests/test_roles.lua',
    'tests/test_accounts.lua', 'tests/test_inventory.lua', 'tests/test_callbacks.lua', 'tests/test_player.lua',
    'tests/test_permissions_commands.lua', 'tests/test_events.lua', 'tests/test_compat.lua',
}
for _, f in ipairs(files) do
    local chunk, err = loadfile(f)
    if not chunk then error(err) end
    chunk(Shim)
end

print(('\n%d passed, %d failed'):format(T.passed, T.failed))
for _, f in ipairs(T.failures) do print('\n' .. f) end
os.exit(T.failed == 0 and 0 or 1)
