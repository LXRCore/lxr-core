-- compatibility adapters (RSG events, VORP facade, legacy exports)
local Shim = ...
T.suite('compat')

T.test('RSG-shaped core object surface exists', function()
    local core = exports['lxr-core']:GetCoreObject()
    for _, fn in ipairs({ 'GetPlayer', 'GetPlayers', 'GetPlayerByCitizenId', 'CreateCallback', 'TriggerCallback', 'TriggerClientCallback',
        'CreateUseableItem', 'CanUseItem', 'UseItem', 'HasPermission', 'AddPermission', 'RemovePermission', 'GetPermission', 'Kick',
        'AddJob', 'AddJobs', 'RemoveJob', 'UpdateJob', 'AddGang', 'AddGangs', 'AddItem', 'AddItems', 'RemoveItem', 'UpdateItem',
        'GetIdentifier', 'GetSource', 'GetPlayersOnDuty', 'GetDutyCount', 'GetCoreVersion', 'GetPlayerByLicense', 'IsPlayerBanned',
        'SetPlayerBucket', 'GetClosestPlayer', 'AddPlayerMethod', 'AddPlayerField', 'SetMethod', 'SetField', 'CreateAccountNumber',
        'IsLicenseInUse', 'GetDatabaseInfo', 'PrepForSQL', 'ChangeWeight', 'ChangeSlots', 'IsOptin', 'ToggleOptin' }) do
        T.eq(type(core.Functions[fn]), 'function', 'Functions.' .. fn)
    end
    for _, fn in ipairs({ 'Login', 'Logout', 'CreatePlayer', 'CheckPlayerData', 'Save', 'SaveOffline', 'DeleteCharacter', 'ForceDeleteCharacter',
        'GetOfflinePlayer', 'GetPlayerByLicense', 'CreateCitizenId', 'CreateFingerId', 'CreateWalletId', 'GetTotalWeight', 'GetSlotsByItem',
        'GetFirstSlotByItem', 'SaveInventory', 'SaveOfflineInventory' }) do
        T.eq(type(core.Player[fn]), 'function', 'Player.' .. fn)
    end
    T.ok(core.Shared.Items and core.Shared.Jobs and core.Shared.Gangs and core.Config and core.Commands.Add)
end)

T.test('player object exposes the RSG method set', function()
    T.newPlayer(61, 'license:rsg', 'RsgUser')
    LXRCore.Player.Login(61, false, { cid = 1, charinfo = { firstname = 'R' } })
    local p = LXRCore.Functions.GetPlayer(61)
    for _, fn in ipairs({ 'UpdatePlayerData', 'SetJob', 'SetGang', 'HasItem', 'SetJobDuty', 'SetPlayerData', 'SetMetaData', 'GetMetaData',
        'AddRep', 'RemoveRep', 'GetRep', 'AddMoney', 'RemoveMoney', 'SetMoney', 'GetMoney', 'Save', 'Logout', 'AddMethod', 'AddField',
        'PersistStateBags', 'InitializeStateBags', 'AddItem', 'RemoveItem', 'GetItemByName', 'GetItemsByName', 'GetItemBySlot',
        'SetInventory', 'ClearInventory', 'AddXp', 'RemoveXp', 'AddJobReputation', 'UpdatePlayerItems' }) do
        T.eq(type(p.Functions[fn]), 'function', 'Functions.' .. fn)
    end
    p.Functions.AddMethod('Custom', function() return 'custom' end)
    T.eq(p.Functions.Custom(), 'custom')
end)

