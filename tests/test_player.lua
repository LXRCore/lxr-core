-- player & character lifecycle against the in-memory database
local Shim = ...
T.suite('player')

local SRC = 21

T.test('new character: Login creates row, indexes, state bags, events', function()
    T.newPlayer(SRC, 'license:abc', 'Tester')
    Shim.clientEvents = {}
    local loaded
    AddEventHandler('LXRCore:Server:PlayerLoaded', function(p) loaded = p end)
    local ok = LXRCore.Player.Login(SRC, false, { cid = 1, charinfo = { firstname = 'John', lastname = 'Marston', gender = 0, birthdate = '1873-01-01', nationality = 'USA', evil = 'ignored' } })
    T.eq(ok, true)
    local player = LXRCore.Functions.GetPlayer(SRC)
    T.ok(player, 'player registered')
    local pd = player.PlayerData
    T.eq(pd.charinfo.firstname, 'John')
    T.eq(pd.charinfo.evil, nil, 'unknown charinfo keys dropped')
    T.ok(pd.citizenid:match('^%u%u%u%d%d%d%d%d$'), 'citizenid format ' .. tostring(pd.citizenid))
    T.eq(pd.money.cash, Config.Money.MoneyTypes.cash)
    T.eq(pd.job.name, 'unemployed')
    T.eq(pd.license, 'license:abc')
    T.ok(pd.metadata.walletid and pd.metadata.fingerprint and pd.metadata.bloodtype, 'generated metadata')
    T.eq(pd.metadata.xp.main, 0)
    T.ok(Shim.db.players[pd.citizenid], 'row created on login')
    T.eq(LXRCore.PlayersByCitizenId[pd.citizenid], player)
    T.eq(LXRCore.PlayersByLicense['license:abc'], player)
    T.eq(Player(SRC).state.isLoggedIn, true)
    T.eq(Player(SRC).state.citizenid, pd.citizenid)
    T.eq(loaded, player, 'PlayerLoaded event carries the player object')
    Shim.advance(200)
    T.ok(#Shim.clientEventsNamed('LXRCore:Player:SetPlayerData') >= 1, 'PlayerData pushed to client')
    T.ok(#Shim.clientEventsNamed('RSGCore:Player:SetPlayerData') >= 1, 'RSG mirror')
end)

T.test('UpdatePlayerData is debounced into one push', function()
    Shim.clientEvents = {}
    local p = LXRCore.Functions.GetPlayer(SRC)
    p.Functions.SetMetaData('hunger', 50)
    p.Functions.SetMetaData('thirst', 40)
    p.Functions.SetMetaData('stress', 5)
    Shim.advance(Config.Performance.playerDataSyncMs + 1)
    T.eq(#Shim.clientEventsNamed('LXRCore:Player:SetPlayerData'), 1)
    T.eq(p.PlayerData.metadata.hunger, 50)
    p.Functions.SetMetaData('hunger', 500)
    T.eq(p.PlayerData.metadata.hunger, 100, 'clamped')
end)

T.test('SetJob / SetGang / duty update state bag and fire events', function()
    local p = LXRCore.Functions.GetPlayer(SRC)
    local jobEv
    AddEventHandler('LXRCore:Server:OnJobUpdate', function(src, job) jobEv = job end)
    T.eq(p.Functions.SetJob('vallaw', 1), true)
    T.eq(jobEv.grade.level, 1)
    T.eq(Player(SRC).state.job.name, 'vallaw')
    T.eq(p.Functions.SetJob('nope'), false)
    p.Functions.SetJobDuty(true)
    T.eq(p.PlayerData.job.onduty, true)
    T.eq(LXRCore.Functions.GetDutyCount('vallaw'), 1)
    T.eq(p.Functions.SetGang('odriscoll', 4), true)
    T.eq(p.PlayerData.gang.isboss, true)
end)

T.test('XP and levels', function()
    local p = LXRCore.Functions.GetPlayer(SRC)
    p.Functions.AddXp('mining', 120)
    T.eq(p.Functions.GetXp('mining'), 120)
    T.eq(p.Functions.GetLevel('mining'), 2)
    p.Functions.RemoveXp('mining', 500)
    T.eq(p.Functions.GetXp('mining'), 0)
    T.eq(p.Functions.GetLevel('mining'), 0)
end)

T.test('Save writes a full upsert with position and persists inventory', function()
    local p = LXRCore.Functions.GetPlayer(SRC)
    p.Functions.AddItem('bread', 2)
    Shim.players[SRC].coords = vector3(1.5, 2.5, 3.5)
    local before = #Shim.db.log
    T.eq(LXRCore.Player.Save(SRC, true), true)
    local upsert
    for i = before + 1, #Shim.db.log do if Shim.db.log[i].query:find('^INSERT INTO players') then upsert = Shim.db.log[i] end end
    T.ok(upsert, 'upsert issued')
    local pos = json.decode(upsert.params.position)
    T.eq(pos.x, 1.5)
    T.eq(json.decode(upsert.params.job).name, 'vallaw')
    local row = Shim.db.players[p.PlayerData.citizenid]
    T.ok(row.inventory:find('bread', 1, true), 'inventory column written')
    T.eq(p._dirty, false)
end)

T.test('periodic SaveAll writes only dirty players', function()
    local p = LXRCore.Functions.GetPlayer(SRC)
    T.eq(LXRCore.Player.SaveAll(false), 0, 'clean player skipped')
    p.Functions.AddMoney('cash', 1, 'dirty')
    T.eq(LXRCore.Player.SaveAll(false), 1)
end)

T.test('Login with someone else\'s citizenid is refused and kicked', function()
    local victimCid = LXRCore.Functions.GetPlayer(SRC).PlayerData.citizenid
    T.newPlayer(22, 'license:evil', 'Evil')
    Shim.dropped = {}
    T.eq(LXRCore.Player.Login(22, victimCid), false)
    T.eq(#Shim.dropped, 1, 'kicked')
    T.eq(LXRCore.Functions.GetPlayer(22), nil)
    T.eq(LXRCore.Player.Login(22, '../x'), false, 'malformed citizenid rejected')
end)

T.test('character switch: Logout saves and clears indexes, second Login loads DB row', function()
    local p = LXRCore.Functions.GetPlayer(SRC)
    local cid = p.PlayerData.citizenid
    p.Functions.AddMoney('bank', 77, 'x')
    -- create a second character for the same license
    T.eq(LXRCore.Player.Login(SRC, false, { cid = 2, charinfo = { firstname = 'Arthur', lastname = 'Morgan' } }), true)
    local p2 = LXRCore.Functions.GetPlayer(SRC)
    T.ok(p2.PlayerData.citizenid ~= cid, 'different character')
    T.eq(LXRCore.PlayersByCitizenId[cid], nil, 'old index cleared')
    T.eq(Shim.db.players[cid] and json.decode(Shim.db.players[cid].money).bank, 77, 'old character saved on switch')
    -- switch back to the first character from the database
    T.eq(LXRCore.Player.Login(SRC, cid), true)
    local p3 = LXRCore.Functions.GetPlayer(SRC)
    T.eq(p3.PlayerData.citizenid, cid)
    T.eq(p3.PlayerData.money.bank, 77)
    T.eq(p3.PlayerData.job.name, 'vallaw', 'job restored from row')
    T.eq(p3.PlayerData.job.onduty, false, 'ForceJobDefaultDutyAtLogin resets duty')
    T.eq(LXRCore.Player.CountCharacters('license:abc'), 2)
    T.eq(#LXRCore.Player.GetCharacters('license:abc'), 2)
end)

T.test('offline player objects load, mutate and save', function()
    local cid = LXRCore.Functions.GetPlayer(SRC).PlayerData.citizenid
    LXRCore.Player.Logout(SRC)
    T.eq(LXRCore.Functions.GetPlayer(SRC), nil)
    local off = LXRCore.Player.GetOfflinePlayer(cid)
    T.ok(off and off.Offline, 'offline object')
    T.eq(off.Functions.AddMoney('cash', 5, 'offline'), true)
    T.eq(off.Functions.Save(), true)
    T.eq(json.decode(Shim.db.players[cid].money).cash, off.PlayerData.money.cash)
    T.eq(LXRCore.Player.GetOfflinePlayer('ZZZ99999'), nil)
end)

T.test('DeleteCharacter requires ownership; ForceDelete works from console', function()
    local chars = LXRCore.Player.GetCharacters('license:abc')
    local cid = chars[1].citizenid
    T.newPlayer(23, 'license:other')
    Shim.dropped = {}
    T.eq(LXRCore.Player.DeleteCharacter(23, cid), false, 'not the owner')
    T.eq(#Shim.dropped, 1, 'owner check kicks')
    T.ok(Shim.db.players[cid], 'row still there')
    T.eq(LXRCore.Player.DeleteCharacter(SRC, cid), true)
    T.eq(Shim.db.players[cid], nil)
    local cid2 = chars[2].citizenid
    T.eq(LXRCore.Player.ForceDeleteCharacter(cid2), true)
    T.eq(Shim.db.players[cid2], nil)
    T.eq(LXRCore.Player.ForceDeleteCharacter('NOPE00000'), false)
end)

T.test('playerDropped saves synchronously and cleans indexes', function()
    T.newPlayer(31, 'license:drop', 'Dropper')
    T.eq(LXRCore.Player.Login(31, false, { cid = 1, charinfo = { firstname = 'D' } }), true)
    local cid = LXRCore.Functions.GetPlayer(31).PlayerData.citizenid
    LXRCore.Functions.GetPlayer(31).Functions.AddMoney('cash', 9, 'x')
    Shim.netEvent(31, 'playerDropped', 'quit')
    T.eq(LXRCore.Players[31], nil)
    T.eq(LXRCore.PlayersByCitizenId[cid], nil)
    T.eq(json.decode(Shim.db.players[cid].money).cash, Config.Money.MoneyTypes.cash + 9)
end)

T.test('imported VORP row (steam-keyed) is relinked to the license on first login', function()
    T.newPlayer(32, 'license:relink', 'Relinker')
    Shim.players[32].identifiers.steam = 'steam:110000'
    Shim.db.players['VORP0001'] = { citizenid = 'VORP0001', cid = 1, license = 'steam:110000', name = 'Imported', money = '{"cash":3}', charinfo = '{"firstname":"Im"}', job = '{"name":"unemployed","grade":{"level":0}}', gang = '{}', position = '{}', metadata = '{}', inventory = '[]' }
    T.eq(#LXRCore.Player.GetCharacters(32), 1, 'listed by steam before relink')
    T.eq(LXRCore.Player.Login(32, 'VORP0001'), true)
    T.eq(Shim.db.players['VORP0001'].license, 'license:relink')
    T.eq(LXRCore.Functions.GetPlayer(32).PlayerData.money.cash, 3)
    LXRCore.Player.Logout(32)
end)
