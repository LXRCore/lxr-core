--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Connection Handling & Validated Net Events (server)
     ═══════════════════════════════════════════════════════════════════════════
     • playerConnecting deferrals: closed server, database readiness, whitelist,
       license, duplicate license, discord requirement, ban check
     • playerDropped: synchronous save, index cleanup, callback cleanup
     • Every client-originated event is rate-limited and validated. There is no
       event that adds money or items; those stay server-side APIs.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local eventBuckets = {}
local connecting = {} -- license → true while a client is in the deferral phase

local function limited(src)
    local rl = Config.Security.eventRateLimit
    if not rl then return false end
    if LXRCore.RateLimit(eventBuckets, src, rl.burst, rl.windowMs) then return false end
    LXRCore.Metrics.Inc('event.ratelimited')
    return true
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🚫 BANS & KICKS
-- ═══════════════════════════════════════════════════════════════════════════════

---@return boolean banned, string|nil reason
function LXRCore.Functions.IsPlayerBanned(source)
    local license = GetPlayerIdentifierByType(source, 'license')
    local discord = GetPlayerIdentifierByType(source, 'discord')
    local row = LXRCore.DB.Single('SELECT id, reason, expire FROM bans WHERE license = ? OR (discord IS NOT NULL AND discord = ?) ORDER BY expire DESC LIMIT 1', { license, discord or '' })
    if not row then return false end
    local expire = tonumber(row.expire) or 0
    if expire == 0 or expire >= 2147483647 then
        return true, Lang:t('error.banned_permanent', { reason = row.reason or '' })
    end
    if os.time() < expire then
        return true, Lang:t('error.banned', { reason = row.reason or '', expires = os.date('%Y-%m-%d %H:%M', expire) })
    end
    LXRCore.DB.UpdateAsync('DELETE FROM bans WHERE id = ?', { row.id })
    return false
end

---Ban + drop a player for an exploit (permanent unless `hours` given).
function LXRCore.Functions.ExploitBan(source, origin, hours)
    source = LXRCore.ToSource(source)
    if not source then return false end
    local expire = hours and (os.time() + math.floor(hours * 3600)) or 2147483647
    LXRCore.DB.InsertAsync('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(source),
        GetPlayerIdentifierByType(source, 'license'),
        GetPlayerIdentifierByType(source, 'discord'),
        GetPlayerIdentifierByType(source, 'ip'),
        Lang:t('info.exploit_ban_reason', { origin = tostring(origin) }),
        expire,
        'LXRCore Anti-Exploit',
    })
    LXRCore.Log.exploit(source, 'banned: ' .. tostring(origin))
    DropPlayer(source, Lang:t('error.exploit_banned', { discord = LXRCore.Brand.discord }))
    return true
end

---Kick with a reason; safe to call during deferrals.
function LXRCore.Functions.Kick(source, reason, setKickReason, deferrals)
    source = LXRCore.ToSource(source)
    reason = ('\n%s\n🔸 %s'):format(tostring(reason or ''), LXRCore.Brand.discord or '')
    if setKickReason then setKickReason(reason) end
    if deferrals then
        deferrals.update(reason)
        SetTimeout(2500, function() if source then DropPlayer(source, reason) end end)
        return
    end
    if source then DropPlayer(source, reason) end
end
LXRCore.Functions.KickPlayer = LXRCore.Functions.Kick

function LXRCore.Functions.IsLicenseInUse(license)
    if LXRCore.PlayersByLicense[license] then return true end
    for _, id in ipairs(GetPlayers()) do
        if GetPlayerIdentifierByType(id, 'license') == license then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔌 CONNECTION
-- ═══════════════════════════════════════════════════════════════════════════════

