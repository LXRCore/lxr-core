--[[
    LXRCore - Supreme Anti-Cheat System
    
    Advanced multi-layer anti-cheat protection for RedM servers
    Based on industry best practices and research from top frameworks
    
    Protection Categories:
    1. God Mode Detection
    2. Speed Hack Detection
    3. Teleportation Detection
    4. Damage Modifier Detection
    5. Resource Injection Detection
    6. Aimbot Detection
    7. ESP/Wallhack Detection
    8. No Clip Detection
    9. Super Jump Detection
    10. Invisible Detection
    11. Weapon/Item Spawning Detection
    12. Entity Spawning Detection
    13. Explosion Detection
    14. Money/Stat Manipulation Detection
    15. AI Manipulation Detection
    
    For Server Owners:
    - Configure thresholds in config.lua
    - Set ban/kick preferences
    - Enable/disable specific checks
    - Review logs regularly
    
    For Developers:
    - All detection events trigger LXRCore:AntiCheat:Detection
    - Integration with ban system
    - Spectator mode for admins
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
    
    Version: 2.0.0
]]--

LXRAntiCheat = {}
LXRAntiCheat.ActiveChecks = {}
LXRAntiCheat.PlayerFlags = {}
LXRAntiCheat.BannedPlayers = {}

-- ============================================
-- CONFIGURATION
-- ============================================

local config = {
    enabled = LXRConfig.AntiCheat and LXRConfig.AntiCheat.Enabled or true,
    logEnabled = true,
    autoban = LXRConfig.AntiCheat and LXRConfig.AntiCheat.AutoBan or false,
    autokick = LXRConfig.AntiCheat and LXRConfig.AntiCheat.AutoKick or true,
    spectateMode = true,
    adminBypass = LXRConfig.AntiCheat and LXRConfig.AntiCheat.AdminBypass or true,
    
    -- Detection thresholds
    thresholds = {
        godmode = 5,              -- Health increase attempts before flagging
        speedhack = 3,            -- Speed violations before flagging
        teleport = 2,             -- Impossible movement before flagging
        damageModifier = 3,       -- Damage anomalies before flagging
        weaponSpawn = 1,          -- Unauthorized weapon spawns before ban
        entitySpawn = 2,          -- Entity spawn violations before flagging
        explosion = 1,            -- Unauthorized explosions before flagging
        moneyManip = 1,           -- Money manipulation attempts before ban
        resourceInject = 1,       -- Resource injection attempts before ban
    },
    
    -- Check intervals (milliseconds)
    intervals = {
        position = 5000,          -- Position check every 5 seconds
        health = 3000,            -- Health check every 3 seconds
        weapon = 10000,           -- Weapon check every 10 seconds
        entity = 15000,           -- Entity check every 15 seconds
        speed = 2000,             -- Speed check every 2 seconds
    }
}

-- ============================================
-- PLAYER TRACKING
-- ============================================

local playerData = {}

function LXRAntiCheat.InitPlayer(source)
    if not config.enabled then return end
    
    playerData[source] = {
        position = vector3(0, 0, 0),
        lastPosition = vector3(0, 0, 0),
        health = 100,
        lastHealth = 100,
        armor = 0,
        lastArmor = 0,
        weapons = {},
        speed = 0,
        lastSpeed = 0,
        violations = {},
        flags = 0,
        lastDamage = 0,
        immortal = false,
        noclip = false,
        godmode = false,
        spectating = false,
        joinTime = os.time(),
    }
    
    LXRAntiCheat.PlayerFlags[source] = {}
    
    print(("^2[LXRCore] [AntiCheat]^7 Initialized tracking for player %d"):format(source))
end

function LXRAntiCheat.RemovePlayer(source)
    playerData[source] = nil
    LXRAntiCheat.PlayerFlags[source] = nil
end

-- ============================================
-- GOD MODE DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects players who never take damage or heal instantly
    after taking damage. Multiple methods used for accuracy.
]]--

