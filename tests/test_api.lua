-- native LXR API and lxr:* event vocabulary
local Shim = ...
T.suite('native api')

local SRC = 71

T.test('GetLXR export returns the native object with every module', function()
    local api = exports['lxr-core']:GetLXR()
    for _, m in ipairs({ 'Players', 'Characters', 'Economy', 'Roles', 'Permissions', 'RPC', 'Items', 'Inventory', 'Commands', 'Events', 'Database', 'Log', 'Metrics', 'Utils', 'Config', 'Shared' }) do
        T.ok(api[m], 'LXR.' .. m)
    end
    T.eq(api.Version, LXRCore.Version)
end)

T.test('lxr:player:loaded fires with a handle-compatible record; handle methods work', function()
    local loadedRec
    LXR.Events.On('lxr:player:loaded', function(rec) loadedRec = rec end)
    T.newPlayer(SRC, 'license:api', 'ApiUser')
    T.eq(LXR.Characters.Create(SRC, 1, { firstname = 'Sadie', lastname = 'Adler', gender = 1 }), true)
    T.ok(loadedRec, 'native loaded event fired')
    local p = LXR.Players.Get(SRC)
    T.ok(p, 'handle')
    T.eq(p:FullName(), 'Sadie Adler')
    T.eq(p:Source(), SRC)
    T.eq(p:CitizenId(), loadedRec.PlayerData.citizenid)
    T.eq(LXR.Players.ByCitizenId(p:CitizenId()), p, 'handles are cached per record')
    T.eq(p:Money('cash'), Config.Money.MoneyTypes.cash)
    T.eq(p:AddMoney('cash', 10, 'test'), true)
    T.eq(p:Money('cash'), Config.Money.MoneyTypes.cash + 10)
    T.eq(p:HasMoney('cash', 5), true)
    T.eq(p:SetJob('medic', 2), true)
    T.eq(p:Job().name, 'medic')
    T.eq(p:IsBoss(), true)
    T.eq(p:OnDuty(), false)
    p:SetDuty(true)
    T.eq(p:OnDuty(), true)
    local found = false
    for _, h in ipairs(LXR.Players.OnDuty('medic')) do if h == p then found = true end end
    T.ok(found, 'listed among on-duty medics')
    T.eq(p:AddItem('bread', 2), true)
    T.eq(p:Count('bread'), 2)
    T.eq(p:HasItem('bread', 2), true)
    T.eq(p:Item('bread').amount, 2)
    T.eq(p:Weight(), 400)
    p:SetMeta('hunger', 42)
    T.eq(p:Meta('hunger'), 42)
    T.eq(p:AddXp('mining', 100), true)
    T.eq(p:Level('mining'), 2)
    T.eq(p:Group(), 'user')
    p:Grant('admin')
    T.eq(p:Has('admin'), true)
    T.eq(LXR.Players.Count(), (function() local n = 0 for _ in pairs(LXRCore.Players) do n = n + 1 end return n end)())
end)

