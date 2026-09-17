-- ACE permissions and command registry
local Shim = ...
T.suite('permissions & commands')

T.test('boot created group aces (+ rsgcore aliases)', function()
    local found, alias = false, false
    for _, cmd in ipairs(Shim.executed) do
        if cmd == 'add_ace lxrcore.admin admin allow' then found = true end
        if cmd == 'add_principal rsgcore.admin lxrcore.admin' then alias = true end
    end
    T.ok(found, 'admin ace')
    T.ok(alias, 'rsgcore alias')
end)

T.test('Has / Add / Remove / Group', function()
    T.newPlayer(41, 'license:perm')
    T.eq(LXRCore.Perms.Has(41, 'admin'), false)
    T.eq(LXRCore.Perms.Add(41, 'admin'), true)
    T.eq(LXRCore.Perms.Has(41, 'admin'), true)
    T.eq(LXRCore.Perms.Has(41, { 'mod', 'admin' }), true)
    T.eq(LXRCore.Perms.Group(41), 'admin')
    T.eq(LXRCore.Perms.Get(41).admin, true)
    T.eq(LXRCore.Perms.Remove(41, 'admin'), true)
    T.eq(LXRCore.Perms.Has(41, 'admin'), false)
    T.eq(LXRCore.Perms.Group(41), 'user')
end)

T.test('Commands.Add registers, gates by ace, validates required args', function()
    local ran
    LXRCore.Commands.Add('lxrtest', 'help', { { name = 'a', help = '' } }, true, function(src, args) ran = args[1] end, 'admin')
    T.ok(Shim.commands.lxrtest, 'registered with runtime')
    T.eq(Shim.commands.lxrtest.restricted, true)
    local aceCreated = false
    for _, cmd in ipairs(Shim.executed) do if cmd == 'add_ace lxrcore.admin command.lxrtest allow' then aceCreated = true end end
    T.ok(aceCreated)
    Shim.runCommand(41, 'lxrtest', {})
    T.eq(ran, nil, 'missing args blocked')
    Shim.runCommand(41, 'lxrtest', { 'x' })
    T.eq(ran, 'x')
    -- Commands.Call honours aces
    Shim.aces[41] = {}
    T.eq(LXRCore.Commands.Call(41, 'lxrtest', { 'y' }), false)
    Shim.aces[41]['command.lxrtest'] = true
    T.eq(LXRCore.Commands.Call(41, 'lxrtest', { 'y' }), true)
    T.eq(ran, 'y')
end)

T.test('built-in admin commands operate on a loaded player', function()
    T.newPlayer(42, 'license:target', 'Target')
    T.eq(LXRCore.Player.Login(42, false, { cid = 1, charinfo = { firstname = 'T' } }), true)
    Shim.runCommand(0, 'givemoney', { '42', 'cash', '50' })
    T.eq(LXRCore.Functions.GetPlayer(42).Functions.GetMoney('cash'), Config.Money.MoneyTypes.cash + 50)
    Shim.runCommand(0, 'setmoney', { '42', 'bank', '12.5' })
    T.eq(LXRCore.Functions.GetPlayer(42).Functions.GetMoney('bank'), 12.5)
    Shim.runCommand(0, 'setjob', { '42', 'valdoc', '4' })
    T.eq(LXRCore.Functions.GetPlayer(42).PlayerData.job.isboss, true)
    Shim.runCommand(0, 'givemoney', { '42', 'cash', 'NaN' })
    T.eq(LXRCore.Functions.GetPlayer(42).Functions.GetMoney('cash'), Config.Money.MoneyTypes.cash + 50, 'invalid amount ignored')
    Shim.runCommand(0, 'closeserver', { 'maintenance' })
    T.eq(Config.Server.closed, true)
    Shim.runCommand(0, 'openserver', {})
    T.eq(Config.Server.closed, false)
end)
