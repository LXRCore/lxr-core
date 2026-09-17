--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Server Core Object

    Defines the server-side LXRCore object that every other server module fills
    in. The object has two faces that share one implementation:

      • RSG/QBR-shaped surface  : LXRCore.Functions, LXRCore.Player, LXRCore.Players,
                                  LXRCore.Shared, LXRCore.Config, LXRCore.Commands
      • Native namespaced API   : LXRCore.Accounts, LXRCore.Roles, LXRCore.Perms,
                                  LXRCore.Callback, LXRCore.Items, LXRCore.Inventory,
                                  LXRCore.DB, LXRCore.Log, LXRCore.Metrics

    exports['lxr-core']:GetCoreObject() returns this table.

    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

LXRCore = LXRCore or {}
LXRCore.Config = Config
LXRCore.Shared = LXRShared

LXRCore.Functions = LXRCore.Functions or {}
LXRCore.Player = LXRCore.Player or {}
LXRCore.Players = {}            -- source → player object
LXRCore.PlayersByCitizenId = {} -- citizenid → player object (O(1) lookups)
LXRCore.PlayersByLicense = {}   -- license → player object
LXRCore.Commands = LXRCore.Commands or {}
LXRCore.UsableItems = {}
LXRCore.ServerCallbacks = {}    -- legacy name-keyed registry (still honoured)
LXRCore.ClientCallbacks = {}
LXRCore.Ready = false           -- true once the database is migrated and boot finished
LXRCore.BootTime = os.time()

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📊 METRICS — cheap counters, no timers. Read with /lxr:metrics or LXRCore.Metrics.Get()
-- ═══════════════════════════════════════════════════════════════════════════════

LXRCore.Metrics = { counters = {}, timings = {} }

function LXRCore.Metrics.Inc(name, by)
    if not Config.Performance.metrics then return end
    local c = LXRCore.Metrics.counters
    c[name] = (c[name] or 0) + (by or 1)
end

---Record a duration sample (ms). Keeps count/total/max only.
function LXRCore.Metrics.Time(name, ms)
    if not Config.Performance.metrics then return end
    local t = LXRCore.Metrics.timings[name]
    if not t then
        t = { count = 0, total = 0, max = 0 }
        LXRCore.Metrics.timings[name] = t
    end
    t.count = t.count + 1
    t.total = t.total + ms
    if ms > t.max then t.max = ms end
end

function LXRCore.Metrics.Get()
    local out = { uptime = os.time() - LXRCore.BootTime, players = 0, counters = {}, timings = {} }
    for _ in pairs(LXRCore.Players) do out.players = out.players + 1 end
    for k, v in pairs(LXRCore.Metrics.counters) do out.counters[k] = v end
    for k, v in pairs(LXRCore.Metrics.timings) do
        out.timings[k] = { count = v.count, avg = v.count > 0 and (v.total / v.count) or 0, max = v.max }
    end
    return out
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧰 SMALL SHARED HELPERS USED ACROSS SERVER MODULES
-- ═══════════════════════════════════════════════════════════════════════════════

---Normalise a source argument (number or numeric string) to a number.
---@param source any
---@return integer|nil
function LXRCore.ToSource(source)
    local n = tonumber(source)
    if not n or n <= 0 then return nil end
    return math.floor(n)
end

---Return the resource that invoked the current export/event (or 'unknown').
function LXRCore.Invoker()
    local r = GetInvokingResource and GetInvokingResource()
    return r or 'unknown'
end

---Simple sliding-window rate limiter keyed by an arbitrary id.
---@param bucket table state table owned by the caller
---@param key any
---@param burst integer
---@param windowMs integer
---@return boolean allowed
function LXRCore.RateLimit(bucket, key, burst, windowMs)
    local now = GetGameTimer()
    local entry = bucket[key]
    if not entry or now - entry.start > windowMs then
        bucket[key] = { start = now, count = 1 }
        return true
    end
    entry.count = entry.count + 1
    return entry.count <= burst
end

-- Core object export: the same table on every call, so state is shared.
local function GetCoreObject()
    return LXRCore
end
exports('GetCoreObject', GetCoreObject)
exports('GetCore', GetCoreObject)

-- Fired after every mutation of the core object so wrappers can refresh copies.
function LXRCore.NotifyObjectUpdate()
    TriggerEvent('lxr:core:updated')
    if Config.Compat.legacy.enabled then TriggerEvent('LXRCore:Server:UpdateObject') end
    if Config.Compat.rsg.enabled then TriggerEvent('RSGCore:Server:UpdateObject') end
end