local function onPlayerConnecting(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)
    LXRCore.Metrics.Inc('connect.attempt')

    if Config.Server.closed and not IsPlayerAceAllowed(src, 'lxrcore.join') then
        return deferrals.done(Config.Server.closedReason or Lang:t('error.server_closed'))
    end
    if Config.Database.requireReady and not LXRCore.DB.Ready then
        return deferrals.done(Lang:t('error.database_not_ready'))
    end

    deferrals.update(Lang:t('info.checking_license', { name = name }))
    local license = GetPlayerIdentifierByType(src, 'license')
    if not license then
        return deferrals.done(Lang:t('error.no_valid_license'))
    end
    if Config.Server.checkDuplicateLicense and (connecting[license] or LXRCore.Functions.IsLicenseInUse(license)) then
        return deferrals.done(Lang:t('error.duplicate_license'))
    end
    connecting[license] = true
    local function finish(msg)
        connecting[license] = nil
        deferrals.done(msg)
    end

    if Config.Server.requireDiscord and not GetPlayerIdentifierByType(src, 'discord') then
        return finish(Lang:t('error.no_discord'))
    end

    if Config.Server.whitelist then
        deferrals.update(Lang:t('info.checking_whitelisted', { name = name }))
        if not LXRCore.Perms.IsWhitelisted(src) then
            return finish(Lang:t('error.not_whitelisted'))
        end
    end

    deferrals.update(Lang:t('info.checking_ban', { name = name }))
    local ok, banned, reason = pcall(LXRCore.Functions.IsPlayerBanned, src)
    if not ok then
        LXRCore.Log.error('player', 'ban check failed', { error = tostring(banned) })
        return finish(Lang:t('error.connecting_database_error'))
    end
    if banned then
        LXRCore.Metrics.Inc('connect.banned')
        return finish(reason)
    end

    deferrals.update(Lang:t('info.join_server', { name = name, server = LXRCore.Brand.name }))
    -- give other resources a chance to veto (queue, whitelist systems); they may call deferrals.done(reason)
    LXRCore.Emit('lxr:player:connecting', { legacy = 'LXRCore:Server:PlayerConnecting' }, src, name, setKickReason, deferrals)
    Wait(0)
    finish()
    LXRCore.Metrics.Inc('connect.accepted')
    LXRCore.Log.info('player', 'connection accepted', { source = src, name = name })
end
AddEventHandler('playerConnecting', onPlayerConnecting)

AddEventHandler('playerJoining', function()
    local src = source
    -- shared data snapshot so late-added items/jobs are present before any resource asks
    LXRCore.EmitClient(src, 'lxr:client:sharedAll', { legacy = 'LXRCore:Client:SharedUpdate', rsg = 'RSGCore:Client:SharedUpdate' }, LXRShared)
    GlobalState['Count:Players'] = GetNumPlayerIndices()
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local player = LXRCore.Players[src]
    GlobalState['Count:Players'] = math.max(0, GetNumPlayerIndices() - 1)
    eventBuckets[src] = nil
    if LXRCore.Items.lastUse then LXRCore.Items.lastUse[src] = nil end
    LXRCore.Callback.CleanupSource(src)
    if not player then return end
    LXRCore.Emit('lxr:player:dropped', { legacy = 'LXRCore:Server:PlayerDropped', rsg = 'RSGCore:Server:PlayerDropped' }, player, reason)
    player.Functions.PersistStateBags()
    LXRCore.Player.Save(src, true)
    LXRCore.Players[src] = nil
    LXRCore.PlayersByCitizenId[player.PlayerData.citizenid] = nil
    LXRCore.PlayersByLicense[player.PlayerData.license] = nil
    LXRCore.Metrics.Inc('player.dropped')
    LXRCore.Log.info('player', 'dropped', { source = src, citizenid = player.PlayerData.citizenid, reason = reason })
end)

