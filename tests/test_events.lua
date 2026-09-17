-- connection deferrals and validated net events
local Shim = ...
T.suite('events')

local function connect(src, name)
    local result
    local deferrals = {
        defer = function() end,
        update = function() end,
        done = function(msg) result = msg or 'ACCEPTED' end,
    }
    Shim.connecting = src
    Shim.netEvent(src, 'playerConnecting', name or ('P' .. src), function() end, deferrals)
    Shim.advance(5)
    Shim.connecting = nil
    return result
end

T.test('connection accepted with a license; refused without; duplicate refused', function()
    T.newPlayer(51, 'license:conn1')
    T.eq(connect(51), 'ACCEPTED')
    Shim.players[52] = { name = 'NoLicense', identifiers = {}, coords = vector3(0, 0, 0), heading = 0 }
    T.eq(connect(52), Lang:t('error.no_valid_license'))
    T.newPlayer(53, 'license:conn1')
    T.eq(connect(53), Lang:t('error.duplicate_license'))
end)

T.test('closed server blocks everyone but lxrcore.join', function()
    Config.Server.closed = true
    Config.Server.closedReason = 'closed-for-test'
    T.newPlayer(54, 'license:closed')
    local got = connect(54)
    Config.Server.closed = false
    T.eq(got, 'closed-for-test')
    Config.Server.closed = true
    Shim.aces[54]['lxrcore.join'] = true
    got = connect(54)
    Config.Server.closed = false
    T.eq(got, 'ACCEPTED')
end)

T.test('whitelist and discord requirement', function()
    Config.Server.whitelist = true
    T.newPlayer(55, 'license:wl')
    T.eq(connect(55), Lang:t('error.not_whitelisted'))
    Shim.aces[55].whitelisted = true
    T.eq(connect(55), 'ACCEPTED')
    Config.Server.whitelist = false
    Config.Server.requireDiscord = true
    T.newPlayer(56, 'license:dc')
    Shim.players[56].identifiers.discord = nil
    T.eq(connect(56), Lang:t('error.no_discord'))
    Config.Server.requireDiscord = false
end)

T.test('client SetMetaData only for whitelisted numeric keys', function()
    T.newPlayer(57, 'license:meta')
    LXRCore.Player.Login(57, false, { cid = 1, charinfo = { firstname = 'M' } })
    local p = LXRCore.Functions.GetPlayer(57)
    Shim.netEvent(57, 'LXRCore:Server:SetMetaData', 'hunger', 33)
    T.eq(p.PlayerData.metadata.hunger, 33)
    Shim.netEvent(57, 'LXRCore:Server:SetMetaData', 'isdead', true)
    T.eq(p.PlayerData.metadata.isdead, false, 'protected key untouched')
    Shim.netEvent(57, 'LXRCore:Server:SetMetaData', 'hunger', 'abc')
    T.eq(p.PlayerData.metadata.hunger, 33, 'non-number ignored')
end)

T.test('deprecated item events never mutate state', function()
    local p = LXRCore.Functions.GetPlayer(57)
    Shim.netEvent(57, 'LXRCore:Server:AddItem', 'bread', 99)
    T.eq(LXRCore.Inventory.GetItemCount(57, 'bread'), 0)
    Shim.netEvent(57, 'LXRCore:Player:GiveXp', 57, 'mining', 9999)
    T.eq(p.Functions.GetXp('mining'), 0)
end)

T.test('UseItem verifies ownership before running the handler', function()
    local used = 0
    LXRCore.Functions.CreateUseableItem('bread', function() used = used + 1 end)
    Shim.netEvent(57, 'LXRCore:Server:UseItem', { name = 'bread', slot = 1, amount = 1 })
    T.eq(used, 0, 'not owned → not used')
    LXRCore.Inventory.AddItem(57, 'bread', 1)
    Shim.netEvent(57, 'LXRCore:Server:UseItem', { name = 'bread', slot = 99, amount = 500 })
    T.eq(used, 1, 'owned → handler ran with server-side item')
end)

T.test('ToggleDuty flips duty server-side', function()
    local p = LXRCore.Functions.GetPlayer(57)
    p.Functions.SetJob('vallaw', 0)
    Shim.netEvent(57, 'LXRCore:ToggleDuty')
    T.eq(p.PlayerData.job.onduty, true)
    Shim.netEvent(57, 'LXRCore:ToggleDuty')
    T.eq(p.PlayerData.job.onduty, false)
end)

T.test('ExploitBan inserts a ban row and drops the player', function()
    Shim.dropped = {}
    Shim.db.bans = {}
    T.eq(LXRCore.Functions.ExploitBan(57, 'test-origin'), true)
    T.eq(#Shim.db.bans, 1)
    T.eq(#Shim.dropped, 1)
end)
