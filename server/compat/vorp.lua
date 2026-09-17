--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Compatibility Adapter: VORP Core (server)
     ═══════════════════════════════════════════════════════════════════════════
     Builds a vorp_core-shaped core object (`exports.vorp_core:GetCore()` via
     bridges/vorp_core) on top of LXRCore players:

       Core.getUser(src) → { source, getUsedCharacter = { …fields…, addCurrency,
                             removeCurrency, setJob, setJobGrade, setGroup, … } }
       Core.Callback.Register / TriggerAsync / TriggerAwait
       Core.NotifyLeft / NotifyTip / … (routed to LXRCore:Notify)
       Core.RegisterJobs / GetRegisteredJobs, Core.Player.Heal/Revive/Respawn

     Currency ids: 0 → cash, 1 → gold, 2 → Config.Compat.vorp.rolAccount.
     Group: derived from ACE permissions (admin/mod/… else 'user').

     Explicitly NOT emulated (VORP resources doing these need a real VORP):
       • direct SQL against `characters` / `users` tables
       • character skin/comps storage (use lxr-clothing / rsg-appearance)
       • whitelist tables (Core.Whitelist.* return nil)
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not Config.Compat.vorp.enabled then return end

LXRCore.Compat = LXRCore.Compat or {}
local Vorp = { Core = {}, RegisteredJobs = {} }
LXRCore.Compat.Vorp = Vorp
local Core = Vorp.Core

local CURRENCY = { [0] = 'cash', [1] = 'gold', [2] = Config.Compat.vorp.rolAccount or 'bloodmoney' }

local function notify(src, text, kind)
    TriggerClientEvent('LXRCore:Notify', src, tostring(text or ''), kind or 'inform')
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 👤 CHARACTER FACADE
-- ═══════════════════════════════════════════════════════════════════════════════

local function buildCharacter(player)
    local pd = player.PlayerData
    local src = pd.source
    local c = {
        identifier = pd.license,
        charIdentifier = pd.citizenid,
        group = LXRCore.Perms.Group(src),
        job = pd.job.name,
        jobLabel = pd.job.label,
        jobGrade = pd.job.grade.level,
        money = pd.money.cash or 0,
        gold = pd.money.gold or 0,
        rol = pd.money[CURRENCY[2]] or 0,
        xp = pd.metadata.xp and pd.metadata.xp.main or 0,
        healthOuter = pd.metadata.health, healthInner = 100, staminaOuter = 100, staminaInner = 100,
        firstname = pd.charinfo.firstname,
        lastname = pd.charinfo.lastname,
        inventory = '{}',
        status = json.encode(pd.metadata.status or {}),
        coords = json.encode(pd.position or {}),
        isdead = pd.metadata.isdead == true,
        skin = '{}', comps = '{}', compTints = '{}',
        age = pd.charinfo.birthdate,
        gender = tostring(pd.charinfo.gender),
        charDescription = '',
        nickname = pd.charinfo.firstname,
        invCapacity = pd.slots,
        skills = pd.metadata.xp or {},
        multiJobs = {},
        source = src,
    }

    c.addCurrency = function(currency, quantity)
        local acc = CURRENCY[tonumber(currency)]
        if not acc then return false end
        return player.Functions.AddMoney(acc, quantity, 'vorp:addCurrency')
    end
    c.removeCurrency = function(currency, quantity)
        local acc = CURRENCY[tonumber(currency)]
        if not acc then return false end
        return player.Functions.RemoveMoney(acc, quantity, 'vorp:removeCurrency')
    end
    c.setMoney = function(v) return player.Functions.SetMoney('cash', v, 'vorp:setMoney') end
    c.setGold = function(v) return player.Functions.SetMoney('gold', v, 'vorp:setGold') end
    c.setRol = function(v) return player.Functions.SetMoney(CURRENCY[2], v, 'vorp:setRol') end
    c.addXp = function(v) return player.Functions.AddXp('main', v) end
    c.removeXp = function(v) return player.Functions.RemoveXp('main', v) end
    c.setXp = function(v)
        local cur = player.Functions.GetXp('main')
        if v > cur then player.Functions.AddXp('main', v - cur) elseif v < cur then player.Functions.RemoveXp('main', cur - v) end
    end
    c.setJob = function(job) return player.Functions.SetJob(job, pd.job.grade.level) end
    c.setJobGrade = function(grade) return player.Functions.SetJob(pd.job.name, grade) end
    c.setJobLabel = function() return false end -- labels come from the shared registry
    c.setGroup = function(group)
        LXRCore.Log.warn('compat', 'vorp setGroup ignored: groups are ACE principals in LXRCore', { group = group, source = src })
        return false
    end
    c.setMultiJob = function() return false end
    c.removeMultiJob = function() return false end
    c.getMultiJobsCount = function() return 0 end
    c.setFirstname = function(v) pd.charinfo.firstname = tostring(v) player.Functions.UpdatePlayerData() end
    c.setLastname = function(v) pd.charinfo.lastname = tostring(v) player.Functions.UpdatePlayerData() end
    c.setAge = function(v) pd.charinfo.birthdate = tostring(v) player.Functions.UpdatePlayerData() end
    c.setGender = function(v) pd.charinfo.gender = v player.Functions.UpdatePlayerData() end
    c.setCharDescription = function() end
    c.setNickName = function() end
    c.setStatus = function(status) player.Functions.SetMetaData('status', LXRShared.JsonDecode(status, {})) end
    c.updateInvCapacity = function(slots) LXRCore.Functions.ChangeSlots(src, (pd.slots or 0) + (tonumber(slots) or 0)) end
    c.updateSkin = function() end
    c.updateComps = function() end
    c.updateCompTints = function() end
    c.setSkills = function() end
    return c
