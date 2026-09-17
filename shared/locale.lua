--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Locale Engine (shared)
     ═══════════════════════════════════════════════════════════════════════════
     Every player-facing string comes from locales/<lang>.lua. Locale files
     call Locale.Register('en', { ... }); the active language is selected by
     Config.Lang (falls back to 'en', then to the key itself so a missing
     translation is visible instead of crashing).

     Usage:  Lang:t('error.no_permission')           → string
             Lang:t('info.paycheck', { value = 12 })  → placeholders %{value}
     ═══════════════════════════════════════════════════════════════════════════
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale = Locale or {}
Locale.Bundles = Locale.Bundles or {}
Locale.Fallback = 'en'

---Flatten { error = { no_perm = 'x' } } into { ['error.no_perm'] = 'x' }.
local function flatten(tbl, prefix, out)
    out = out or {}
    for k, v in pairs(tbl) do
        local key = prefix and (prefix .. '.' .. tostring(k)) or tostring(k)
        if type(v) == 'table' then
            flatten(v, key, out)
        else
            out[key] = v
        end
    end
    return out
end

---Register (or extend) a language bundle. Later registrations override earlier
---keys so servers can ship a `locales/custom_en.lua` overlay.
---@param lang string
---@param phrases table
function Locale.Register(lang, phrases)
    lang = tostring(lang):lower()
    Locale.Bundles[lang] = Locale.Bundles[lang] or {}
    local flat = flatten(phrases)
    for k, v in pairs(flat) do
        Locale.Bundles[lang][k] = v
    end
end

local function interpolate(str, vars)
    if type(vars) ~= 'table' then return str end
    return (string.gsub(str, '%%{([%w_]+)}', function(name)
        local v = vars[name]
        if v == nil then return '%{' .. name .. '}' end
        return tostring(v)
    end))
end

Lang = Lang or {}

---Current language code (config-driven, safe before config loads).
---@return string
function Lang.current()
    local cfg = rawget(_G, 'Config')
    local lang = cfg and cfg.Lang
    if type(lang) ~= 'string' or lang == '' then return Locale.Fallback end
    return lang:lower()
end

---Translate `key` with optional `%{placeholders}`.
---@param self table
---@param key string
---@param vars table|nil
---@return string
function Lang.t(self, key, vars)
    -- support both Lang:t(key) and Lang.t(key)
    if type(self) == 'string' then
        vars = key
        key = self
    end
    local lang = Lang.current()
    local bundle = Locale.Bundles[lang]
    local str = bundle and bundle[key]
    if str == nil and lang ~= Locale.Fallback then
        local fb = Locale.Bundles[Locale.Fallback]
        str = fb and fb[key]
    end
    if str == nil then return key end
    return interpolate(tostring(str), vars)
end

---True when a key exists in the active or fallback bundle.
---@param key string
---@return boolean
function Lang.has(key)
    local lang = Lang.current()
    local b = Locale.Bundles[lang]
    if b and b[key] ~= nil then return true end
    local fb = Locale.Bundles[Locale.Fallback]
    return fb ~= nil and fb[key] ~= nil
end

---Return the flattened bundle for NUI consumers (copy).
---@param lang string|nil
---@return table
function Lang.bundle(lang)
    lang = (lang or Lang.current()):lower()
    local out = {}
    local fb = Locale.Bundles[Locale.Fallback]
    if fb then for k, v in pairs(fb) do out[k] = v end end
    local b = Locale.Bundles[lang]
    if b then for k, v in pairs(b) do out[k] = v end end
    return out
end

LXRCore.Lang = Lang
LXRCore.Locale = Locale
