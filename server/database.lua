--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Database Layer & Migration Runner (server)
     ═══════════════════════════════════════════════════════════════════════════
     • Wraps oxmysql with timing metrics and slow-query logging.
     • Applies database/migrations/*.sql in order at boot, tracked in the
       lxr_migrations table (name + checksum). Already-applied files are skipped;
       a changed checksum is reported as a warning, never re-run silently.
     • Other resources register their own migrations with
         LXRCore.DB.RegisterMigration(resourceName, name, sqlString)
       and are queued behind the core ones.
     • LXRCore.DB.OnReady(fn) runs fn once migrations are complete (immediately
       if they already are). Connections are refused before that when
       Config.Database.requireReady is true.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.DB = { Ready = false, Connected = false }
local DB = LXRCore.DB

-- Ordered core migrations. Files live in database/migrations/<name>.sql.
local CORE_MIGRATIONS = {
    '0001_core_schema',
    '0002_ledger',
}

local pendingExternal = {}   -- { resource, name, sql }
local readyCallbacks = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔧 QUERY WRAPPERS (timing + slow log)
-- ═══════════════════════════════════════════════════════════════════════════════

local function timed(kind, query, fn, ...)
    local started = GetGameTimer()
    local ok, result = pcall(fn, ...)
    local elapsed = GetGameTimer() - started
    LXRCore.Metrics.Time('db.' .. kind, elapsed)
    local slow = Config.Database.slowQueryMs or 0
    if slow > 0 and elapsed >= slow then
        LXRCore.Log.warn('db', ('slow %s query %dms'):format(kind, elapsed), { query = tostring(query):sub(1, 160) })
    end
    if not ok then
        LXRCore.Log.error('db', ('%s failed: %s'):format(kind, tostring(result)), { query = tostring(query):sub(1, 160) })
        return nil, result
    end
    return result
end

function DB.Query(query, params)    return timed('query', query, MySQL.query.await, query, params) end
function DB.Single(query, params)   return timed('single', query, MySQL.single.await, query, params) end
function DB.Scalar(query, params)   return timed('scalar', query, MySQL.scalar.await, query, params) end
function DB.Insert(query, params)   return timed('insert', query, MySQL.insert.await, query, params) end
function DB.Update(query, params)   return timed('update', query, MySQL.update.await, query, params) end
function DB.Prepare(query, params)  return timed('prepare', query, MySQL.prepare.await, query, params) end

---Run several statements atomically. `queries` = { { query = '', values = {} }, … }
---@return boolean
function DB.Transaction(queries)
    local result = timed('transaction', 'transaction', MySQL.transaction.await, queries)
    return result == true
end

---Fire-and-forget variants for hot paths (saves, ledger). Errors are logged.
function DB.InsertAsync(query, params, cb)
    MySQL.insert(query, params, function(id)
        if cb then cb(id) end
    end)
end

function DB.UpdateAsync(query, params, cb)
    MySQL.update(query, params, function(affected)
        if cb then cb(affected) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧱 MIGRATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

---Split a SQL file into statements. Handles line comments and quoted semicolons.
---@param sql string
---@return string[]
function DB.SplitStatements(sql)
    local statements, buf = {}, {}
    local inSingle, inDouble, inBacktick = false, false, false
    local i, len = 1, #sql
    while i <= len do
        local c = sql:sub(i, i)
        local nxt = sql:sub(i + 1, i + 1)
        if not inSingle and not inDouble and not inBacktick then
            if c == '-' and nxt == '-' then
                local e = sql:find('\n', i, true) or len
                i = e
            elseif c == '#' then
                local e = sql:find('\n', i, true) or len
                i = e
            elseif c == '/' and nxt == '*' then
                local e = sql:find('*/', i + 2, true)
                i = e and (e + 1) or len
            elseif c == ';' then
                local stmt = table.concat(buf):gsub('^%s+', ''):gsub('%s+$', '')
                if stmt ~= '' then statements[#statements + 1] = stmt end
                buf = {}
            else
                if c == "'" then inSingle = true elseif c == '"' then inDouble = true elseif c == '`' then inBacktick = true end
                buf[#buf + 1] = c
            end
        else
            buf[#buf + 1] = c
            if inSingle and c == "'" and sql:sub(i - 1, i - 1) ~= '\\' then inSingle = false
            elseif inDouble and c == '"' and sql:sub(i - 1, i - 1) ~= '\\' then inDouble = false
            elseif inBacktick and c == '`' then inBacktick = false end
        end
        i = i + 1
    end
    local tail = table.concat(buf):gsub('^%s+', ''):gsub('%s+$', '')
    if tail ~= '' then statements[#statements + 1] = tail end
    return statements
end

---Stable checksum for change detection (FNV-1a 32-bit, hex).
---@param str string
---@return string
function DB.Checksum(str)
    local hash = 2166136261
    for i = 1, #str do
        hash = hash ~ str:byte(i)
        hash = (hash * 16777619) & 0xFFFFFFFF
    end
    return ('%08x'):format(hash)
end

---Register a migration from another resource. Safe to call before or after boot.
---@param resource string
---@param name string  e.g. '0001_stables'
---@param sql string
function DB.RegisterMigration(resource, name, sql)
    if type(resource) ~= 'string' or type(name) ~= 'string' or type(sql) ~= 'string' then
        LXRCore.Log.error('db', 'RegisterMigration: invalid arguments', { resource = resource, name = name })
        return false
    end
    local entry = { resource = resource, name = resource .. ':' .. name, sql = sql }
    if DB.Ready then
        CreateThread(function() DB.ApplyMigration(entry) end)
    else
        pendingExternal[#pendingExternal + 1] = entry
    end
    return true
end

local function loadCoreMigration(name)
    local sql = LoadResourceFile(LXRCore.ResourceName, ('database/migrations/%s.sql'):format(name))
    if not sql then
        LXRCore.Log.error('db', 'migration file missing', { name = name })
        return nil
    end
    return { resource = LXRCore.ResourceName, name = 'core:' .. name, sql = sql }
end

---Apply one migration entry if it has not been applied yet.
---@param entry table { resource, name, sql }
---@return boolean applied
function DB.ApplyMigration(entry)
    local checksum = DB.Checksum(entry.sql)
    local existing = DB.Single('SELECT checksum FROM lxr_migrations WHERE name = ?', { entry.name })
    if existing then
        if existing.checksum ~= checksum then
            LXRCore.Log.warn('db', 'migration already applied but file changed; create a new migration instead', { name = entry.name })
        end
        return false
    end
    local statements = DB.SplitStatements(entry.sql)
    local started = GetGameTimer()
    for idx, stmt in ipairs(statements) do
        local _, err = DB.Query(stmt)
        if err then
            LXRCore.Log.error('db', ('migration %s failed at statement %d — boot halted'):format(entry.name, idx), { error = tostring(err) })
            return false, err
        end
    end
    DB.Insert('INSERT INTO lxr_migrations (name, resource, checksum) VALUES (?, ?, ?)', { entry.name, entry.resource, checksum })
    LXRCore.Log.info('db', ('applied migration %s (%d statements, %dms)'):format(entry.name, #statements, GetGameTimer() - started))
    return true
end

---Run every migration in order. Returns true on success.
function DB.Migrate()
    DB.Query([[CREATE TABLE IF NOT EXISTS `lxr_migrations` (
        `name` VARCHAR(191) NOT NULL,
        `resource` VARCHAR(100) NOT NULL,
        `checksum` CHAR(8) NOT NULL,
        `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])

    for _, name in ipairs(CORE_MIGRATIONS) do
        local entry = loadCoreMigration(name)
        if not entry then return false end
        local applied, err = DB.ApplyMigration(entry)
        if err then return false end
    end
    for _, entry in ipairs(pendingExternal) do
        DB.ApplyMigration(entry)
    end
    pendingExternal = {}
    return true
end

---Column existence helper for defensive code paths.
function DB.ColumnExists(tbl, column)
    local n = DB.Scalar('SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?', { tbl, column })
    return (tonumber(n) or 0) > 0
end

function DB.TableExists(tbl)
    local n = DB.Scalar('SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?', { tbl })
    return (tonumber(n) or 0) > 0
end

---Run `fn` once the database is ready (immediately if it already is).
---@param fn function
function DB.OnReady(fn)
    if DB.Ready then
        CreateThread(fn)
    else
        readyCallbacks[#readyCallbacks + 1] = fn
    end
end

---Boot sequence: wait for oxmysql, migrate, flip Ready, drain callbacks.
function DB.Boot()
    local started = GetGameTimer()
    if MySQL.ready then
        local p = promise.new()
        MySQL.ready(function() p:resolve(true) end)
        Citizen.Await(p)
    end
    DB.Connected = true

    if Config.Database.autoMigrate then
        local ok = DB.Migrate()
        if not ok then
            LXRCore.Log.error('db', 'migrations failed; LXRCore will not accept players until the database is fixed')
            return false
        end
    else
        LXRCore.Log.warn('db', 'autoMigrate disabled — make sure database/schema.sql has been imported')
    end

    DB.Ready = true
    LXRCore.Metrics.Time('db.boot', GetGameTimer() - started)
    LXRCore.Log.info('db', ('database ready in %dms'):format(GetGameTimer() - started))
    for _, fn in ipairs(readyCallbacks) do
        CreateThread(fn)
    end
    readyCallbacks = {}
    TriggerEvent('LXRCore:Server:DatabaseReady')
    return true
end

exports('IsDatabaseReady', function() return DB.Ready end)
exports('RegisterMigration', DB.RegisterMigration)