end

local function buildUser(player)
    local pd = player.PlayerData
    local src = pd.source
    local user = {
        source = src,
        getCharperm = Config.Player.maxCharacters,
        getGroup = LXRCore.Perms.Group(src),
        getUsedCharacter = buildCharacter(player),
        getUserCharacters = {},
        maxJobsAllowed = 1,
    }
    user.getIdentifier = function() return pd.license end
    user.getPlayerwarnings = function() return 0 end
    user.setPlayerWarnings = function() end
    user.setGroup = function(group) LXRCore.Log.warn('compat', 'vorp user.setGroup ignored', { group = group }) end
    user.setCharperm = function() end
    user.setMaxJobsAllowed = function() end
    user.getNumOfCharacters = function() return LXRCore.Player.CountCharacters(pd.license) end
    user.addCharacter = function() end
    user.removeCharacter = function(charid) LXRCore.Player.DeleteCharacter(src, tostring(charid)) end
    user.setUsedCharacter = function(charid) LXRCore.Player.Login(src, tostring(charid)) end
    return user
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧩 CORE FACADE
-- ═══════════════════════════════════════════════════════════════════════════════

function Core.maxCharacters() return Config.Player.maxCharacters end

function Core.getUsers()
    local out = {}
    for src, player in pairs(LXRCore.Players) do out[player.PlayerData.license] = buildUser(player) end
    return out
end

function Core.getUser(src)
    local player = LXRCore.Functions.GetPlayer(src)
    if not player then return nil end
    return buildUser(player)
end

function Core.getUserByCharId(charid)
    local player = LXRCore.Functions.GetPlayerByCitizenId(tostring(charid))
    if not player then return nil end
    return buildUser(player)
end

-- Notifications → unified LXRCore notify
Core.NotifyTip = function(src, text) notify(src, text) end
Core.NotifyLeft = function(src, title, subtitle) notify(src, ('%s — %s'):format(tostring(title), tostring(subtitle or ''))) end
Core.NotifyRightTip = function(src, text) notify(src, text) end
Core.NotifyObjective = function(src, text) notify(src, text) end
Core.NotifyTop = function(src, text) notify(src, text) end
Core.NotifySimpleTop = function(src, text, subtitle) notify(src, ('%s — %s'):format(tostring(text), tostring(subtitle or ''))) end
Core.NotifyAvanced = function(src, text) notify(src, text) end
Core.NotifyCenter = function(src, text) notify(src, text) end
Core.NotifyBottomRight = function(src, text) notify(src, text) end
Core.NotifyFail = function(src, text) notify(src, text, 'error') end
Core.NotifyDead = function(src, title) notify(src, title, 'error') end
Core.NotifyUpdate = function(src, title, subtitle) notify(src, ('%s — %s'):format(tostring(title), tostring(subtitle or ''))) end
Core.NotifyWarning = function(src, title, msg) notify(src, ('%s — %s'):format(tostring(title), tostring(msg or '')), 'error') end
Core.NotifyLeftRank = Core.NotifyLeft
Core.NotifyThreeSimpleTop = function(src, a, b, c) notify(src, ('%s — %s — %s'):format(tostring(a), tostring(b), tostring(c))) end
Core.NotifyOneSimpleTop = function(src, title) notify(src, title) end
Core.NotifyLeftInteractive = function(src, title, desc) notify(src, ('%s — %s'):format(tostring(title), tostring(desc or ''))) end

-- Callbacks (VORP protocol: unique ids, sync/async)
Core.Callback = {
    Register = function(name, cb) LXRCore.Callback.RegisterLegacy(name, cb) end,
    TriggerAsync = function(name, src, cb, ...) LXRCore.Callback.Trigger(name, src, cb, ...) end,
    TriggerAwait = function(name, src, ...) return LXRCore.Callback.Await(name, src, ...) end,
}
Core.addRpcCallback = Core.Callback.Register

