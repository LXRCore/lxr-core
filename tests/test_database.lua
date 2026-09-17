-- database layer & migrations
local Shim = ...
T.suite('database')

T.test('SplitStatements handles comments and quoted semicolons', function()
    local sql = [[
-- comment; with semicolon
CREATE TABLE a (x INT); /* block; comment */
INSERT INTO a VALUES ('a;b'); # hash comment
UPDATE a SET x = 1
]]
    local st = LXRCore.DB.SplitStatements(sql)
    T.eq(#st, 3)
    T.ok(st[2]:find("'a;b'", 1, true), 'quoted semicolon preserved')
    T.ok(st[3]:find('^UPDATE'), 'trailing statement without semicolon')
end)

T.test('Checksum is stable and 8 hex chars', function()
    T.eq(LXRCore.DB.Checksum('abc'), LXRCore.DB.Checksum('abc'))
    T.ok(LXRCore.DB.Checksum('abc'):match('^%x%x%x%x%x%x%x%x$'))
    T.ok(LXRCore.DB.Checksum('abc') ~= LXRCore.DB.Checksum('abd'))
end)

T.test('core migrations applied once, recorded, and skipped on rerun', function()
    T.eq(LXRCore.DB.Ready, true, 'boot marked db ready')
    T.ok(Shim.db.migrations['core:0001_core_schema'], '0001 recorded')
    T.ok(Shim.db.migrations['core:0002_ledger'], '0002 recorded')
    local before = #Shim.db.log
    T.eq(LXRCore.DB.Migrate(), true)
    local creates = 0
    for i = before + 1, #Shim.db.log do
        if Shim.db.log[i].query:find('^CREATE TABLE IF NOT EXISTS `players`') then creates = creates + 1 end
    end
    T.eq(creates, 0, 'players table not re-created on rerun')
end)

T.test('external migration registered after boot runs immediately', function()
    LXRCore.DB.RegisterMigration('lxr-test', '0001_x', 'CREATE TABLE IF NOT EXISTS t (id INT);')
    Shim.advance(1)
    T.ok(Shim.db.migrations['lxr-test:0001_x'])
end)

T.test('migration files only contain idempotent statements', function()
    for _, name in ipairs({ '0001_core_schema', '0002_ledger' }) do
        local sql = LoadResourceFile('lxr-core', 'database/migrations/' .. name .. '.sql')
        T.ok(sql and #sql > 100, name .. ' readable')
        for _, s in ipairs(LXRCore.DB.SplitStatements(sql)) do
            T.ok(s:match('^CREATE TABLE IF NOT EXISTS'), name .. ' only idempotent CREATEs: ' .. s:sub(1, 40))
        end
    end
end)