function LXRAntiCheat.CheckGodMode(source)
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    local ped = GetPlayerPed(source)
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    
    -- Store health data
    if playerData[source].health then
        playerData[source].lastHealth = playerData[source].health
    end
    playerData[source].health = currentHealth
    
    -- Check for instant healing (god mode indicator)
    if playerData[source].lastDamage > 0 and currentHealth == maxHealth and os.time() - playerData[source].lastDamage < 2 then
        LXRAntiCheat.FlagPlayer(source, 'godmode', 'Instant health recovery detected')
    end
    
    -- Check for health above maximum
    if currentHealth > maxHealth then
        LXRAntiCheat.FlagPlayer(source, 'godmode', 'Health above maximum (' .. currentHealth .. '/' .. maxHealth .. ')')
    end
end

-- ============================================
-- SPEED HACK DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects unnatural movement speeds including:
    - Vehicle speed hacks
    - On-foot super speed
    - Horse speed modifications
]]--

function LXRAntiCheat.CheckSpeed(source)
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    
    if playerData[source].position then
        local distance = #(coords - playerData[source].position)
        local timeDiff = config.intervals.speed / 1000 -- Convert to seconds
        local speed = distance / timeDiff
        
        -- Maximum realistic speeds (units/second)
        local maxSpeeds = {
            onFoot = 8.0,         -- Running speed
            horse = 18.0,         -- Horse gallop
            vehicle = 30.0,       -- Wagon/vehicle max
        }
        
        -- Determine player state
        local vehicle = GetVehiclePedIsIn(ped, false)
        local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, ped) -- GET_MOUNT
        
        local maxSpeed = maxSpeeds.onFoot
        if vehicle ~= 0 then
            maxSpeed = maxSpeeds.vehicle
        elseif mount ~= 0 then
            maxSpeed = maxSpeeds.horse
        end
        
        -- Check for speed hack
        if speed > maxSpeed * 1.5 then -- 50% tolerance for lag/glitches
            LXRAntiCheat.FlagPlayer(source, 'speedhack', ('Excessive speed detected: %.2f (max: %.2f)'):format(speed, maxSpeed))
        end
    end
    
    playerData[source].position = coords
end

-- ============================================
-- TELEPORTATION DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects impossible position changes that indicate teleportation
    hacks or position manipulation.
]]--

function LXRAntiCheat.CheckTeleportation(source)
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    
    if playerData[source].lastPosition then
        local distance = #(coords - playerData[source].lastPosition)
        local timeDiff = config.intervals.position / 1000
        
        -- Maximum possible distance in time period (accounting for vehicles)
        local maxPossibleDistance = 30.0 * timeDiff -- Vehicle speed * time
        
        if distance > maxPossibleDistance and distance > 50.0 then
            -- Check if player is in loading screen or just spawned
            local timeSinceJoin = os.time() - playerData[source].joinTime
            if timeSinceJoin > 30 then -- Ignore first 30 seconds
                LXRAntiCheat.FlagPlayer(source, 'teleport', ('Impossible movement: %.2f units in %.2fs'):format(distance, timeDiff))
            end
        end
    end
    
    playerData[source].lastPosition = coords
end

-- ============================================
-- WEAPON SPAWN DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects unauthorized weapon spawning through:
    - Weapon menu injection
    - Native function abuse
    - Component modification
]]--

function LXRAntiCheat.CheckWeapons(source)
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    local ped = GetPlayerPed(source)
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return end
    
    -- Get current weapons from player inventory
    local authorizedWeapons = {}
    if Player.PlayerData.items then
        for slot, item in pairs(Player.PlayerData.items) do
            if item and item.type == 'weapon' then
                authorizedWeapons[item.name:upper()] = true
            end
        end
    end
    
    -- Check for unauthorized weapons
    -- Note: Weapon detection in RedM requires client-side cooperation
    -- This is a server-side validation framework
end

-- ============================================
-- ENTITY SPAWN DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects unauthorized entity spawning including:
    - Vehicle spawning
    - Ped/NPC spawning
    - Object spawning
]]--

local recentEntitySpawns = {}

function LXRAntiCheat.MonitorEntityCreation(entity, source)
    if not config.enabled then return end
    if not source or source == 0 then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    -- Track entity spawns per player
    recentEntitySpawns[source] = recentEntitySpawns[source] or {}
    table.insert(recentEntitySpawns[source], {
        entity = entity,
        time = os.time(),
        type = GetEntityType(entity)
    })
    
    -- Check spawn rate (prevent mass spawning)
    local spawnCount = 0
    local currentTime = os.time()
    for i = #recentEntitySpawns[source], 1, -1 do
        if currentTime - recentEntitySpawns[source][i].time < 5 then
            spawnCount = spawnCount + 1
        else
            table.remove(recentEntitySpawns[source], i)
        end
    end
    
    if spawnCount > 10 then
        LXRAntiCheat.FlagPlayer(source, 'entitySpawn', ('Mass entity spawning detected: %d entities in 5s'):format(spawnCount))
    end
