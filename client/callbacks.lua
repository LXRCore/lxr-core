--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Callback System (client)
     ═══════════════════════════════════════════════════════════════════════════
     Ask the server:
       LXRCore.Functions.TriggerCallback('name', function(...) end, ...)   -- RSG/QBR style
       local a, b = LXRCore.Callback.Await('name', ...)                      -- yields
     Answer the server:
       LXRCore.Callback.Register('name', function(...) return ... end)
       LXRCore.Functions.CreateClientCallback('name', function(cb, ...) cb(...) end) -- RSG style
     Every request carries a unique id, so concurrent calls of the same name
     never clobber each other; a pending request is dropped after the timeout.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Callback = {}
local Callback = LXRCore.Callback

local pending = {}      -- reqId → { cb, promise, name }
local registry = {}     -- name → { fn, legacy }
local nextId = 0
local TIMEOUT = 15000

local function newRequestId()
    nextId = nextId + 1
    return ('%d:%d'):format(nextId, GetGameTimer())
end

local function settle(reqId, ok, ...)
    local req = pending[reqId]
    if not req then return end
    pending[reqId] = nil
    if not ok then
        local reason = ...
        if reason ~= 'timeout' then print(('^3[LXRCore]^7 callback "%s" failed: %s'):format(req.name, tostring(reason))) end
        if req.cb then req.cb(nil) end
        if req.promise then req.promise:resolve(table.pack(nil)) end
        return
    end
    if req.cb then req.cb(...) end
    if req.promise then req.promise:resolve(table.pack(...)) end
end

local function dispatch(name, cb, promise, ...)
    local reqId = newRequestId()
    pending[reqId] = { cb = cb, promise = promise, name = name }
    TriggerServerEvent('LXRCore:Server:Callback:Request', name, reqId, ...)
    SetTimeout(TIMEOUT, function()
        if pending[reqId] then settle(reqId, false, 'timeout') end
    end)
    return reqId
end

---RSG/QBR style: TriggerCallback(name, cb, ...)
function Callback.Trigger(name, cb, ...)
    if type(name) ~= 'string' then return end
    return dispatch(name, cb, nil, ...)
end

---Yielding variant: local a, b = LXRCore.Callback.Await('name', ...)
function Callback.Await(name, ...)
    local p = promise.new()
    dispatch(name, nil, p, ...)
    local packed = Citizen.Await(p)
    return table.unpack(packed, 1, packed.n)
end

RegisterNetEvent('LXRCore:Client:Callback:Response', function(reqId, ok, ...)
    settle(reqId, ok, ...)
end)

-- ── Server → client requests ─────────────────────────────────────────────────

function Callback.Register(name, fn)
    if type(name) ~= 'string' or type(fn) ~= 'function' then return false end
    registry[name] = { fn = fn, legacy = false }
    LXRCore.ClientCallbacks[name] = fn
    return true
end

---RSG style: fn(cb, ...) must call cb(...)
function Callback.RegisterLegacy(name, fn)
    if type(name) ~= 'string' or type(fn) ~= 'function' then return false end
    registry[name] = { fn = fn, legacy = true }
    LXRCore.ClientCallbacks[name] = fn
    return true
end

local function invoke(name, respond, ...)
    local entry = registry[name]
    if not entry then return respond(nil) end
    if entry.legacy then
        local answered = false
        local ok, err = pcall(entry.fn, function(...)
            if answered then return end
            answered = true
            respond(...)
        end, ...)
        if not ok then
            print(('^1[LXRCore]^7 client callback "%s" errored: %s'):format(name, tostring(err)))
            if not answered then respond(nil) end
        end
    else
        local results = table.pack(pcall(entry.fn, ...))
        if results[1] then respond(table.unpack(results, 2, results.n)) else respond(nil) end
    end
end

RegisterNetEvent('LXRCore:Client:Callback:Request', function(name, reqId, ...)
    invoke(name, function(...)
        TriggerServerEvent('LXRCore:Server:Callback:Response', reqId, ...)
    end, ...)
end)

-- Legacy v2 protocol (name-keyed) — answered so older servers/resources still work
RegisterNetEvent('LXRCore:Client:TriggerCallback', function(name, ...)
    local cb = LXRCore.ServerCallbacks[name]
    if cb then
        LXRCore.ServerCallbacks[name] = nil
        cb(...)
    end
end)

RegisterNetEvent('LXRCore:Client:TriggerClientCallback', function(name, ...)
    invoke(name, function(...)
        TriggerServerEvent('LXRCore:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

-- RSG / QBR-shaped aliases
LXRCore.Functions.TriggerCallback = Callback.Trigger
LXRCore.Functions.CreateClientCallback = Callback.RegisterLegacy
LXRCore.Functions.TriggerClientCallback = function(name, cb, ...)
    -- RSG signature on the client: run a locally registered client callback
    invoke(name, cb or function() end, ...)
end

exports('TriggerCallback', Callback.Trigger)
exports('AwaitCallback', Callback.Await)
exports('CreateClientCallback', Callback.RegisterLegacy)
exports('RegisterClientCallback', Callback.Register)