-- Save everything on resource stop so a restart never loses progress.
AddEventHandler('onResourceStop', function(res)
    if res ~= LXRCore.ResourceName then return end
    for src in pairs(LXRCore.Players) do
        pcall(LXRCore.Player.Save, src, true)
    end
    LXRCore.Accounts.FlushLedger()
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📡 CLIENT-ORIGINATED EVENTS (validated)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Client asks for a save (legacy loop / logout screens). Rate-limited: one per 30s.
local saveRequests = {}
local function onSaveRequest()
    local src = source
    local player = LXRCore.Players[src]
    if not player then return end
    if not LXRCore.RateLimit(saveRequests, src, 1, 30000) then return end
    player.Functions.PersistStateBags()
    LXRCore.Player.Save(src, false)
end
RegisterNetEvent('lxr:player:save', onSaveRequest)
RegisterNetEvent('LXRCore:UpdatePlayer', onSaveRequest) -- legacy name

-- Client may only set whitelisted metadata keys (hunger/thirst/…).
local function onSetMeta(meta, data)
    local src = source
    if limited(src) then return end
    local player = LXRCore.Players[src]
    if not player or type(meta) ~= 'string' then return end
    local allowed = false
    for _, k in ipairs(Config.Security.clientMetadataWhitelist or {}) do
        if k == meta then allowed = true break end
    end
    if not allowed then
        LXRCore.Log.exploit(src, 'client tried to set protected metadata', { key = meta })
        return
    end
    if type(data) ~= 'number' then return end
    player.Functions.SetMetaData(meta, data)
end
RegisterNetEvent('lxr:player:meta', onSetMeta)
RegisterNetEvent('LXRCore:Server:SetMetaData', onSetMeta) -- legacy name

local function onToggleDuty()
    local src = source
    if limited(src) then return end
    local player = LXRCore.Players[src]
    if not player then return end
    local onduty = not player.PlayerData.job.onduty
    player.Functions.SetJobDuty(onduty)
    LXRCore.Notify(src, onduty and Lang:t('info.on_duty') or Lang:t('info.off_duty'))
end
RegisterNetEvent('lxr:player:duty', onToggleDuty)
RegisterNetEvent('LXRCore:ToggleDuty', onToggleDuty) -- legacy name

-- Spawn resources announce that the character stands in the world.
local function onSpawned()
    local src = source
    local player = LXRCore.Players[src]
    if not player then return end
    Player(src).state:set('isLoggedIn', true, true)
    LXRCore.Emit('lxr:player:spawned', { legacy = 'LXRCore:Server:PlayerSpawned' }, src, player)
end
RegisterNetEvent('lxr:player:spawned', onSpawned)
RegisterNetEvent('LXRCore:Server:OnPlayerLoaded', onSpawned) -- legacy name

-- Usable item from an inventory UI. Ownership is re-verified server-side in Items.Use.
local function onUseItem(item)
    local src = source
    if limited(src) then return end
    if type(item) ~= 'table' and type(item) ~= 'string' then return end
    LXRCore.Items.Use(src, item)
end
RegisterNetEvent('lxr:item:use', onUseItem)
RegisterNetEvent('LXRCore:Server:UseItem', onUseItem) -- legacy name

RegisterNetEvent('LXRCore:Server:CloseServer', function(reason)
    local src = source
    if not LXRCore.Perms.Has(src, 'admin') then
        return LXRCore.Log.exploit(src, 'CloseServer without permission')
    end
    LXRCore.Commands.Call(src, 'closeserver', { tostring(reason or 'No reason specified') })
end)

RegisterNetEvent('LXRCore:Server:OpenServer', function()
    local src = source
    if not LXRCore.Perms.Has(src, 'admin') then
        return LXRCore.Log.exploit(src, 'OpenServer without permission')
    end
    Config.Server.closed = false
end)

-- Legacy v2 callback protocol (name-keyed). Kept for resources that trigger the
-- event manually; the v3 client uses request ids.
RegisterNetEvent('LXRCore:Server:TriggerCallback', function(name, ...)
    local src = source
    if limited(src) or type(name) ~= 'string' then return end
    LXRCore.Callback.Invoke(name, src, function(...)
        TriggerClientEvent('LXRCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

RegisterNetEvent('LXRCore:Server:TriggerClientCallback', function(name, ...)
    local src = source
    local cb = LXRCore.ClientCallbacks[name]
    if cb then
        LXRCore.ClientCallbacks[name] = nil
        cb(...)
    end
end)

-- Deprecated exploitable events from the QBR era are answered with a log, never an action.
for _, ev in ipairs({ 'LXRCore:Server:AddItem', 'LXRCore:Server:RemoveItem', 'LXRCore:Player:GiveXp', 'LXRCore:Player:RemoveXp', 'LXRCore:Player:SetLevel' }) do
    RegisterNetEvent(ev, function()
        LXRCore.Log.exploit(source, ('deprecated client event %s called'):format(ev), { resource = GetInvokingResource() })
    end)
end

-- Shared data on demand (resources that start late).
RegisterNetEvent('LXRCore:Server:RequestShared', function()
    LXRCore.EmitClient(source, 'lxr:client:sharedAll', { legacy = 'LXRCore:Client:SharedUpdate', rsg = 'RSGCore:Client:SharedUpdate' }, LXRShared)
end)

-- Vehicle spawn helper (server-side entity creation, returns net id).
LXRCore.Functions.CreateCallback('LXRCore:Server:SpawnVehicle', function(src, cb, model, coords, warp)
    if type(model) ~= 'string' and type(model) ~= 'number' then return cb(nil) end
    local ped = GetPlayerPed(src)
    if not coords then coords = GetEntityCoords(ped) end
    local hash = type(model) == 'string' and joaat(model) or model
    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w or GetEntityHeading(ped), true, true)
    local tries = 0
    while not DoesEntityExist(veh) and tries < 100 do Wait(10) tries = tries + 1 end
    if not DoesEntityExist(veh) then return cb(nil) end
    if warp then TaskWarpPedIntoVehicle(ped, veh, -1) end
    cb(NetworkGetNetworkIdFromEntity(veh))
end)