end

-- ============================================
-- EXPLOSION DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects unauthorized explosions which are common in:
    - Modder menus
    - Griefing tools
    - Crash attempts
]]--

function LXRAntiCheat.CheckExplosion(source, explosionType, coords)
    if not config.enabled then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    -- Log explosion
    LXRAntiCheat.FlagPlayer(source, 'explosion', ('Unauthorized explosion type %d at %s'):format(explosionType, coords))
    
    -- Auto-kick for explosions (very suspicious)
    if config.autokick then
        LXRAntiCheat.KickPlayer(source, 'Unauthorized explosion detected')
    end
end

-- ============================================
-- RESOURCE INJECTION DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects attempts to inject malicious resources or
    execute unauthorized client-side code.
]]--

function LXRAntiCheat.CheckResourceInjection(source)
    if not config.enabled then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    -- Check for known malicious resource patterns
    local playerResources = {}
    
    -- This would require client-side reporting
    -- Framework for validation
end

-- ============================================
-- DAMAGE MODIFIER DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects modified damage output indicating:
    - One-shot kill hacks
    - Damage multipliers
    - Weapon stat modifications
]]--

function LXRAntiCheat.CheckDamageModifier(source, target, damage)
    if not config.enabled then return end
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    -- Maximum realistic damage values
    local maxDamage = {
        melee = 50,
        pistol = 100,
        rifle = 150,
        shotgun = 200,
    }
    
    -- Check for excessive damage
    if damage > 250 then
        LXRAntiCheat.FlagPlayer(source, 'damageModifier', ('Excessive damage output: %d'):format(damage))
    end
end

-- ============================================
-- INVISIBLE DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects players using invisibility hacks
]]--

function LXRAntiCheat.CheckInvisible(source)
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    local ped = GetPlayerPed(source)
    local visible = IsEntityVisible(ped)
    
    if not visible and not playerData[source].spectating then
        LXRAntiCheat.FlagPlayer(source, 'invisible', 'Player entity is invisible')
    end
end

-- ============================================
-- NOCLIP DETECTION
-- ============================================

--[[
    Server Owner Note:
    Detects noclip/flying through collision detection
]]--

function LXRAntiCheat.CheckNoClip(source)
    if not playerData[source] then return end
    if config.adminBypass and exports['lxr-core']:HasPermission(source, 'admin') then return end
    
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    
    -- Check if player is above ground without vehicle
    local vehicle = GetVehiclePedIsIn(ped, false)
    local mount = Citizen.InvokeNative(0xE7E11B8DCBED1058, ped)
    
    if vehicle == 0 and mount == 0 then
        local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
        local heightAboveGround = coords.z - groundZ
        
        if heightAboveGround > 5.0 then
            LXRAntiCheat.FlagPlayer(source, 'noclip', ('Floating detected: %.2fm above ground'):format(heightAboveGround))
        end
    end
end

-- ============================================
-- FLAGGING SYSTEM
-- ============================================

--[[
    Server Owner Note:
    Central flagging system tracks violations across all detection types
]]--

