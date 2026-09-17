--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Structured Logging (server)
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore.Log.debug|info|warn|error(channel, message, data?)
       channel : 'player' | 'money' | 'db' | 'callback' | 'perm' | 'compat' | 'exploit' …
       data    : optional table serialised as JSON on the same line
     Console output honours Config.Log.level; every entry is also forwarded as
     the ecosystem event Config.Log.forwardEvent so external loggers (Discord
     webhooks, files) can subscribe without the core knowing about them.
     Legacy helpers ShowError / ShowSuccess / Debug are kept for old resources.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Log = {}

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4 }
local COLORS = { debug = '^5', info = '^2', warn = '^3', error = '^1' }
local EVENT_COLOR = { debug = 'lightblue', info = 'green', warn = 'orange', error = 'red' }

local function threshold()
    local lvl = Config.Log and Config.Log.level or 'info'
    return LEVELS[lvl] or LEVELS.info
end

local function encode(data)
    if data == nil then return '' end
    local ok, str = pcall(json.encode, data)
    if not ok then return ' <unserialisable>' end
    return ' ' .. str
end

local function emit(level, channel, message, data, tagEveryone)
    local numeric = LEVELS[level] or LEVELS.info
    channel = tostring(channel or 'core')
    message = tostring(message)

    if Config.Log.console ~= false and numeric >= threshold() then
        print(('%s[LXRCore]^7 [%s] ^7%s%s'):format(COLORS[level] or '^7', channel, message, encode(data)))
    end

    -- Forward to the ecosystem log event (lxr-log / rsg-log listeners). Debug is never forwarded.
    if numeric >= LEVELS.info then
        local ev = Config.Log.forwardEvent
        local title = channel:sub(1, 1):upper() .. channel:sub(2)
        local body = message .. encode(data)
        if ev then
            TriggerEvent(ev, channel, title, EVENT_COLOR[level], body, tagEveryone == true)
        end
        if Config.Log.forwardRsgEvent and Config.Compat.rsg.enabled and ev ~= 'rsg-log:server:CreateLog' then
            TriggerEvent('rsg-log:server:CreateLog', channel, title, EVENT_COLOR[level], body, tagEveryone == true)
        end
    end
    if Config.Performance.metrics then
        LXRCore.Metrics.Inc('log.' .. level)
    end
end

function LXRCore.Log.debug(channel, message, data) emit('debug', channel, message, data) end
function LXRCore.Log.info(channel, message, data, tag) emit('info', channel, message, data, tag) end
function LXRCore.Log.warn(channel, message, data, tag) emit('warn', channel, message, data, tag) end
function LXRCore.Log.error(channel, message, data, tag) emit('error', channel, message, data, tag) end

---Exploit / integrity failures: logged on their own channel, tags everyone.
---@param source integer
---@param origin string
---@param detail table|nil
function LXRCore.Log.exploit(source, origin, detail)
    if not Config.Security.logExploits then return end
    local data = detail or {}
    data.source = source
    data.name = source and GetPlayerName(source) or nil
    data.license = source and GetPlayerIdentifierByType(source, 'license') or nil
    emit('warn', 'exploit', origin, data, true)
    LXRCore.Metrics.Inc('exploit')
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧩 LEGACY HELPERS (QBR / old LXR API)
-- ═══════════════════════════════════════════════════════════════════════════════

function LXRCore.ShowError(resource, msg)
    print(('^1[%s]^7 %s'):format(resource or LXRCore.ResourceName, tostring(msg)))
end

function LXRCore.ShowSuccess(resource, msg)
    print(('^2[%s]^7 %s'):format(resource or LXRCore.ResourceName, tostring(msg)))
end

---Pretty-print any value (legacy Debug export). Depth-limited to avoid cycles.
function LXRCore.Debug(resource, obj, depth)
    if type(resource) ~= 'string' then
        depth = obj
        obj = resource
        resource = LXRCore.ResourceName
    end
    depth = depth or 3
    local seen = {}
    local function dump(v, indent, level)
        if type(v) ~= 'table' then return tostring(v) end
        if seen[v] or level > depth then return '{…}' end
        seen[v] = true
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = indent .. '  ' .. tostring(k) .. ' = ' .. dump(val, indent .. '  ', level + 1)
        end
        return '{\n' .. table.concat(parts, ',\n') .. '\n' .. indent .. '}'
    end
    print(('^5[%s:debug]^7 %s'):format(resource, dump(obj, '', 1)))
end

exports('ShowError', LXRCore.ShowError)
exports('ShowSuccess', LXRCore.ShowSuccess)
exports('Debug', LXRCore.Debug)
