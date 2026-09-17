-- Minimal JSON encoder/decoder used only by the offline test harness
-- (the FXServer runtime provides its own `json`). © 2026 iBoss21 / LXRCore
local json = {}

local escapes = { ['"'] = '\\"', ['\\'] = '\\\\', ['\b'] = '\\b', ['\f'] = '\\f', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }

local function isArray(t)
    local n = 0
    for k in pairs(t) do
        if type(k) ~= 'number' or k <= 0 or k % 1 ~= 0 then return false end
        n = n + 1
    end
    return n == #t
end

local function encode(v, seen)
    local tv = type(v)
    if tv == 'nil' then return 'null' end
    if tv == 'boolean' then return tostring(v) end
    if tv == 'number' then
        if v ~= v or v == math.huge or v == -math.huge then return 'null' end
        if v % 1 == 0 then return ('%d'):format(v) end
        return ('%.14g'):format(v)
    end
    if tv == 'string' then return '"' .. v:gsub('[%c"\\]', function(c) return escapes[c] or ('\\u%04x'):format(c:byte()) end) .. '"' end
    if tv == 'table' then
        seen = seen or {}
        if seen[v] then error('cycle') end
        seen[v] = true
        local parts = {}
        if isArray(v) and (#v > 0 or next(v) == nil) then
            for i = 1, #v do parts[i] = encode(v[i], seen) end
            seen[v] = nil
            return '[' .. table.concat(parts, ',') .. ']'
        end
        for k, val in pairs(v) do
            parts[#parts + 1] = encode(tostring(k), seen) .. ':' .. encode(val, seen)
        end
        seen[v] = nil
        return '{' .. table.concat(parts, ',') .. '}'
    end
    return 'null'
end

function json.encode(v) return encode(v) end

local function skip(s, i)
    while true do
        local c = s:sub(i, i)
        if c == ' ' or c == '\n' or c == '\t' or c == '\r' then i = i + 1 else return i end
    end
end

local decode

local function decodeString(s, i)
    local out = {}
    i = i + 1
    while true do
        local c = s:sub(i, i)
        if c == '' then error('unterminated string') end
        if c == '"' then return table.concat(out), i + 1 end
        if c == '\\' then
            local n = s:sub(i + 1, i + 1)
            local map = { b = '\b', f = '\f', n = '\n', r = '\r', t = '\t', ['"'] = '"', ['\\'] = '\\', ['/'] = '/' }
            if n == 'u' then
                out[#out + 1] = utf8.char(tonumber(s:sub(i + 2, i + 5), 16))
                i = i + 6
            else
                out[#out + 1] = map[n] or n
                i = i + 2
            end
        else
            out[#out + 1] = c
            i = i + 1
        end
    end
end

decode = function(s, i)
    i = skip(s, i)
    local c = s:sub(i, i)
    if c == '{' then
        local obj = {}
        i = skip(s, i + 1)
        if s:sub(i, i) == '}' then return obj, i + 1 end
        while true do
            local k
            k, i = decodeString(s, skip(s, i))
            i = skip(s, i)
            assert(s:sub(i, i) == ':', 'expected :')
            local v
            v, i = decode(s, i + 1)
            obj[k] = v
            i = skip(s, i)
            local d = s:sub(i, i)
            if d == '}' then return obj, i + 1 end
            assert(d == ',', 'expected ,')
            i = i + 1
        end
    elseif c == '[' then
        local arr = {}
        i = skip(s, i + 1)
        if s:sub(i, i) == ']' then return arr, i + 1 end
        while true do
            local v
            v, i = decode(s, i)
            arr[#arr + 1] = v
            i = skip(s, i)
            local d = s:sub(i, i)
            if d == ']' then return arr, i + 1 end
            assert(d == ',', 'expected ,')
            i = i + 1
        end
    elseif c == '"' then
        return decodeString(s, i)
    elseif s:sub(i, i + 3) == 'true' then return true, i + 4
    elseif s:sub(i, i + 4) == 'false' then return false, i + 5
    elseif s:sub(i, i + 3) == 'null' then return nil, i + 4
    else
        local num = s:match('^-?%d+%.?%d*[eE]?[-+]?%d*', i)
        if not num or num == '' then error('unexpected token at ' .. i .. ': ' .. c) end
        return tonumber(num), i + #num
    end
end

function json.decode(s)
    if type(s) ~= 'string' then error('json.decode expects a string') end
    local v = decode(s, 1)
    return v
end

return json
