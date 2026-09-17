--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Accounts / Economy Engine (server)
     ═══════════════════════════════════════════════════════════════════════════
     Every balance mutation goes through this module. Rules enforced here, not
     in callers:
       • account must exist in Config.Money.MoneyTypes
       • amount must be a finite number > 0 (Set allows 0), integer for
         IntegerAccounts, rounded to Config.Money.Decimals otherwise
       • DontAllowMinus / MinusLimit floors, MaxBalance ceiling
       • every operation is written to lxr_ledger (batched) and broadcast as
         LXRCore:Server:OnMoneyChange / LXRCore:Client:OnMoneyChange
     Client input never reaches these functions directly: there is no net event
     that adds money. Resources call player.Functions.AddMoney server-side.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Accounts = {}
local Accounts = LXRCore.Accounts

local ledgerQueue = {}
local ledgerTimerArmed = false

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔎 VALIDATION
-- ═══════════════════════════════════════════════════════════════════════════════

local function minusAllowed(account)
    for _, a in ipairs(Config.Money.DontAllowMinus or {}) do
        if a == account then return false end
    end
    return true
end

---Validate account name and amount. Returns normalised (account, amount) or nil, err.
---@param account string
---@param amount any
---@param allowZero boolean|nil
function Accounts.Normalize(account, amount, allowZero)
    if type(account) ~= 'string' then return nil, nil, 'invalid_account' end
    account = account:lower()
    if Config.Money.MoneyTypes[account] == nil then return nil, nil, 'invalid_account' end
    amount = tonumber(amount)
    if not LXRShared.IsFiniteNumber(amount) then return nil, nil, 'invalid_amount' end
    if amount < 0 or (amount == 0 and not allowZero) then return nil, nil, 'invalid_amount' end
    if Config.Money.IntegerAccounts and Config.Money.IntegerAccounts[account] then
        if amount % 1 ~= 0 then return nil, nil, 'invalid_amount' end
    else
        amount = LXRShared.Round(amount, Config.Money.Decimals or 2)
    end
    if amount > (Config.Money.MaxBalance or math.huge) then return nil, nil, 'invalid_amount' end
    return account, amount, nil
end

---Fill missing accounts with their configured starting balance (login path).
---@param money table|nil
---@return table
function Accounts.EnsureAccounts(money)
    money = type(money) == 'table' and money or {}
    for account, start in pairs(Config.Money.MoneyTypes) do
        local v = tonumber(money[account])
        if not LXRShared.IsFiniteNumber(v) then
            money[account] = tonumber(start) or 0
        else
            money[account] = v
        end
    end
    return money
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧾 LEDGER (batched inserts)
-- ═══════════════════════════════════════════════════════════════════════════════