T.test('RSG net events are answered', function()
    Shim.clientEvents = {}
    LXRCore.Functions.CreateCallback('rsg:test', function(src, cb) cb('rsg-ok') end)
    Shim.netEvent(61, 'RSGCore:Server:TriggerCallback', 'rsg:test')
    local ev = Shim.clientEventsNamed('RSGCore:Client:TriggerCallback')
    T.eq(#ev, 1)
    T.eq(ev[1].args[2], 'rsg-ok')
    local p = LXRCore.Functions.GetPlayer(61)
    p.Functions.SetJob('medic', 0)
    Shim.netEvent(61, 'RSGCore:ToggleDuty')
    T.eq(p.PlayerData.job.onduty, true)
    Shim.netEvent(61, 'RSGCore:Server:SetMetaData', 'thirst', 10)
    T.eq(p.PlayerData.metadata.thirst, 10)
end)

T.test('money change mirrors RSG events and hud event', function()
    Shim.clientEvents = {}
    LXRCore.Functions.GetPlayer(61).Functions.AddMoney('cash', 3, 'x')
    T.eq(#Shim.clientEventsNamed('LXRCore:Client:OnMoneyChange'), 1)
    T.eq(#Shim.clientEventsNamed('RSGCore:Client:OnMoneyChange'), 1)
    T.eq(#Shim.clientEventsNamed('hud:client:OnMoneyChange'), 1)
end)

T.test('VORP facade: getUser / getUsedCharacter / currencies / callbacks', function()
    local Core = exports['lxr-core']:GetVorpCore()
    local user = Core.getUser(61)
    T.ok(user, 'user')
    local ch = user.getUsedCharacter
    T.eq(ch.firstname, 'R')
    T.eq(ch.job, 'medic')
    local before = ch.money
    ch.addCurrency(0, 10)
    T.eq(LXRCore.Functions.GetPlayer(61).PlayerData.money.cash, before + 10)
    ch.addCurrency(1, 2)
    T.eq(LXRCore.Functions.GetPlayer(61).PlayerData.money.gold, 2)
    T.eq(ch.addCurrency(1, 1.5), false, 'gold integer rule applies through facade')
    ch.removeCurrency(2, 5)
    T.eq(LXRCore.Functions.GetPlayer(61).PlayerData.money[Config.Compat.vorp.rolAccount], 0, 'rol cannot go negative')
    T.eq(Core.getUser(999), nil)
    T.eq(Core.getUserByCharId(LXRCore.Functions.GetPlayer(61).PlayerData.citizenid).source, 61)
    Shim.clientEvents = {}
    Core.Callback.Register('vorp:test', function(src, cb, a) cb(a .. '!') end)
    Shim.netEvent(61, 'vorp:TriggerServerCallback', 'vorp:test', 'uid-1', false, 'hi')
    local ev = Shim.clientEventsNamed('vorp:ServerCallback')
    T.eq(#ev, 1)
    T.eq(ev[1].args[1], 'uid-1')
    T.eq(ev[1].args[4], 'hi!')
    T.eq(Player(61).state.IsInSession, true, 'VORP session state bag')
    T.eq(Player(61).state.Character.CharId, LXRCore.Functions.GetPlayer(61).PlayerData.citizenid)
end)

T.test('VORP RegisterJobs maps into the shared registry', function()
    local Core = exports['lxr-core']:GetVorpCore()
    Core.RegisterJobs({ vorpjob = { grades = { [0] = { label = 'Newbie' }, [1] = { label = 'Pro' } } } }, 'vorp_test')
    T.ok(LXRShared.Jobs.vorpjob)
    T.eq(LXRShared.Jobs.vorpjob.grades['1'].name, 'Pro')
    T.ok(Core.GetRegisteredJobs('vorpjob'))
end)

T.test('legacy export-per-function surface', function()
    local E = exports['lxr-core']
    T.eq(E:GetPlayer(61).PlayerData.source, 61)
    T.eq(type(E:GetLXRPlayers()), 'table')
    T.eq(E:GetIdentifier(61, 'license'), 'license:rsg')
    T.eq(#E:RandomStr(4), 4)
    T.eq(E:GetConfig().Lang, 'en')
    T.ok(E:GetItems().bread)
    T.eq(E:AddMoney(61, 'cash', 1, 't'), true)
    T.eq(E:GetMoney(61, 'cash'), LXRCore.Functions.GetPlayer(61).PlayerData.money.cash)
    T.eq(E:IsPlayerLoaded(61), true)
    T.eq(E:IsPlayerLoaded(999), false)
    T.eq(E:HasPermission(61, 'admin'), false)
    T.eq(E:GetInventoryProvider(), 'core')
end)
