-- economy engine
local Shim = ...
T.suite('accounts')

local function offlinePlayer(cash, bank)
    local pd = { citizenid = 'ACC00001', source = nil, money = LXRCore.Accounts.EnsureAccounts({ cash = cash or 0, bank = bank or 0 }), charinfo = {}, job = { name = 'x', grade = { level = 0 } }, gang = {}, metadata = { xp = {}, levels = {}, rep = {} }, items = {} }
    return LXRCore.Player.CreatePlayer(pd, true)
end

T.test('Normalize validates account and amount', function()
    local A = LXRCore.Accounts
    T.eq(select(3, A.Normalize('nope', 5)), 'invalid_account')
    T.eq(select(3, A.Normalize('cash', -1)), 'invalid_amount')
    T.eq(select(3, A.Normalize('cash', 0)), 'invalid_amount')
    T.eq(select(3, A.Normalize('cash', 0/0)), 'invalid_amount')
    T.eq(select(3, A.Normalize('cash', math.huge)), 'invalid_amount')
    T.eq(select(3, A.Normalize('cash', 'abc')), 'invalid_amount')
    T.eq(select(3, A.Normalize('gold', 1.5)), 'invalid_amount', 'gold must be integer')
    local acc, amt = A.Normalize('CASH', 1.239)
    T.eq(acc, 'cash')
    T.eq(amt, 1.24, 'rounded to 2 decimals')
    T.eq(select(2, A.Normalize('cash', 0, true)), 0, 'zero allowed for Set')
end)

T.test('Add / Remove / Set respect floors and caps', function()
    local p = offlinePlayer(10, 0)
    T.eq(p.Functions.AddMoney('cash', 5, 'test'), true)
    T.eq(p.Functions.GetMoney('cash'), 15)
    local ok, err = p.Functions.RemoveMoney('cash', 20, 'test')
    T.eq(ok, false)
    T.eq(err, 'not_enough_money', 'cash cannot go negative')
    T.eq(p.Functions.GetMoney('cash'), 15, 'balance untouched on failure')
    T.eq(p.Functions.RemoveMoney('bank', 4000, 'overdraft'), true, 'bank may go negative within MinusLimit')
    T.eq(p.Functions.GetMoney('bank'), -4000)
    T.eq(p.Functions.RemoveMoney('bank', 2000, 'overdraft'), false, 'MinusLimit enforced')
    T.eq(p.Functions.SetMoney('cash', 0, 'reset'), true)
    T.eq(p.Functions.GetMoney('cash'), 0)
    T.eq(p.Functions.AddMoney('cash', Config.Money.MaxBalance + 1), false, 'cap')
    p.PlayerData.money.cash = Config.Money.MaxBalance - 1
    T.eq(p.Functions.AddMoney('cash', 5), false, 'cap on resulting balance')
end)

T.test('Transfer is atomic and validated', function()
    local a, b = offlinePlayer(100, 0), offlinePlayer(0, 0)
    b.PlayerData.citizenid = 'ACC00002'
    T.eq(LXRCore.Accounts.Transfer(a, b, 'cash', 60, 'trade'), true)
    T.eq(a.PlayerData.money.cash, 40)
    T.eq(b.PlayerData.money.cash, 60)
    T.eq(LXRCore.Accounts.Transfer(a, b, 'cash', 60, 'trade'), false, 'insufficient')
    T.eq(a.PlayerData.money.cash, 40)
    T.eq(b.PlayerData.money.cash, 60)
    T.eq(LXRCore.Accounts.Transfer(a, a, 'cash', 1), false, 'self transfer rejected')
end)

T.test('ledger batches rows and flushes on timer', function()
    LXRCore.Accounts.FlushLedger()
    Shim.db.ledger = {}
    local p = offlinePlayer(0, 0)
    p.Functions.AddMoney('cash', 10, 'quest')
    p.Functions.RemoveMoney('cash', 4, 'shop')
    T.eq(#Shim.db.ledger, 0, 'not flushed yet')
    Shim.advance(Config.Money.Ledger.flushMs + 1)
    T.eq(#Shim.db.ledger, 2)
    T.eq(Shim.db.ledger[1].operation, 'add')
    T.eq(Shim.db.ledger[2].balance, 6)
    T.eq(Shim.db.ledger[2].reason, 'shop')
end)

T.test('EnsureAccounts adds new configured accounts without touching existing', function()
    local m = LXRCore.Accounts.EnsureAccounts({ cash = 7, bank = 'garbage' })
    T.eq(m.cash, 7)
    T.eq(m.bank, 0, 'invalid stored value reset')
    T.eq(m.gold, 0, 'missing account created with start amount')
end)
