--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Shared Bootstrap

    First file loaded on both sides. Creates the LXRCore namespace, the shared
    data container (items, jobs, gangs, weapons, horses, vehicles) and the pure
    utility functions that every other module relies on. No natives are called
    here, which keeps this file unit-testable outside the game.

    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

LXRCore = LXRCore or {}
LXRCore.Version = '3.0.0'
LXRCore.ApiLevel = 3
LXRCore.ResourceName = (GetCurrentResourceName and GetCurrentResourceName()) or 'lxr-core'
LXRCore.IsServer = (IsDuplicityVersion and IsDuplicityVersion()) or false

-- Framework identity. Server owners override the player-facing values with
-- convars in server.cfg (sv_projectName, lxr_discord) — nothing to edit here.
local function convar(name, default)
    if GetConvar then
        local v = GetConvar(name, '')
        if v ~= '' then return v end
    end
    return default
end
LXRCore.Brand = {
    framework  = 'LXRCore',
    name       = convar('sv_projectName', 'The Land of Wolves'),
    tagline    = convar('lxr_tagline', 'მგლების მიწა - რჩეულთა ადგილი!'),
    website    = 'https://www.lxrcore.com',
    discord    = convar('lxr_discord', 'https://discord.gg/wolvesland'),
    devDiscord = 'https://discord.gg/ZHMKVYyhBa',
    github     = 'https://github.com/LXRCore',
}

-- Shared data tables. Populated by shared/*.lua, mutated at runtime only through
-- the server-side registry functions (AddJob/AddItem/…) so clients stay in sync.
LXRShared = LXRShared or {}
LXRShared.Items = LXRShared.Items or {}
LXRShared.Jobs = LXRShared.Jobs or {}
LXRShared.Gangs = LXRShared.Gangs or {}
LXRShared.Weapons = LXRShared.Weapons or {}
LXRShared.Horses = LXRShared.Horses or {}
LXRShared.Vehicles = LXRShared.Vehicles or {}
LXRShared.StarterItems = LXRShared.StarterItems or {}
LXRShared.ForceJobDefaultDutyAtLogin = true
LXRCore.Shared = LXRShared

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 STRING / NUMBER UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════════

local ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
local DIGITS = '0123456789'

---Random alphabetic string of `length` characters.
---@param length integer
---@return string
function LXRShared.RandomStr(length)
    length = tonumber(length) or 0
    if length <= 0 then return '' end
    local out = {}
    for i = 1, length do
        local n = math.random(1, #ALPHA)
        out[i] = ALPHA:sub(n, n)
    end
    return table.concat(out)
end

---Random numeric string of `length` digits (string, so leading zeros survive).
---@param length integer
---@return string
function LXRShared.RandomInt(length)
    length = tonumber(length) or 0
    if length <= 0 then return '' end
    local out = {}
    for i = 1, length do
        local n = math.random(1, #DIGITS)
        out[i] = DIGITS:sub(n, n)
    end
    return table.concat(out)
end

---Split `str` on a plain (non-pattern) delimiter.
---@param str string
---@param delimiter string
---@return string[]
function LXRShared.SplitStr(str, delimiter)
    local result = {}
    if type(str) ~= 'string' then return result end
    delimiter = delimiter or ','
    local from = 1
    local dFrom, dTo = string.find(str, delimiter, from, true)
    while dFrom do
        result[#result + 1] = string.sub(str, from, dFrom - 1)
        from = dTo + 1
        dFrom, dTo = string.find(str, delimiter, from, true)
    end
    result[#result + 1] = string.sub(str, from)
    return result
end

---Trim leading/trailing whitespace. Returns nil for nil input.
---@param value string|nil
---@return string|nil
function LXRShared.Trim(value)
    if value == nil then return nil end
    return (string.gsub(tostring(value), '^%s*(.-)%s*$', '%1'))
end

---Round to `places` decimals (0 = integer). Half rounds away from zero.
---@param value number
---@param places integer|nil
---@return number
function LXRShared.Round(value, places)
    value = tonumber(value) or 0
    if not places or places <= 0 then
        if value >= 0 then return math.floor(value + 0.5) end
        return math.ceil(value - 0.5)
    end
    local mult = 10 ^ places
    if value >= 0 then return math.floor(value * mult + 0.5) / mult end
    return math.ceil(value * mult - 0.5) / mult
end

---Clamp `value` into [min, max].
---@param value number
---@param min number
---@param max number
---@return number
function LXRShared.Clamp(value, min, max)
    value = tonumber(value) or min
    if value < min then return min end
    if value > max then return max end
    return value
end

---True when `n` is a real, finite number (rejects NaN, ±inf, strings).
---@param n any
---@return boolean
function LXRShared.IsFiniteNumber(n)
    if type(n) ~= 'number' then return false end
    if n ~= n then return false end                      -- NaN
    if n == math.huge or n == -math.huge then return false end
    return true
end

---Number of entries in any table (hash or array).
---@param t table
---@return integer
function LXRShared.TableSize(t)
    if type(t) ~= 'table' then return 0 end
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

---Deep copy (tables only; functions/userdata copied by reference).
---@param src any
---@return any
function LXRShared.DeepCopy(src)
    if type(src) ~= 'table' then return src end
    local out = {}
    for k, v in pairs(src) do
        out[k] = LXRShared.DeepCopy(v)
    end
    return out
end

---Recursively fill missing keys of `target` from `defaults`. Function values in
---`defaults` are invoked lazily so per-player unique ids are only generated when
---actually needed. Existing values are never overwritten.
---@param target table
---@param defaults table
---@return table
function LXRShared.ApplyDefaults(target, defaults)
    target = target or {}
    for key, value in pairs(defaults) do
        if type(value) == 'function' then
            if target[key] == nil then target[key] = value() end
        elseif type(value) == 'table' then
            if type(target[key]) ~= 'table' then target[key] = {} end
            LXRShared.ApplyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
    return target
end

---Format 1234567.5 → "1,234,567.5".
---@param amount number
---@return string
function LXRShared.Commas(amount)
    local s = tostring(amount)
    local int, frac = s:match('^(-?%d+)(%.?%d*)$')
    if not int then return s end
    local formatted = int:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^(-?),', '%1')
    return formatted .. frac
end

---Safe JSON decode: returns fallback (default {}) on nil/invalid input.
---@param str string|nil
---@param fallback any
---@return any
function LXRShared.JsonDecode(str, fallback)
    if fallback == nil then fallback = {} end
    if type(str) == 'table' then return str end
    if type(str) ~= 'string' or str == '' then return fallback end
    local ok, result = pcall(json.decode, str)
    if ok and result ~= nil then return result end
    return fallback
end

-- Backwards-compatible aliases (legacy LXR resources call these through exports).
LXRCore.Utils = LXRShared
