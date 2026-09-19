--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Game script events (client)
     ═══════════════════════════════════════════════════════════════════════════
     RDR3 raises its own script events (EVENT_PED_CREATED, EVENT_ENTITY_DAMAGED,
     EVENT_PLAYER_SHOT_PED …) into an event queue the game scripts poll every
     frame. RedM does not turn those into `gameEventTriggered`, so the core
     polls the queue once for everyone:

         LXR.Game.On('EVENT_PED_CREATED', 1, function(data) ... end)   -- data[1] = the ped
         LXR.Game.Off(handle)

     One thread, running only while at least one handler exists (0.00 ms
     otherwise). `size` is how many values the event carries — read that from
     the game scripts, not guessed. Natives: rdr3natives.com
       GET_NUMBER_OF_EVENTS 0x5CE8DE5909565748 · GET_EVENT_AT_INDEX 0xA85E614430EFF816
       GET_EVENT_DATA 0x57EC5FA4D4D6AFCA (eventGroup, eventIndex, eventData*, eventDataSize)

     The data buffer is a Lua string the native writes into in place (each slot
     is an 8-byte scrValue; the int lives in the low 4 bytes) — the same trick
     the community DataView helpers rely on. In-game: NOT TESTED yet.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local N = Citizen.InvokeNative
local GROUP = 0
local handlers = {}   -- eventHash → { [handle] = { size, fn } }
local count = 0
local nextHandle = 0
local running = false

local function read(index, size)
    local buf = string.rep('\0', 8 * size)
    N(0x57EC5FA4D4D6AFCA, GROUP, index, buf, size)
    return { string.unpack('<' .. ('i4xxxx'):rep(size), buf) }
end

local function loop()
    if running then return end
    running = true
    CreateThread(function()
        while count > 0 do
            local n = N(0x5CE8DE5909565748, GROUP, Citizen.ReturnResultAnyway(), Citizen.ResultAsInteger())
            for i = 0, (n or 0) - 1 do
                local ev = N(0xA85E614430EFF816, GROUP, i, Citizen.ReturnResultAnyway(), Citizen.ResultAsInteger())
                local set = handlers[ev]
                if set then
                    local cache = {}
                    for _, h in pairs(set) do
                        local data = cache[h.size]
                        if not data then data = read(i, h.size) cache[h.size] = data end
                        local ok, err = pcall(h.fn, data, ev)
                        if not ok then LXRCore.Log.error('gameevent', 'handler failed', { event = ev, error = tostring(err) }) end
                    end
                end
            end
            Wait(0)
        end
        running = false
    end)
end

LXRCore.GameEvents = {}

---Subscribe to a game script event by name (`'EVENT_PED_CREATED'`) or hash.
---@param name string|integer
---@param size integer  how many values the event carries
---@param fn fun(data: integer[], event: integer)
---@return integer handle
function LXRCore.GameEvents.On(name, size, fn)
    local hash = type(name) == 'string' and joaat(name) or name
    if type(size) ~= 'number' or not LXRShared.IsCallable(fn) then return nil end
    nextHandle = nextHandle + 1
    handlers[hash] = handlers[hash] or {}
    handlers[hash][nextHandle] = { size = math.max(1, math.floor(size)), fn = fn, hash = hash, res = GetInvokingResource() or LXRCore.ResourceName }
    count = count + 1
    loop()
    return nextHandle
end

function LXRCore.GameEvents.Off(handle)
    for hash, set in pairs(handlers) do
        if set[handle] then
            set[handle] = nil
            count = count - 1
            if next(set) == nil then handlers[hash] = nil end
            return true
        end
    end
    return false
end

-- a resource that stops takes its handlers with it
AddEventHandler('onResourceStop', function(res)
    for hash, set in pairs(handlers) do
        for handle, h in pairs(set) do
            if h.res == res then set[handle] = nil count = count - 1 end
        end
        if next(set) == nil then handlers[hash] = nil end
    end
end)
