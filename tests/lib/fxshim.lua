--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Offline FXServer runtime shim for unit tests
     ═══════════════════════════════════════════════════════════════════════════
     Emulates the subset of the Cfx runtime the server modules use: events,
     exports, timers (executed synchronously, in order), state bags, players,
     ACE permissions and an in-memory oxmysql (`MySQL`) that records queries and
     keeps a tiny `players` table so login/save/delete paths run for real.
     Run: lua tests/run.lua
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local Shim = {}
json = require('tests.lib.json')

-- ── clock, timers & coroutine scheduler ──────────────────────────────────────
Shim.now = 0
Shim.timers = {}   -- { at, fn }
Shim.threads = {}  -- { co, wakeAt }
function GetGameTimer() return Shim.now end
function SetTimeout(ms, fn) Shim.timers[#Shim.timers + 1] = { at = Shim.now + (ms or 0), fn = fn } end

local function runDue()
    local progressed = true
    while progressed do
        progressed = false
        -- timers become threads so they can Wait() too
        local keep = {}
        for _, t in ipairs(Shim.timers) do
            if t.at <= Shim.now then
                progressed = true
                Shim.threads[#Shim.threads + 1] = { co = coroutine.create(t.fn), wakeAt = Shim.now }
            else
                keep[#keep + 1] = t
            end
        end
        Shim.timers = keep
        local alive = {}
        for _, th in ipairs(Shim.threads) do
            if coroutine.status(th.co) ~= 'dead' and th.wakeAt <= Shim.now then
                progressed = true
                local ok, err = coroutine.resume(th.co)
                if not ok then error(err, 0) end
            end
            if coroutine.status(th.co) ~= 'dead' then alive[#alive + 1] = th end
        end
        Shim.threads = alive
    end
end

function Shim.advance(ms)
    local target = Shim.now + (ms or 0)
    runDue()
    while Shim.now < target do
        -- step to the next wake-up, never past target
        local nextAt = target
        for _, t in ipairs(Shim.timers) do if t.at < nextAt then nextAt = t.at end end
        for _, th in ipairs(Shim.threads) do if th.wakeAt > Shim.now and th.wakeAt < nextAt then nextAt = th.wakeAt end end
        Shim.now = math.max(nextAt, Shim.now + 1)
        if Shim.now > target then Shim.now = target end
        runDue()
    end
end

local mainCo = coroutine.running()
local function inThread()
    local co, isMain = coroutine.running()
    return not isMain and co ~= mainCo
end

function Wait(ms)
    if inThread() then
        for _, th in ipairs(Shim.threads) do
            if th.co == coroutine.running() then th.wakeAt = Shim.now + (ms or 0) end
        end
        coroutine.yield()
    else
        Shim.advance(ms or 0)
    end
end

function CreateThread(fn)
    local th = { co = coroutine.create(fn), wakeAt = Shim.now }
    Shim.threads[#Shim.threads + 1] = th
    if not inThread() then runDue() end
end

Citizen = {
    Await = function(p)
        local started = Shim.now
        while not p._settled do
            Wait(1)
            if Shim.now - started > 60000 then error('await timeout') end
        end
        return p._value
    end,
    InvokeNative = function() return 0 end,
}
promise = { new = function() return { _settled = false, resolve = function(self, v) self._settled = true self._value = v end } end }

-- ── resource metadata ─────────────────────────────────────────────────────────
Shim.resourceName = 'lxr-core'
function GetCurrentResourceName() return Shim.resourceName end
function IsDuplicityVersion() return true end
function GetInvokingResource() return Shim.invoker end
function GetResourceState(name) return Shim.startedResources[name] and 'started' or 'missing' end
function GetResourceMetadata(_, key) if key == 'version' then return '3.0.0' end return nil end
function GetConvar(_, default) return default end
function GetConvarInt(_, default) return default end
function LoadResourceFile(_, path)
    local f = io.open(path, 'rb')
    if not f then return nil end
    local s = f:read('a')
    f:close()
    return s
end
Shim.startedResources = {}

-- ── vectors ───────────────────────────────────────────────────────────────────
local vecmt = {}
vecmt.__index = vecmt
vecmt.__sub = function(a, b) return setmetatable({ x = a.x - b.x, y = a.y - b.y, z = a.z - b.z }, vecmt) end
vecmt.__len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end
function vector3(x, y, z) return setmetatable({ x = x, y = y, z = z }, vecmt) end
function vector4(x, y, z, w) return setmetatable({ x = x, y = y, z = z, w = w }, vecmt) end
function joaat(s) local h = 0 for i = 1, #s do h = (h + s:byte(i)) & 0xffffffff end return h end

-- ── events ────────────────────────────────────────────────────────────────────
Shim.handlers = {}
Shim.clientEvents = {}
source = 0
function AddEventHandler(name, fn) Shim.handlers[name] = Shim.handlers[name] or {} table.insert(Shim.handlers[name], fn) end
function RegisterNetEvent(name, fn) if fn then AddEventHandler(name, fn) end end
RegisterServerEvent = RegisterNetEvent
function TriggerEvent(name, ...)
    for _, fn in ipairs(Shim.handlers[name] or {}) do fn(...) end
end
---Simulate a client firing a net event
function Shim.netEvent(src, name, ...)
    local prev = source
    source = src
    TriggerEvent(name, ...)
    source = prev
end
function TriggerClientEvent(name, target, ...) Shim.clientEvents[#Shim.clientEvents + 1] = { name = name, target = target, args = table.pack(...) } end
function CancelEvent() end
function Shim.clientEventsNamed(name)
    local out = {}
    for _, e in ipairs(Shim.clientEvents) do if e.name == name then out[#out + 1] = e end end
    return out
end

-- ── exports ───────────────────────────────────────────────────────────────────
Shim.exports = {}
exports = setmetatable({}, {
    __call = function(_, name, fn) Shim.exports[Shim.resourceName .. ':' .. name] = fn end,
    __index = function(_, res)
        return setmetatable({}, { __index = function(_, name)
            local fn = Shim.exports[res .. ':' .. name]
            if not fn then error(('export %s:%s missing'):format(res, name)) end
            return function(_, ...) return fn(...) end
        end })
    end,
})

-- ── players & state bags ──────────────────────────────────────────────────────
Shim.players = {}   -- src → { name, identifiers = { license = … }, ped, coords }
Shim.aces = {}      -- src → { perm = true }
Shim.commands = {}
Shim.executed = {}
Shim.dropped = {}
GlobalState = {}
local function stateBag()
    local bag = {}
    bag.state = setmetatable({}, { __index = function(_, k) return bag._data and bag._data[k] end })
    bag._data = {}
    bag.state.set = function(_, k, v) bag._data[k] = v end
    return bag
end
Shim.bags = {}
function Player(src) Shim.bags[src] = Shim.bags[src] or stateBag() return Shim.bags[src] end
function Shim.addPlayer(src, license, name)
    Shim.players[src] = { name = name or ('Player' .. src), identifiers = { license = license, discord = 'discord:' .. src, ip = 'ip:1.1.1.1' }, coords = vector3(10.0, 20.0, 30.0), heading = 90.0 }
    Shim.aces[src] = Shim.aces[src] or {}
end
function GetPlayerIdentifierByType(src, kind) local p = Shim.players[tonumber(src)] return p and p.identifiers[kind] or nil end
function GetPlayerIdentifiers(src) local p = Shim.players[tonumber(src)] local out = {} for _, v in pairs(p and p.identifiers or {}) do out[#out + 1] = v end return out end
function GetPlayerName(src) local p = Shim.players[tonumber(src)] return p and p.name or nil end
function GetPlayers() local out = {} for src in pairs(Shim.players) do if src ~= Shim.connecting then out[#out + 1] = tostring(src) end end return out end
function GetNumPlayerIndices() local n = 0 for _ in pairs(Shim.players) do n = n + 1 end return n end
function GetPlayerPed(src) return Shim.players[tonumber(src)] and (1000 + tonumber(src)) or 0 end
function GetEntityCoords(ent) local p = Shim.players[ent - 1000] return p and p.coords or vector3(0, 0, 0) end
function GetEntityHeading(ent) local p = Shim.players[ent - 1000] return p and p.heading or 0.0 end
function GetPlayerPing() return 50 end
function DropPlayer(src, reason) Shim.dropped[#Shim.dropped + 1] = { src = src, reason = reason } Shim.players[src] = nil end
function IsPlayerAceAllowed(src, perm) local a = Shim.aces[tonumber(src)] return a ~= nil and a[perm] == true end
function ExecuteCommand(cmd)
    Shim.executed[#Shim.executed + 1] = cmd
    local src, group = cmd:match('^add_principal player%.(%d+) lxrcore%.(%S+)')
    if src then Shim.aces[tonumber(src)] = Shim.aces[tonumber(src)] or {} Shim.aces[tonumber(src)][group] = true Shim.aces[tonumber(src)]['command'] = true end
    local rsrc, rgroup = cmd:match('^remove_principal player%.(%d+) lxrcore%.(%S+)')
    if rsrc and Shim.aces[tonumber(rsrc)] then Shim.aces[tonumber(rsrc)][rgroup] = nil end
end
function RegisterCommand(name, fn, restricted) Shim.commands[name] = { fn = fn, restricted = restricted } end
function Shim.runCommand(src, name, args) local c = Shim.commands[name] assert(c, 'command ' .. name .. ' not registered') c.fn(src, args or {}, table.concat(args or {}, ' ')) end
function SetPlayerRoutingBucket() end
function SetEntityRoutingBucket() end
function GetAllObjects() return {} end
function GetAllVehicles() return {} end
function GetAllPeds() return {} end
function CreateVehicle() return 0 end
function DoesEntityExist() return false end
function TaskWarpPedIntoVehicle() end
function NetworkGetNetworkIdFromEntity(e) return e end
function GetHashKey(s) return joaat(s) end

-- ── in-memory oxmysql ─────────────────────────────────────────────────────────
Shim.db = { players = {}, bans = {}, ledger = {}, migrations = {}, log = {}, columns = { players = { weight = true, slots = true, outlawstatus = true, created_at = true }, bans = { created_at = true } }, tables = { players = true, bans = true, lxr_ledger = true, lxr_migrations = true } }
local DBI = Shim.db

local function record(q, p) DBI.log[#DBI.log + 1] = { query = q, params = p } end

local function run(query, params)
    record(query, params)
    local q = query:gsub('%s+', ' ')
    params = params or {}
    if q:find('^CREATE TABLE') then return { affectedRows = 0 } end
    if q:find('^ALTER TABLE') then return { affectedRows = 0 } end
    if q:find('FROM lxr_migrations WHERE name') then return DBI.migrations[params[1]] and { checksum = DBI.migrations[params[1]] } or nil end
    if q:find('^INSERT INTO lxr_migrations') then DBI.migrations[params[1]] = params[3] return 1 end
    if q:find('SELECT EXISTS%(SELECT 1 FROM players WHERE citizenid') then return DBI.players[params[1]] and 1 or 0 end
    if q:find('SELECT %* FROM players WHERE citizenid') then local r = DBI.players[params[1]] if not r then return nil end local c = {} for k, v in pairs(r) do c[k] = v end return c end
    if q:find('SELECT %* FROM players WHERE license') then for _, r in pairs(DBI.players) do if r.license == params[1] then local c = {} for k, v in pairs(r) do c[k] = v end return c end end return nil end
    if q:find('SELECT license FROM players WHERE citizenid') then local r = DBI.players[params[1]] return r and r.license or nil end
    if q:find('SELECT inventory FROM players WHERE citizenid') then local r = DBI.players[params[1]] return r and r.inventory or nil end
    if q:find('SELECT COUNT%(%*%) FROM players WHERE license') then local n = 0 for _, r in pairs(DBI.players) do if r.license == params[1] then n = n + 1 end end return n end
    if q:find('FROM players WHERE license = %? OR license = %? ORDER BY cid') then local out = {} for _, r in pairs(DBI.players) do if r.license == params[1] or r.license == params[2] then local c = {} for k, v in pairs(r) do c[k] = v end out[#out + 1] = c end end return out end
    if q:find('^INSERT INTO players') then
        local row = DBI.players[params.citizenid] or {}
        for k, v in pairs(params) do row[k] = v end
        row.inventory = row.inventory or '[]'
        DBI.players[params.citizenid] = row
        return 1
    end
    if q:find('^UPDATE players SET inventory') then local r = DBI.players[params[2]] if r then r.inventory = params[1] end return 1 end
    if q:find('^UPDATE players SET license') then local r = DBI.players[params[2]] if r and r.license == params[3] then r.license = params[1] end return 1 end
    if q:find('^INSERT INTO lxr_ledger') then
        local n = select(2, q:gsub("%(%?, %?, %?, %?, %?, %?, NULLIF%(%?, ''%), NULLIF%(%?, ''%)%)", '')) ; local per = 8
        for i = 0, n - 1 do DBI.ledger[#DBI.ledger + 1] = { citizenid = params[i * per + 1], account = params[i * per + 2], operation = params[i * per + 3], amount = params[i * per + 4], balance = params[i * per + 5], reason = params[i * per + 6] } end
        return 1
    end
    if q:find('FROM bans WHERE') then return nil end
    if q:find('^INSERT INTO bans') then DBI.bans[#DBI.bans + 1] = params return 1 end
    if q:find('^DELETE FROM bans') then return 1 end
    if q:find('INFORMATION_SCHEMA.COLUMNS') then local cols = DBI.columns[params[1]] return (cols and cols[params[2]]) and 1 or 0 end
    if q:find('INFORMATION_SCHEMA.TABLES') then return DBI.tables[params[1]] and 1 or 0 end
    if q:find('^DELETE FROM `players`') then DBI.players[params[1]] = nil return 1 end
    if q:find('^DELETE FROM') then return 1 end
    if q:find('SELECT license FROM players') then return nil end
    error('fake MySQL: unhandled query: ' .. q)
end

MySQL = {
    ready = function(cb) cb() end,
    query = { await = run }, single = { await = run }, scalar = { await = run },
    insert = setmetatable({ await = run }, { __call = function(_, q, p, cb) local r = run(q, p) if cb then cb(r) end end }),
    update = setmetatable({ await = run }, { __call = function(_, q, p, cb) local r = run(q, p) if cb then cb(r) end end }),
    prepare = setmetatable({ await = run }, { __call = function(_, q, p, cb) local r = run(q, p) if cb then cb(r) end end }),
    transaction = { await = function(queries) for _, e in ipairs(queries) do run(e.query, e.values) end return true end },
}
MySQL.insert = setmetatable({ await = run }, { __call = function(_, q, p, cb) local r = run(q, p) if cb then cb(r) end end })

-- ── loader ────────────────────────────────────────────────────────────────────
function Shim.load(path)
    local chunk, err = loadfile(path)
    if not chunk then error(err) end
    chunk()
end

function Shim.bootCore()
    for _, f in ipairs({
        'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'locales/ka.lua', 'config.lua',
        'shared/items.lua', 'shared/jobs.lua', 'shared/gangs.lua', 'shared/weapons.lua', 'shared/horses.lua', 'shared/vehicles.lua',
        'server/main.lua', 'server/log.lua', 'server/database.lua', 'server/callbacks.lua', 'server/permissions.lua',
        'server/commands.lua', 'server/roles.lua', 'server/accounts.lua', 'server/items.lua', 'server/player.lua',
        'server/events.lua', 'server/exports.lua', 'server/compat/rsg.lua', 'server/compat/vorp.lua', 'server/compat/legacy.lua',
        'server/boot.lua',
    }) do
        Shim.load(f)
    end
    Shim.advance(10) -- let boot thread timers run
end

return Shim
