--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — RedM Prompt System (client)
     ═══════════════════════════════════════════════════════════════════════════
     World-anchored hold prompts and prompt groups using RDR3 prompt natives.
     One adaptive thread: sleeps 500 ms while nothing is in range, runs per
     frame only while a prompt is active. 0.00 ms when idle.

       LXRCore.Prompts.Create('shop', coords, key, 'Open shop', { type = 'client', event = 'lxr-shop:open', args = { 'valentine' } }, distance)
       LXRCore.Prompts.CreateGroup('bank', 'Valentine Bank', coords, { { key = 0xF3830D8E, text = 'Deposit', options = {...} } })
       LXRCore.Prompts.Delete('shop') / LXRCore.Prompts.DeleteGroup('bank')

     options.type: 'client' (TriggerEvent) | 'server' (TriggerServerEvent) | 'callback' (options.event is a function)
     Legacy exports createPrompt / createPromptGroup / deletePrompt / … keep the
     QBR signatures.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Prompts = {}
local Prompts = LXRCore.Prompts
local single = {}    -- name → prompt def
local groups = {}    -- name → group def
local running = false

local function text(label)
    return CreateVarString(10, 'LITERAL_STRING', tostring(label))
end

local function register(key, label, holdMs, groupId)
    local p = PromptRegisterBegin()
    PromptSetControlAction(p, key)
    PromptSetText(p, text(label))
    PromptSetEnabled(p, false)
    PromptSetVisible(p, false)
    if holdMs and holdMs > 0 then
        PromptSetStandardizedHoldMode(p, holdMs)
    else
        PromptSetStandardMode(p, true)
    end
    if groupId then PromptSetGroup(p, groupId, 0) end
    PromptRegisterEnd(p)
    return p
end

local function completed(p, holdMs)
    if holdMs and holdMs > 0 then return PromptHasHoldModeCompleted(p) end
    return PromptHasStandardModeCompleted(p)
end

local function execute(options)
    if type(options) ~= 'table' then return end
    local args = options.args or {}
    if options.type == 'client' then
        TriggerEvent(options.event, table.unpack(args))
    elseif options.type == 'callback' and LXRShared.IsCallable(options.event) then
        -- another resource's function: give it its own thread. Called straight from our loop it cannot yield
        -- (an RPC, a Wait) — "Execution of function reference in script host failed / error object is not a string"
        local fn, n = options.event, #args
        CreateThread(function()
            local ok, err = pcall(fn, table.unpack(args, 1, n))
            if not ok then print(('^1[LXRCore]^7 prompt callback failed: %s'):format(type(err) == 'table' and json.encode(err) or tostring(err))) end
        end)
    elseif options.type == 'server' or options.type == nil then
        TriggerServerEvent(options.event, table.unpack(args))
    end
end

local function ensureLoop()
    if running then return end
    running = true
    CreateThread(function()
        while running do
            local sleep = 500
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)

            for _, def in pairs(single) do
                local dist = #(pos - def.coords)
                if dist <= def.distance then
                    sleep = 0
                    if not def.handle then def.handle = register(def.key, def.text, def.holdMs) end
                    PromptSetEnabled(def.handle, true)
                    PromptSetVisible(def.handle, true)
                    if def.marker then
                        DrawMarker(def.marker.type or 0x94FDAE17, def.coords.x, def.coords.y, def.coords.z, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.6, 244, 242, 238, 110, false, false, 2, false, nil, nil, false)
                    end
                    if completed(def.handle, def.holdMs) then
                        execute(def.options)
                        Wait(500)
                    end
                elseif def.handle then
                    PromptSetEnabled(def.handle, false)
                    PromptSetVisible(def.handle, false)
                end
            end

            for _, g in pairs(groups) do
                local dist = #(pos - g.coords)
                if dist <= g.distance then
                    sleep = 0
                    if not g.groupId then
                        g.groupId = GetRandomIntInRange(0, 0xffffff)
                        for _, item in ipairs(g.prompts) do
                            item.handle = register(item.key, item.text, item.holdMs, g.groupId)
                            PromptSetEnabled(item.handle, true)
                            PromptSetVisible(item.handle, true)
                        end
                    end
                    PromptSetActiveGroupThisFrame(g.groupId, text(g.label))
                    for _, item in ipairs(g.prompts) do
                        if completed(item.handle, item.holdMs) then
                            execute(item.options)
                            Wait(500)
                        end
                    end
                elseif g.groupId then
                    for _, item in ipairs(g.prompts) do
                        if item.handle then PromptDelete(item.handle) item.handle = nil end
                    end
                    g.groupId = nil
                end
            end

            if not next(single) and not next(groups) then
                running = false
                return
            end
            Wait(sleep)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔌 API