T.test('native events fire alongside compat mirrors, with the documented arguments', function()
    local got = {}
    LXR.Events.On('lxr:money:changed', function(src, account, amount, op, reason, balance) got.money = { src, account, amount, op, reason, balance } end)
    LXR.Events.On('lxr:job:changed', function(src, job) got.job = job end)
    LXR.Events.On('lxr:duty:changed', function(src, on) got.duty = on end)
    LXR.Events.On('lxr:meta:changed', function(src, key, value) got.meta = { key, value } end)
    LXR.Events.On('lxr:inventory:changed', function(src) got.inv = src end)
    local legacy = 0
    AddEventHandler('LXRCore:Server:OnMoneyChange', function() legacy = legacy + 1 end)
    AddEventHandler('RSGCore:Server:OnMoneyChange', function() legacy = legacy + 1 end)

    local p = LXR.Players.Get(SRC)
    Shim.clientEvents = {}
    p:RemoveMoney('cash', 3, 'fee')
    T.eq(got.money[2], 'cash')
    T.eq(got.money[3], 3)
    T.eq(got.money[4], 'remove')
    T.eq(got.money[5], 'fee')
    T.eq(got.money[6], p:Money('cash'), 'balance included natively')
    T.eq(legacy, 2, 'both mirrors fired while compat enabled')
    T.eq(#Shim.clientEventsNamed('lxr:client:money'), 1)
    T.eq(#Shim.clientEventsNamed('LXRCore:Client:OnMoneyChange'), 1)

    p:SetJob('vallaw', 0)
    T.eq(got.job.name, 'vallaw')
    p:SetDuty(true)
    T.eq(got.duty, true)
    p:SetMeta('thirst', 10)
    T.eq(got.meta[1], 'thirst')
    p:AddItem('water', 1)
    T.eq(got.inv, SRC)
    Shim.advance(Config.Performance.playerDataSyncMs + 1)
    T.ok(#Shim.clientEventsNamed('lxr:client:data') >= 1, 'native data push')
end)

T.test('compat mirrors stop when compat is disabled', function()
    local native, legacyN = 0, 0
    LXR.Events.On('lxr:gang:changed', function() native = native + 1 end)
    AddEventHandler('LXRCore:Server:OnGangUpdate', function() legacyN = legacyN + 1 end)
    Config.Compat.legacy.enabled = false
    Config.Compat.rsg.enabled = false
    LXR.Players.Get(SRC):SetGang('odriscoll', 1)
    Config.Compat.legacy.enabled = true
    Config.Compat.rsg.enabled = true
    T.eq(native, 1)
    T.eq(legacyN, 0)
end)

T.test('RPC vocabulary: Register answers lxr:rpc:request; Client asks via lxr:rpc:ask', function()
    Shim.clientEvents = {}
    LXR.RPC.Register('api:ping', function(src, x) return x * 2 end)
    Shim.netEvent(SRC, 'lxr:rpc:request', 'api:ping', 'r1', 21)
    local resp = Shim.clientEventsNamed('lxr:rpc:response')
    T.eq(#resp, 1)
    T.eq(resp[1].args[3], 42)
    local result
    CreateThread(function() result = LXR.RPC.Client('client:thing', SRC, 'q') end)
    local ask = Shim.clientEventsNamed('lxr:rpc:ask')[1]
    T.eq(ask.args[1], 'client:thing')
    Shim.netEvent(SRC, 'lxr:rpc:answer', ask.args[2], 'a')
    Shim.advance(5)
    T.eq(result, 'a')
end)

T.test('Events.OnNet only accepts loaded players and rate limits', function()
    local hits = 0
    LXR.Events.OnNet('lxr:test:net', function(src, v) hits = hits + 1 end, { rateLimit = { burst = 2, windowMs = 60000 } })
    Shim.netEvent(999, 'lxr:test:net', 1)
    T.eq(hits, 0, 'unloaded source ignored')
    Shim.netEvent(SRC, 'lxr:test:net', 1)
    Shim.netEvent(SRC, 'lxr:test:net', 1)
    Shim.netEvent(SRC, 'lxr:test:net', 1)
    T.eq(hits, 2, 'third call rate limited')
end)

T.test('Commands.Register and Characters/Economy helpers', function()
    local ran
    T.eq(LXR.Commands.Register({ name = 'apitest', help = 'x', handler = function(src, args) ran = args[1] end, permission = 'user' }), true)
    Shim.runCommand(SRC, 'apitest', { 'go' })
    T.eq(ran, 'go')
    T.eq(LXR.Characters.Count('license:api'), 1)
    T.newPlayer(72, 'license:api2', 'Second')
    T.eq(LXR.Characters.Create(72, 1, { firstname = 'B', lastname = 'C' }), true)
    local a, b = LXR.Players.Get(SRC), LXR.Players.Get(72)
    local before = b:Money('cash')
    T.eq(a:Pay(b, 'cash', 5, 'gift'), true)
    T.eq(b:Money('cash'), before + 5)
    T.eq(LXR.Economy.Transfer(72, SRC, 'cash', 1, 'back'), true)
    T.eq(LXR.Players.IsLoaded(72), true)
    LXR.Characters.Unload(72)
    T.eq(LXR.Players.IsLoaded(72), false)
end)
