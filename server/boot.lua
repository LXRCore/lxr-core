--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Boot Sequence (server)
     ═══════════════════════════════════════════════════════════════════════════
     Last server file. Order matters:
       1. permissions (aces)           4. built-in commands
       2. database + migrations        5. loops (save / paycheck)
       3. schema safety net            6. Ready flag + console banner
     Nothing before step 6 accepts a login; connections are deferred by
     server/events.lua while Config.Database.requireReady is true.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local function ensureColumns()
    -- Upgrades from v1/v2 LXR, QBR or RSG databases that predate these columns.
    local wanted = {
        { 'weight', ('INT(11) NOT NULL DEFAULT %d'):format(Config.Player.maxWeight) },
        { 'slots', ('INT(11) NOT NULL DEFAULT %d'):format(Config.Player.maxSlots) },
        { 'outlawstatus', 'INT(11) NOT NULL DEFAULT 0' },
        { 'created_at', 'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP' },
    }
    for _, col in ipairs(wanted) do
        if not LXRCore.DB.ColumnExists('players', col[1]) then
            LXRCore.DB.Query(('ALTER TABLE `players` ADD COLUMN `%s` %s'):format(col[1], col[2]))
            LXRCore.Log.info('db', ('added missing players.%s column'):format(col[1]))
        end
    end
    if not LXRCore.DB.ColumnExists('bans', 'created_at') then
        LXRCore.DB.Query('ALTER TABLE `bans` ADD COLUMN `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP')
    end
end

local function accountList()
    local t = {}
    for k in pairs(Config.Money.MoneyTypes) do t[#t + 1] = k end
    table.sort(t)
    return table.concat(t, ', ')
end

local function banner()
    if not Config.Debug.printBanner then return end
    local inv = LXRCore.Inventory.Provider .. (LXRCore.Inventory.Resource and (' / ' .. LXRCore.Inventory.Resource) or '')
    local on = function(b) return b and '^2ENABLED^7' or '^1DISABLED^7' end
    print([[
^5    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝^7]])
    print(('^5🐺 LXRCore^7 ^3v%s^7 — %s'):format(LXRCore.Version, Config.ServerInfo.name))
    print(('   ^3Language:^7 ^6%s^7   ^3Inventory:^7 ^6%s^7   ^3Save every:^7 ^6%d min^7'):format(Config.Lang, inv, Config.General.saveInterval))
    print(('   ^3Accounts:^7 ^6%s^7'):format(accountList()))
    print(('   ^3Compat:^7 RSG %s  VORP %s  Legacy %s   ^3Ledger:^7 %s'):format(on(Config.Compat.rsg.enabled), on(Config.Compat.vorp.enabled), on(Config.Compat.legacy.enabled), on(Config.Money.Ledger.enabled)))
    print('   ^3Website:^7 ^6https://www.lxrcore.com^7   ^3Discord:^7 ^6https://discord.gg/ZHMKVYyhBa^7')
    print('^5═══════════════════════════════════════════════════════════════════════════════^7')
end

CreateThread(function()
    local started = GetGameTimer()
    if LXRCore.ResourceName ~= 'lxr-core' then
        LXRCore.Log.warn('core', ('resource folder is "%s"; other resources expect "lxr-core"'):format(LXRCore.ResourceName))
    end
    if GetConvar('onesync', 'off') == 'off' then
        LXRCore.Log.error('core', 'OneSync is off. Set onesync to "on" (infinity) in txAdmin / server.cfg')
    end

    LXRCore.Perms.Boot()
    if not LXRCore.DB.Boot() then return end
    ensureColumns()
    LXRCore.Inventory.Resolve()
    LXRCore.Commands.RegisterBuiltins()
    LXRCore.Player.StartLoops()
    LXRCore.Ready = true
    GlobalState['Count:Players'] = GetNumPlayerIndices()
    GlobalState.LXRCoreReady = true
    LXRCore.Metrics.Time('core.boot', GetGameTimer() - started)
    banner()
    LXRCore.Log.info('core', ('ready in %dms'):format(GetGameTimer() - started))
    LXRCore.Emit('lxr:core:ready', { legacy = 'LXRCore:Server:Ready' })
end)

exports('IsReady', function() return LXRCore.Ready end)
