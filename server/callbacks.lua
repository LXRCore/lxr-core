--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Callback System (server)
     ═══════════════════════════════════════════════════════════════════════════
     Request/response RPC in both directions with request ids, timeouts, per-
     player rate limiting and cleanup on disconnect.

     Server callbacks (client → server):
       LXRCore.Callback.Register('name', function(source, ...) return a, b end)
       LXRCore.Functions.CreateCallback('name', function(source, cb, ...) cb(a, b) end)  -- RSG/QBR style
     Client callbacks (server → client):
       LXRCore.Callback.Trigger('name', source, function(...) end, ...)
       local a, b = LXRCore.Callback.Await('name', source, ...)   -- yields, nil on timeout
       LXRCore.Functions.TriggerClientCallback('name', source, cb, ...) -- RSG style

     Wire protocol (v3):
       C→S  lxr:rpc:request   (name, reqId, ...)
       S→C  lxr:rpc:response  (reqId, ok, ...)
       S→C  lxr:rpc:ask       (name, reqId, ...)
       C→S  lxr:rpc:answer    (reqId, ...)
     Legacy events (LXRCore:Server:TriggerCallback / RSGCore:*) are answered by
     the compat modules using the same registry.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Callback = {}
local Callback = LXRCore.Callback

local registry = {}      -- name → { fn, legacy = bool, resource }
local pending = {}       -- reqId → { cb, promise, timer, source, name }
local rateBuckets = {}
local nextId = 0

local function newRequestId()
    nextId = nextId + 1
    if nextId > 2147483000 then nextId = 1 end
    return ('%d:%d'):format(nextId, GetGameTimer())
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📥 SERVER CALLBACKS (answering the client)
-- ═══════════════════════════════════════════════════════════════════════════════

---Register a callback that returns its results.
---@param name string
---@param fn fun(source: integer, ...): ...
function Callback.Register(name, fn)
    if type(name) ~= 'string' or not LXRShared.IsCallable(fn) then
        LXRCore.Log.error('callback', 'Register: invalid arguments', { name = name })
        return false
    end
    if registry[name] and registry[name].resource ~= LXRCore.Invoker() then
        LXRCore.Log.warn('callback', ('callback "%s" re-registered by another resource'):format(name),
            { previous = registry[name].resource, now = LXRCore.Invoker() })
    end
    registry[name] = { fn = fn, legacy = false, resource = LXRCore.Invoker() }
    LXRCore.ServerCallbacks[name] = fn
    return true
end

---RSG/QBR-style registration: fn(source, cb, ...) must call cb(...) exactly once.
---@param name string
---@param fn fun(source: integer, cb: function, ...)
function Callback.RegisterLegacy(name, fn)
    if type(name) ~= 'string' or not LXRShared.IsCallable(fn) then return false end
    registry[name] = { fn = fn, legacy = true, resource = LXRCore.Invoker() }
    LXRCore.ServerCallbacks[name] = fn
    return true
end

function Callback.Unregister(name)
    registry[name] = nil
    LXRCore.ServerCallbacks[name] = nil
end

function Callback.IsRegistered(name)
    return registry[name] ~= nil
end

---Invoke a registered server callback locally; `respond` receives the results.
---Used by the net handler and by the compat layers.
---@param name string
---@param source integer
---@param respond fun(...)
function Callback.Invoke(name, source, respond, ...)
    local entry = registry[name]
    if not entry then
        LXRCore.Log.debug('callback', 'unknown server callback', { name = name, source = source })
        return false
    end
    LXRCore.Metrics.Inc('callback.server')
    if entry.legacy then
        local answered = false
        local ok, err = pcall(entry.fn, source, function(...)
            if answered then return end
            answered = true
            respond(...)
        end, ...)
        if not ok then
            LXRCore.Log.error('callback', ('server callback "%s" errored'):format(name), { error = tostring(err) })
            if not answered then respond(nil) end
        end
    else
        local results = table.pack(pcall(entry.fn, source, ...))
        if not results[1] then
            LXRCore.Log.error('callback', ('server callback "%s" errored'):format(name), { error = tostring(results[2]) })
            respond(nil)
        else
            respond(table.unpack(results, 2, results.n))
        end
    end
    return true
end