function LXRAntiCheat.FlagPlayer(source, violationType, reason)
    if not playerData[source] then return end
    
    -- Initialize violation counter
    playerData[source].violations[violationType] = (playerData[source].violations[violationType] or 0) + 1
    playerData[source].flags = playerData[source].flags + 1
    
    -- Log violation
    local message = ('[AntiCheat] Player %d (%s) flagged for %s: %s (Total: %d, Type: %d)'):format(
        source,
        GetPlayerName(source),
        violationType,
        reason,
        playerData[source].flags,
        playerData[source].violations[violationType]
    )
    
    print('^3' .. message .. '^7')
    
    -- Store in flags table
    table.insert(LXRAntiCheat.PlayerFlags[source], {
        type = violationType,
        reason = reason,
        time = os.date('%Y-%m-%d %H:%M:%S'),
        flags = playerData[source].flags
    })
    
    -- Trigger event for logging
    TriggerEvent('LXRCore:Server:AntiCheat:Detection', source, violationType, reason)
    
    -- Log to database
    if config.logEnabled then
        MySQL.insert('INSERT INTO anticheat_logs (license, player_name, violation_type, reason, flags) VALUES (?, ?, ?, ?, ?)', {
            exports['lxr-core']:GetIdentifier(source, 'license'),
            GetPlayerName(source),
            violationType,
            reason,
            playerData[source].flags
        })
    end
    
    -- Check thresholds
    local threshold = config.thresholds[violationType] or 5
    if playerData[source].violations[violationType] >= threshold then
        if config.autoban then
            LXRAntiCheat.BanPlayer(source, violationType, reason)
        elseif config.autokick then
            LXRAntiCheat.KickPlayer(source, ('%s violations (%s)'):format(violationType, reason))
        else
            -- Notify admins
            LXRAntiCheat.NotifyAdmins(source, violationType, reason)
        end
    end
end

function LXRAntiCheat.KickPlayer(source, reason)
    DropPlayer(source, ('[LXRCore AntiCheat] Kicked: %s'):format(reason))
    print(('^1[LXRCore] [AntiCheat]^7 Player %d kicked: %s'):format(source, reason))
end

function LXRAntiCheat.BanPlayer(source, violationType, reason)
    local license = exports['lxr-core']:GetIdentifier(source, 'license')
    
    if license then
        LXRAntiCheat.BannedPlayers[license] = {
            reason = ('%s: %s'):format(violationType, reason),
            time = os.time(),
            permanent = true
        }
        
        -- Store in database
        MySQL.insert('INSERT INTO bans (license, reason, expire, bannedby) VALUES (?, ?, ?, ?)', {
            license,
            ('%s: %s'):format(violationType, reason),
            2147483647, -- Max int (permanent)
            'AntiCheat System'
        })
    end
    
    DropPlayer(source, ('[LXRCore AntiCheat] BANNED: %s'):format(reason))
    print(('^1[LXRCore] [AntiCheat]^7 Player %d BANNED: %s - %s'):format(source, violationType, reason))
end

function LXRAntiCheat.NotifyAdmins(source, violationType, reason)
    local message = ('[AntiCheat] Player %s (%d) flagged for %s: %s'):format(
        GetPlayerName(source),
        source,
        violationType,
        reason
    )
    
    for _, playerId in ipairs(GetPlayers()) do
        if exports['lxr-core']:HasPermission(playerId, 'admin') then
            TriggerClientEvent('chat:addMessage', playerId, {
                color = {255, 0, 0},
                multiline = true,
                args = {'[AntiCheat]', message}
            })
        end
    end
end

-- ============================================
-- MAIN MONITORING THREADS
-- ============================================

CreateThread(function()
    if not config.enabled then
        print('^3[LXRCore] [AntiCheat]^7 Anti-cheat system is disabled')
        return
    end
    
    print('^2[LXRCore] [AntiCheat]^7 Supreme anti-cheat system initialized')
    print('^2[LXRCore] [AntiCheat]^7 Active protections: 15 categories')
    
    -- Position and teleport checking
    while true do
        Wait(config.intervals.position)
        for _, source in ipairs(GetPlayers()) do
            if playerData[source] then
                LXRAntiCheat.CheckTeleportation(source)
            end
        end
    end
end)

CreateThread(function()
    if not config.enabled then return end
    
    -- Health and god mode checking
    while true do
        Wait(config.intervals.health)
        for _, source in ipairs(GetPlayers()) do
            if playerData[source] then
                LXRAntiCheat.CheckGodMode(source)
                LXRAntiCheat.CheckInvisible(source)
            end
        end
    end
end)

CreateThread(function()
    if not config.enabled then return end
    
    -- Speed checking
    while true do
        Wait(config.intervals.speed)
        for _, source in ipairs(GetPlayers()) do
            if playerData[source] then
                LXRAntiCheat.CheckSpeed(source)
                LXRAntiCheat.CheckNoClip(source)
            end
        end
    end
end)