function Accounts.FlushLedger()
    ledgerTimerArmed = false
    if #ledgerQueue == 0 then return end
    local batch = ledgerQueue
    ledgerQueue = {}
    local values, params = {}, {}
    -- positional parameters must never contain nil (a hole would shift every
    -- following value); optional columns are passed as '' and NULLIF()ed in SQL.
    for i, row in ipairs(batch) do
        values[i] = "(?, ?, ?, ?, ?, ?, NULLIF(?, ''), NULLIF(?, ''))"
        local base = (i - 1) * 8
        params[base + 1] = row.citizenid
        params[base + 2] = row.account
        params[base + 3] = row.operation
        params[base + 4] = row.amount
        params[base + 5] = row.balance
        params[base + 6] = row.reason
        params[base + 7] = row.resource or ''
        params[base + 8] = row.counterparty or ''
    end
    LXRCore.DB.InsertAsync('INSERT INTO lxr_ledger (citizenid, account, operation, amount, balance_after, reason, resource, counterparty) VALUES ' .. table.concat(values, ','), params)
    LXRCore.Metrics.Inc('ledger.rows', #batch)
end

local function ledger(player, account, op, amount, reason, counterparty)
    local cfg = Config.Money.Ledger
    if not cfg or not cfg.enabled or not LXRCore.DB.Ready then return end
    ledgerQueue[#ledgerQueue + 1] = {
        citizenid = player.PlayerData.citizenid,
        account = account,
        operation = op,
        amount = amount,
        balance = player.PlayerData.money[account],
        reason = tostring(reason or 'unknown'):sub(1, 255),
        resource = LXRCore.Invoker() or '',
        counterparty = counterparty or '',
    }
    if #ledgerQueue >= (cfg.maxBatch or 200) then
        Accounts.FlushLedger()
    elseif not ledgerTimerArmed then
        ledgerTimerArmed = true
        SetTimeout(cfg.flushMs or 2000, Accounts.FlushLedger)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📣 CHANGE BROADCAST
-- ═══════════════════════════════════════════════════════════════════════════════

local function announce(player, account, amount, op, reason)
    local src = player.PlayerData.source
    player._dirty = true
    if player.Offline then return end
    player.Functions.UpdatePlayerData()
    TriggerEvent('LXRCore:Server:OnMoneyChange', src, account, amount, op, reason)
    TriggerClientEvent('LXRCore:Client:OnMoneyChange', src, account, amount, op, reason)
    -- HUD convention shared with RSG: (moneytype, amount, isMinus)
    TriggerClientEvent('hud:client:OnMoneyChange', src, account, amount, op == 'remove')
    if Config.Compat.rsg.enabled then
        TriggerEvent('RSGCore:Server:OnMoneyChange', src, account, amount, op, reason)
        TriggerClientEvent('RSGCore:Client:OnMoneyChange', src, account, amount, op, reason)
    end
    if Accounts.OnChanged then Accounts.OnChanged(player, account, amount, op, reason) end
    local level = amount >= (Config.Money.LogThreshold or math.huge) and 'warn' or 'info'
    LXRCore.Log[level]('money', ('%s %s %s'):format(op, LXRShared.Commas(amount), account), {
        citizenid = player.PlayerData.citizenid, source = src, balance = player.PlayerData.money[account],
        reason = reason, resource = LXRCore.Invoker(),
    }, level == 'warn')
    LXRCore.Metrics.Inc('money.' .. op)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💰 OPERATIONS
-- ═══════════════════════════════════════════════════════════════════════════════

---@return number|nil
function Accounts.Get(player, account)
    if type(account) ~= 'string' then return nil end
    return player.PlayerData.money[account:lower()]
end

---@return boolean ok, string|nil err
function Accounts.Add(player, account, amount, reason, counterparty)
    local acc, amt, err = Accounts.Normalize(account, amount)
    if not acc then return false, err end
    local money = player.PlayerData.money
    local current = tonumber(money[acc]) or 0
    if current + amt > (Config.Money.MaxBalance or math.huge) then return false, 'invalid_amount' end
    money[acc] = current + amt
    ledger(player, acc, 'add', amt, reason, counterparty)
    announce(player, acc, amt, 'add', reason or 'unknown')
    return true
end

---@return boolean ok, string|nil err
function Accounts.Remove(player, account, amount, reason, counterparty)
    local acc, amt, err = Accounts.Normalize(account, amount)
    if not acc then return false, err end
    local money = player.PlayerData.money
    local current = tonumber(money[acc]) or 0
    local after = current - amt
    if after < 0 and not minusAllowed(acc) then return false, 'not_enough_money' end
    if after < (Config.Money.MinusLimit or 0) then return false, 'not_enough_money' end
    money[acc] = after
    ledger(player, acc, 'remove', amt, reason, counterparty)
    announce(player, acc, amt, 'remove', reason or 'unknown')
    return true
end

---@return boolean ok, string|nil err
function Accounts.Set(player, account, amount, reason)
    local acc, amt, err = Accounts.Normalize(account, amount, true)
    if not acc then return false, err end
    local money = player.PlayerData.money
    local before = tonumber(money[acc]) or 0
    money[acc] = amt
    ledger(player, acc, 'set', amt, reason)
    announce(player, acc, math.abs(amt - before), amt < before and 'remove' or 'add', reason or 'set')
    TriggerEvent('LXRCore:Server:OnMoneySet', player.PlayerData.source, acc, amt, before, reason)
    return true
end

---Atomic in-memory transfer between two loaded players (same account type).
---@return boolean ok, string|nil err
function Accounts.Transfer(fromPlayer, toPlayer, account, amount, reason)
    if not fromPlayer or not toPlayer or fromPlayer == toPlayer then return false, 'invalid_amount' end
    local acc, amt, err = Accounts.Normalize(account, amount)
    if not acc then return false, err end
    local fromBal = tonumber(fromPlayer.PlayerData.money[acc]) or 0
    local toBal = tonumber(toPlayer.PlayerData.money[acc]) or 0
    if fromBal - amt < 0 and not minusAllowed(acc) then return false, 'not_enough_money' end
    if fromBal - amt < (Config.Money.MinusLimit or 0) then return false, 'not_enough_money' end
    if toBal + amt > (Config.Money.MaxBalance or math.huge) then return false, 'invalid_amount' end
    fromPlayer.PlayerData.money[acc] = fromBal - amt
    toPlayer.PlayerData.money[acc] = toBal + amt
    ledger(fromPlayer, acc, 'transfer_out', amt, reason, toPlayer.PlayerData.citizenid)
    ledger(toPlayer, acc, 'transfer_in', amt, reason, fromPlayer.PlayerData.citizenid)
    announce(fromPlayer, acc, amt, 'remove', reason or 'transfer')
    announce(toPlayer, acc, amt, 'add', reason or 'transfer')
    return true
end

---Convenience: does the player have at least `amount` in `account`?
function Accounts.Has(player, account, amount)
    local acc, amt = Accounts.Normalize(account, amount, true)
    if not acc then return false end
    return (tonumber(player.PlayerData.money[acc]) or 0) >= amt
end

exports('TransferMoney', function(fromSource, toSource, account, amount, reason)
    local a = LXRCore.Functions.GetPlayer(fromSource)
    local b = LXRCore.Functions.GetPlayer(toSource)
    if not a or not b then return false, 'not_online' end
    return Accounts.Transfer(a, b, account, amount, reason)
end)
