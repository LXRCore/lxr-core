--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Event Emitter (server)
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore's own event vocabulary is `lxr:<domain>:<verb>` (see docs/events.md).
     Foreign vocabularies (LXRCore:* from the QBR era, RSGCore:*) are *mirrors*
     produced here when the matching Config.Compat flag is on — nothing else in
     the core ever spells those names.

       LXRCore.Emit('lxr:player:loaded', { legacy = 'LXRCore:Server:PlayerLoaded', rsg = 'RSGCore:Server:PlayerLoaded' }, player)
       LXRCore.EmitClient(src, 'lxr:client:job', { legacy = 'LXRCore:Client:OnJobUpdate', rsg = 'RSGCore:Client:OnJobUpdate' }, job)
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local function mirrors(map)
    local out = {}
    if type(map) ~= 'table' then return out end
    if map.legacy and Config.Compat.legacy.enabled then out[#out + 1] = map.legacy end
    if map.rsg and Config.Compat.rsg.enabled then out[#out + 1] = map.rsg end
    if map.vorp and Config.Compat.vorp.enabled then out[#out + 1] = map.vorp end
    return out
end

---Fire a native server event and its compat mirrors.
---@param name string   native `lxr:*` name
---@param map table|nil { legacy = 'LXRCore:…', rsg = 'RSGCore:…', vorp = 'vorp:…' }
function LXRCore.Emit(name, map, ...)
    TriggerEvent(name, ...)
    for _, alias in ipairs(mirrors(map)) do TriggerEvent(alias, ...) end
    LXRCore.Metrics.Inc('event.' .. name)
end

---Fire a native client event (target -1 = everyone) and its compat mirrors.
function LXRCore.EmitClient(target, name, map, ...)
    target = tonumber(target)
    if not target or target == 0 then   -- the console (0) or a gone player: nothing to send to, never a native error
        if name ~= 'lxr:client:notify' then LXRCore.Log.warn('emit', ('EmitClient %s: no player target (%s)'):format(name, tostring(target))) end
        return
    end
    TriggerClientEvent(name, target, ...)
    for _, alias in ipairs(mirrors(map)) do TriggerClientEvent(alias, target, ...) end
end

---Send a notification to a player (native `lxr:client:notify`, legacy `LXRCore:Notify`).
---@param target integer|-1
---@param message string|table
---@param kind string|nil  'inform' | 'success' | 'error' | 'warning'
---@param duration integer|nil ms
function LXRCore.Notify(target, message, kind, duration)
    if tonumber(target) == 0 then   -- a console command's answer goes to the console
        local m = type(message) == 'table' and (message.description or message.text or message.title or '') or tostring(message)
        print(('^3[%s]^7 %s'):format(kind or 'inform', m))
        return
    end
    LXRCore.EmitClient(target, 'lxr:client:notify', { legacy = 'LXRCore:Notify' }, message, kind, duration)
end

---Subscribe to a native event (thin wrapper kept for symmetry with the client API).
function LXRCore.On(name, fn)
    return AddEventHandler(name, fn)
end