-- ═══════════════════════════════════════════════════════════════════════════════

---@param name string
---@param coords vector3
---@param key integer control hash (e.g. 0xF3830D8E = J)
---@param label string
---@param options table { type, event, args }
---@param distance number|nil
---@param marker table|boolean|nil
---@param holdMs number|nil  (nil → Config.Prompts.holdMs, 0 → tap)
function Prompts.Create(name, coords, key, label, options, distance, marker, holdMs)
    if single[name] then Prompts.Delete(name) end
    single[name] = {
        name = name,
        coords = vector3(coords.x, coords.y, coords.z),
        key = key,
        text = label,
        options = options,
        distance = tonumber(distance) or (Config.Prompts and Config.Prompts.distance) or 1.5,
        marker = marker == true and {} or (type(marker) == 'table' and marker or nil),
        holdMs = holdMs == nil and ((Config.Prompts and Config.Prompts.holdMs) or 1000) or holdMs,
    }
    ensureLoop()
    return true
end

function Prompts.Delete(name)
    local def = single[name]
    if not def then return false end
    if def.handle then PromptDelete(def.handle) end
    single[name] = nil
    return true
end

---@param prompts table[] { { key, text, options, holdMs } }
function Prompts.CreateGroup(name, label, coords, prompts, distance)
    if groups[name] then Prompts.DeleteGroup(name) end
    local list = {}
    for i, p in ipairs(prompts or {}) do
        list[i] = { key = p.key, text = p.text or p.label, options = p.options, holdMs = p.holdMs == nil and ((Config.Prompts and Config.Prompts.holdMs) or 1000) or p.holdMs }
    end
    groups[name] = {
        name = name, label = label, coords = vector3(coords.x, coords.y, coords.z), prompts = list,
        distance = tonumber(distance) or (Config.Prompts and Config.Prompts.distance) or 2.0,
    }
    ensureLoop()
    return true
end

function Prompts.DeleteGroup(name)
    local g = groups[name]
    if not g then return false end
    for _, item in ipairs(g.prompts) do
        if item.handle then PromptDelete(item.handle) end
    end
    groups[name] = nil
    return true
end

function Prompts.Get(name) if name then return single[name] end return single end
function Prompts.GetGroup(name) if name then return groups[name] end return groups end

---Immediate prompt without a world anchor: returns the handle for manual control.
function Prompts.Register(key, label, holdMs)
    return register(key, label, holdMs)
end

-- Clean up on resource stop so re-starting the core never leaks prompts.
AddEventHandler('onResourceStop', function(res)
    if res ~= LXRCore.ResourceName then return end
    for name in pairs(single) do Prompts.Delete(name) end
    for name in pairs(groups) do Prompts.DeleteGroup(name) end
end)

-- Legacy QBR signatures
exports('createPrompt', function(name, coords, key, label, options, marker) return Prompts.Create(name, coords, key, label, options, nil, marker) end)
exports('createPromptGroup', Prompts.CreateGroup)
exports('deletePrompt', Prompts.Delete)
exports('deletePromptGroup', Prompts.DeleteGroup)
exports('getPrompt', Prompts.Get)
exports('getPromptGroup', Prompts.GetGroup)
exports('RegisterPrompt', Prompts.Register)