RegisterNetEvent('vorp:TriggerServerCallback', function(name, uniqueId, isSync, ...)
    local src = source
    if type(name) ~= 'string' then return end
    LXRCore.Callback.Invoke(name, src, function(...)
        TriggerClientEvent('vorp:ServerCallback', src, uniqueId, isSync, name, ...)
    end, ...)
end)

-- Whitelist API: LXRCore uses ACE, so entries are read-only views.
Core.Whitelist = {
    getEntry = function() return nil end,
    whitelistUser = function() LXRCore.Log.warn('compat', 'vorp whitelistUser ignored (use ACE)') return nil end,
    unWhitelistUser = function() return nil end,
}

Core.Player = {
    Heal = function(src)
        TriggerEvent('vorp_core:Server:OnPlayerHeal', src)
        TriggerClientEvent('vorp_core:Client:OnPlayerHeal', src)
        TriggerClientEvent('LXRCore:Client:Heal', src)
    end,
    Revive = function(src, param)
        TriggerEvent('vorp_core:Server:OnPlayerRevive', src, param)
        TriggerClientEvent('vorp_core:Client:OnPlayerRevive', src, param)
        TriggerClientEvent('LXRCore:Client:Revive', src, param)
    end,
    Respawn = function(src, param)
        TriggerEvent('vorp_core:Server:OnPlayerRespawn', src, param)
        TriggerClientEvent('vorp_core:Client:OnPlayerRespawn', src, param)
    end,
}

---VORP resources register their jobs; map them into the shared registry.
function Core.RegisterJobs(data, resourcename)
    if type(data) ~= 'table' then return end
    for jobname, v in pairs(data) do
        Vorp.RegisteredJobs[jobname] = { RESOURCE = resourcename, PRIVATE_JOB = v.privateJob, GRADES = {}, GROUPS = {} }
        if not LXRShared.Jobs[jobname] then
            local grades = {}
            if type(v.grades) == 'table' then
                for grade, info in pairs(v.grades) do
                    grades[tostring(grade)] = { name = info.label or ('Grade ' .. tostring(grade)), payment = 0 }
                end
            end
            if not next(grades) then grades['0'] = { name = jobname, payment = 0 } end
            LXRCore.Roles.AddJob(jobname, { name = jobname, label = jobname, type = 'vorp', defaultDuty = true, grades = grades })
        end
    end
end

function Core.GetRegisteredJobs(job)
    if job then return Vorp.RegisteredJobs[job] end
    return Vorp.RegisteredJobs
end

Core.dbUpdateAddTables = function() end
Core.dbUpdateAddUpdates = function() end
Core.AddWebhook = function(title, webhook, description)
    TriggerEvent('vorp_core:addWebhook', title, webhook, description)
end

-- Lifecycle bridge: VORP resources listen for vorp:SelectedCharacter
AddEventHandler('LXRCore:Server:PlayerLoaded', function(player)
    local src = player.PlayerData.source
    local char = buildCharacter(player)
    TriggerEvent('vorp:SelectedCharacter', src, char)
    TriggerClientEvent('vorp:SelectedCharacter', src, player.PlayerData.citizenid)
    Player(src).state:set('IsInSession', true, true)
    Player(src).state:set('Character', {
        Group = char.group, FirstName = char.firstname, LastName = char.lastname, Job = char.job,
        JobLabel = char.jobLabel, Grade = char.jobGrade, Gender = char.gender, Age = char.age,
        Money = char.money, Gold = char.gold, Rol = char.rol, CharId = player.PlayerData.citizenid,
    }, true)
end)

AddEventHandler('LXRCore:Server:OnPlayerUnload', function(src)
    Player(src).state:set('IsInSession', false, true)
    Player(src).state:set('Character', nil, true)
end)

AddEventHandler('LXRCore:Server:OnMoneyChange', function(src, account)
    local player = LXRCore.Players[src]
    local state = player and Player(src).state.Character
    if not state then return end
    if account == 'cash' then state.Money = player.PlayerData.money.cash
    elseif account == 'gold' then state.Gold = player.PlayerData.money.gold
    elseif account == CURRENCY[2] then state.Rol = player.PlayerData.money[account] end
    Player(src).state:set('Character', state, true)
end)

-- deprecated VORP acquisition event still used by very old scripts
AddEventHandler('getCore', function(cb)
    if type(cb) == 'function' then cb(Core) end
end)

exports('GetVorpCore', function() return Core end)
LXRCore.Log.info('compat', 'VORP adapter active (GetCore facade + vorp:* callbacks)')