local function allowed(source)
    local rl = Config.Security.callbackRateLimit
    if not rl then return true end
    if LXRCore.RateLimit(rateBuckets, source, rl.burst, rl.windowMs) then return true end
    LXRCore.Metrics.Inc('callback.ratelimited')
    LXRCore.Log.warn('callback', 'rate limit exceeded', { source = source })
    return false
end

local function handleRequest(name, reqId, ...)
    local src = source
    if type(name) ~= 'string' or type(reqId) ~= 'string' then return end
    if not allowed(src) then
        TriggerClientEvent('lxr:rpc:response', src, reqId, false, 'rate_limited')
        return
    end
    local found = Callback.Invoke(name, src, function(...)
        TriggerClientEvent('lxr:rpc:response', src, reqId, true, ...)
    end, ...)
    if not found then
        TriggerClientEvent('lxr:rpc:response', src, reqId, false, 'unknown_callback')
    end
end
RegisterNetEvent('lxr:rpc:request', handleRequest)
RegisterNetEvent('LXRCore:Server:Callback:Request', handleRequest) -- v3.0 wire name, kept

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 CLIENT CALLBACKS (asking the client)
-- ═══════════════════════════════════════════════════════════════════════════════

local function settle(reqId, ...)
    local req = pending[reqId]
    if not req then return end
    pending[reqId] = nil
    if req.cb then
        local ok, err = pcall(req.cb, ...)
        if not ok then LXRCore.Log.error('callback', 'client callback handler errored', { name = req.name, error = tostring(err) }) end
    end
    if req.promise then req.promise:resolve(table.pack(...)) end
end

local function dispatch(name, source, cb, promise, ...)
    source = LXRCore.ToSource(source)
    if not source then
        LXRCore.Log.error('callback', 'Trigger: invalid source', { name = name })
        return nil
    end
    local reqId = newRequestId()
    pending[reqId] = { cb = cb, promise = promise, source = source, name = name, at = GetGameTimer() }
    TriggerClientEvent('lxr:rpc:ask', source, name, reqId, ...)
    local timeout = Config.Security.callbackTimeoutMs or 15000
    SetTimeout(timeout, function()
        if pending[reqId] then
            LXRCore.Metrics.Inc('callback.client.timeout')
            LXRCore.Log.warn('callback', 'client callback timed out', { name = name, source = source })
            settle(reqId, nil)
        end
    end)
    LXRCore.Metrics.Inc('callback.client')
    return reqId
end

---Ask the client and receive the answer in `cb`.
function Callback.Trigger(name, source, cb, ...)
    return dispatch(name, source, cb, nil, ...)
end

---Ask the client and yield until it answers (or timeout → nil).
function Callback.Await(name, source, ...)
    local p = promise.new()
    if not dispatch(name, source, nil, p, ...) then return nil end
    local packed = Citizen.Await(p)
    return table.unpack(packed, 1, packed.n)
end

local function handleAnswer(reqId, ...)
    local src = source
    local req = pending[reqId]
    if not req then return end
    if req.source ~= src then
        LXRCore.Log.exploit(src, 'callback response for another player', { reqId = reqId })
        return
    end
    settle(reqId, ...)
end
RegisterNetEvent('lxr:rpc:answer', handleAnswer)
RegisterNetEvent('LXRCore:Server:Callback:Response', handleAnswer) -- v3.0 wire name, kept

---Drop everything a disconnected player still owed us.
function Callback.CleanupSource(source)
    rateBuckets[source] = nil
    for reqId, req in pairs(pending) do
        if req.source == source then settle(reqId, nil) end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧩 RSG / QBR-SHAPED ALIASES
-- ═══════════════════════════════════════════════════════════════════════════════

LXRCore.Functions.CreateCallback = Callback.RegisterLegacy
LXRCore.Functions.RemoveCallback = Callback.Unregister

---RSG: TriggerCallback(name, source, cb, ...) — runs a *server* callback locally.
function LXRCore.Functions.TriggerCallback(name, source, cb, ...)
    return Callback.Invoke(name, source, cb or function() end, ...)
end

---RSG: TriggerClientCallback(name, source, cb, ...)
function LXRCore.Functions.TriggerClientCallback(name, source, cb, ...)
    return Callback.Trigger(name, source, cb, ...)
end

exports('CreateCallback', Callback.RegisterLegacy)
exports('RegisterCallback', Callback.Register)
exports('TriggerCallback', LXRCore.Functions.TriggerCallback)
exports('TriggerClientCallback', Callback.Trigger)
exports('AwaitClientCallback', Callback.Await)