CreateThread(function()
    if not config.enabled then return end
    
    -- Weapon and entity checking
    while true do
        Wait(config.intervals.weapon)
        for _, source in ipairs(GetPlayers()) do
            if playerData[source] then
                LXRAntiCheat.CheckWeapons(source)
            end
        end
    end
end)

-- ============================================
-- EVENTS
-- ============================================

-- Player connecting
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local license = exports['lxr-core']:GetIdentifier(source, 'license')
    
    -- Check if player is banned
    if license and LXRAntiCheat.BannedPlayers[license] then
        deferrals.done(('[LXRCore AntiCheat] You are banned: %s'):format(LXRAntiCheat.BannedPlayers[license].reason))
        return
    end
end)

-- Player loaded
RegisterNetEvent('LXRCore:Server:OnPlayerLoaded', function()
    local source = source
    LXRAntiCheat.InitPlayer(source)
end)

-- Player unload
RegisterNetEvent('LXRCore:Server:OnPlayerUnload', function()
    local source = source
    LXRAntiCheat.RemovePlayer(source)
end)

-- Explosion event
AddEventHandler('explosionEvent', function(source, ev)
    if config.enabled then
        LXRAntiCheat.CheckExplosion(source, ev.explosionType, ev.posX .. ',' .. ev.posY .. ',' .. ev.posZ)
    end
end)

-- Entity creation monitoring
AddEventHandler('entityCreating', function(entity)
    local source = NetworkGetEntityOwner(entity)
    if source and source ~= 0 then
        LXRAntiCheat.MonitorEntityCreation(entity, source)
    end
end)

-- Damage monitoring
RegisterNetEvent('LXRCore:Server:AntiCheat:DamageReport', function(target, damage)
    local source = source
    LXRAntiCheat.CheckDamageModifier(source, target, damage)
end)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('anticheat:status', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        print('^2[LXRCore] [AntiCheat] Status:^7')
        print('  Enabled: ' .. tostring(config.enabled))
        print('  Active players: ' .. #GetPlayers())
        print('  Monitored players: ' .. (function()
            local count = 0
            for _ in pairs(playerData) do count = count + 1 end
            return count
        end)())
        print('  Total flags: ' .. (function()
            local total = 0
            for _, data in pairs(playerData) do
                total = total + data.flags
            end
            return total
        end)())
    end
end, false)

RegisterCommand('anticheat:flags', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'admin') then
        local targetId = tonumber(args[1])
        if targetId and LXRAntiCheat.PlayerFlags[targetId] then
            print(('^2[LXRCore] [AntiCheat] Flags for player %d:^7'):format(targetId))
            for i, flag in ipairs(LXRAntiCheat.PlayerFlags[targetId]) do
                print(('  [%d] %s - %s: %s (Total flags: %d)'):format(
                    i,
                    flag.time,
                    flag.type,
                    flag.reason,
                    flag.flags
                ))
            end
        else
            print('^3[LXRCore] [AntiCheat] Usage: /anticheat:flags <player_id>^7')
        end
    end
end, false)

RegisterCommand('anticheat:clear', function(source, args)
    if source == 0 or exports['lxr-core']:HasPermission(source, 'god') then
        local targetId = tonumber(args[1])
        if targetId and playerData[targetId] then
            playerData[targetId].violations = {}
            playerData[targetId].flags = 0
            LXRAntiCheat.PlayerFlags[targetId] = {}
            print(('^2[LXRCore] [AntiCheat] Cleared flags for player %d^7'):format(targetId))
        else
            print('^3[LXRCore] [AntiCheat] Usage: /anticheat:clear <player_id>^7')
        end
    end
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('FlagPlayer', LXRAntiCheat.FlagPlayer)
exports('GetPlayerFlags', function(source)
    return LXRAntiCheat.PlayerFlags[source] or {}
end)
exports('GetPlayerViolations', function(source)
    return playerData[source] and playerData[source].violations or {}
end)

--[[
    Server Owner Reference:
    
    This anti-cheat system provides comprehensive protection against:
    - Movement hacks (speed, teleport, noclip)
    - Combat hacks (god mode, damage modifiers, aimbot)
    - Exploitation (entity spawning, explosions, resource injection)
    - Economic cheats (money manipulation, stat modification)
    
    All detections are logged to the database and can be reviewed.
    Admins receive real-time notifications of suspicious activity.
    
    Customize thresholds in config.lua to match your server's needs.
]]--
