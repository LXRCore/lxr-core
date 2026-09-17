--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Command Registry & Built-in Commands (server)
     ═══════════════════════════════════════════════════════════════════════════
     LXRCore.Commands.Add(name, help, arguments, argsRequired, callback, permission, ...)
       permission 'user' (default) → anyone; any other string → ACE
       `command.<name>` granted to lxrcore.<permission> (+ extra groups via …).
     LXRCore.Commands.Refresh(src) pushes chat suggestions the player may use.
     Built-in commands only touch server-authoritative state; every argument is
     validated before it reaches the player object.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Commands = LXRCore.Commands or {}
local Commands = LXRCore.Commands
Commands.List = {}
Commands.IgnoreList = { god = true, user = true }

local function notify(src, msg, kind)
    TriggerClientEvent('LXRCore:Notify', src, msg, kind or 'inform')
end

local function grantAce(group, name)
    if Commands.IgnoreList[group] then return end
    ExecuteCommand(('add_ace lxrcore.%s command.%s allow'):format(group, name))
end

---@param name string
---@param help string
---@param arguments table[] { { name = 'id', help = 'Player id' }, … }
---@param argsRequired boolean
---@param callback fun(source: integer, args: string[], raw: string)
---@param permission string|nil
function Commands.Add(name, help, arguments, argsRequired, callback, permission, ...)
    if type(name) ~= 'string' or type(callback) ~= 'function' then
        LXRCore.Log.error('command', 'Commands.Add: invalid arguments', { name = name })
        return false
    end
    name = name:lower()
    arguments = arguments or {}
    permission = permission or 'user'
    local restricted = permission ~= 'user'

    RegisterCommand(name, function(source, args, raw)
        if argsRequired and #args < #arguments then
            if source == 0 then
                print(Lang:t('error.missing_args2'))
            else
                notify(source, Lang:t('error.missing_args2'), 'error')
            end
            return
        end
        TriggerEvent('LXRCore:Server:PreCommandExecution', source, name, args)
        local ok, err = pcall(callback, source, args, raw)
        if not ok then
            LXRCore.Log.error('command', ('command /%s errored'):format(name), { error = tostring(err), source = source })
        end
    end, restricted)

    local extra = table.pack(...)
    local perms = { permission }
    for i = 1, extra.n do
        if type(extra[i]) == 'string' then perms[#perms + 1] = extra[i] end
    end
    if restricted then
        for _, group in ipairs(perms) do grantAce(group, name) end
    end

    Commands.List[name] = {
        name = name,
        permission = #perms > 1 and perms or permission,
        help = help or '',
        arguments = arguments,
        argsrequired = argsRequired == true,
        callback = callback,
        resource = LXRCore.Invoker(),
    }
    return true
end

---Push chat suggestions for the commands this player can run.
function Commands.Refresh(source)
    source = LXRCore.ToSource(source)
    if not source then return end
    local suggestions = {}
    for name, info in pairs(Commands.List) do
        local allowed = info.permission == 'user' or IsPlayerAceAllowed(source, 'command.' .. name)
        if allowed then
            suggestions[#suggestions + 1] = { name = '/' .. name, help = info.help, params = info.arguments }
        else
            TriggerClientEvent('chat:removeSuggestion', source, '/' .. name)
        end
    end
    TriggerClientEvent('chat:addSuggestions', source, suggestions)
end

---Run a registered command on behalf of a player without the chat (admin menus).
---@return boolean
function Commands.Call(source, name, args)
    name = tostring(name or ''):lower()
    local info = Commands.List[name]
    if not info then return false end
    if info.permission ~= 'user' and not IsPlayerAceAllowed(source, 'command.' .. name) then
        notify(source, Lang:t('error.no_access'), 'error')
        return false
    end
    if info.argsrequired and #(args or {}) < #info.arguments then
        notify(source, Lang:t('error.missing_args2'), 'error')
        return false
    end
    info.callback(source, args or {}, table.concat(args or {}, ' '))
    return true
end

RegisterNetEvent('LXRCore:CallCommand', function(command, args)
    local src = source
    if not LXRCore.Players[src] then return end
    Commands.Call(src, command, args)
end)

-- Swallow chat messages that start with '/' but are not registered (stock chat behaviour)
AddEventHandler('chatMessage', function(_, _, message)
    if type(message) == 'string' and message:sub(1, 1) == '/' then
        CancelEvent()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🧩 BUILT-IN COMMANDS (registered after locale + core objects exist)
-- ═══════════════════════════════════════════════════════════════════════════════

local function targetPlayer(src, id)
    local target = LXRCore.Functions.GetPlayer(tonumber(id))
    if not target then
        notify(src, Lang:t('error.not_online'), 'error')
        return nil
    end
    return target
end

function Commands.RegisterBuiltins()
    local T = function(k, v) return Lang:t(k, v) end
    local P = function(key) return { name = T('command.' .. key .. '.name'), help = T('command.' .. key .. '.help') } end

    -- Teleport: /tp <id>  or  /tp <x> <y> <z>
    Commands.Add('tp', T('command.tp.help'), { P('tp.params.x'), P('tp.params.y'), P('tp.params.z') }, false, function(src, args)
        if args[1] and not args[2] then
            local target = tonumber(args[1])
            local ped = target and GetPlayerPed(target) or 0
            if ped == 0 then return notify(src, Lang:t('error.not_online'), 'error') end
            TriggerClientEvent('LXRCore:Command:TeleportToCoords', src, GetEntityCoords(ped))
            notify(src, Lang:t('success.teleported_to_player'), 'success')
        elseif args[1] and args[2] and args[3] then
            local x, y, z = tonumber((args[1]:gsub(',', ''))), tonumber((args[2]:gsub(',', ''))), tonumber((args[3]:gsub(',', '')))
            if not (x and y and z) then return notify(src, Lang:t('error.wrong_format'), 'error') end
            TriggerClientEvent('LXRCore:Command:TeleportToCoords', src, vector3(x, y, z))
            notify(src, Lang:t('success.teleported_to_coords'), 'success')
        else
            notify(src, Lang:t('error.missing_args'), 'error')
        end
    end, 'admin')

    Commands.Add('tpm', T('command.tpm.help'), {}, false, function(src)
        TriggerClientEvent('LXRCore:Command:GoToMarker', src)
    end, 'admin')

    Commands.Add('togglepvp', T('command.togglepvp.help'), {}, false, function(src)
        Config.General.enablePVP = not Config.General.enablePVP
        TriggerClientEvent('LXRCore:Client:PvpHasToggled', -1, Config.General.enablePVP)
        if src > 0 then
            notify(src, Config.General.enablePVP and Lang:t('info.pvp_enabled') or Lang:t('info.pvp_disabled'))
        end
    end, 'admin')

    Commands.Add('addpermission', T('command.addpermission.help'), { P('addpermission.params.id'), P('addpermission.params.permission') }, true, function(src, args)
        local target = targetPlayer(src, args[1]); if not target then return end
        local perm = tostring(args[2]):lower()
        LXRCore.Perms.Add(target.PlayerData.source, perm)
        if src > 0 then notify(src, Lang:t('success.permission_added', { permission = perm, name = target.PlayerData.name }), 'success') end
    end, 'god')

    Commands.Add('removepermission', T('command.removepermission.help'), { P('removepermission.params.id'), P('removepermission.params.permission') }, true, function(src, args)
        local target = targetPlayer(src, args[1]); if not target then return end
        local perm = tostring(args[2]):lower()
        LXRCore.Perms.Remove(target.PlayerData.source, perm)
        if src > 0 then notify(src, Lang:t('success.permission_removed', { permission = perm, name = target.PlayerData.name }), 'success') end
    end, 'god')

    Commands.Add('openserver', T('command.openserver.help'), {}, false, function(src)
        Config.Server.closed = false
        if src > 0 then notify(src, Lang:t('success.server_opened'), 'success') end
    end, 'admin')

    Commands.Add('closeserver', T('command.closeserver.help'), { P('closeserver.params.reason') }, false, function(src, args)
        Config.Server.closed = true
        Config.Server.closedReason = args[1] and table.concat(args, ' ') or Lang:t('error.server_closed')
        for id in pairs(LXRCore.Players) do
            if not LXRCore.Perms.Has(id, 'lxrcore.join') then
                LXRCore.Functions.Kick(id, Config.Server.closedReason)
            end
        end
        if src > 0 then notify(src, Lang:t('success.server_closed'), 'success') end
    end, 'admin')

    Commands.Add('givemoney', T('command.givemoney.help'), { P('givemoney.params.id'), P('givemoney.params.moneytype'), P('givemoney.params.amount') }, true, function(src, args)
        local target = targetPlayer(src, args[1]); if not target then return end
        local ok, err = target.Functions.AddMoney(tostring(args[2]), tonumber(args[3]), 'admin:givemoney')
        if not ok then return notify(src, Lang:t('error.' .. (err or 'invalid_amount')), 'error') end
        if src > 0 then notify(src, Lang:t('success.money_given', { amount = args[3], account = args[2], name = target.PlayerData.name }), 'success') end
    end, 'admin')

    Commands.Add('setmoney', T('command.setmoney.help'), { P('setmoney.params.id'), P('setmoney.params.moneytype'), P('setmoney.params.amount') }, true, function(src, args)
        local target = targetPlayer(src, args[1]); if not target then return end
        local ok, err = target.Functions.SetMoney(tostring(args[2]), tonumber(args[3]), 'admin:setmoney')
        if not ok then return notify(src, Lang:t('error.' .. (err or 'invalid_amount')), 'error') end
        if src > 0 then notify(src, Lang:t('success.money_set', { amount = args[3], account = args[2], name = target.PlayerData.name }), 'success') end
    end, 'admin')

    Commands.Add('job', T('command.job.help'), {}, false, function(src)
        local player = LXRCore.Functions.GetPlayer(src); if not player then return end
        local job = player.PlayerData.job
        notify(src, Lang:t('info.job_info', { value = job.label, value2 = job.grade.name, value3 = tostring(job.onduty) }))
    end, 'user')

    Commands.Add('setjob', T('command.setjob.help'), { P('setjob.params.id'), P('setjob.params.job'), P('setjob.params.grade') }, true, function(src, args)
        local target = targetPlayer(src, args[1]); if not target then return end
        local ok, err = target.Functions.SetJob(tostring(args[2]), tonumber(args[3]) or 0)
        if not ok then return notify(src, Lang:t('error.' .. (err or 'invalid_job')), 'error') end
        if src > 0 then notify(src, Lang:t('success.job_set', { job = args[2], grade = args[3] or 0, name = target.PlayerData.name }), 'success') end
    end, 'admin')

    Commands.Add('gang', T('command.gang.help'), {}, false, function(src)
        local player = LXRCore.Functions.GetPlayer(src); if not player then return end
        local gang = player.PlayerData.gang
        notify(src, Lang:t('info.gang_info', { value = gang.label, value2 = gang.grade.name }))
    end, 'user')

    Commands.Add('setgang', T('command.setgang.help'), { P('setgang.params.id'), P('setgang.params.gang'), P('setgang.params.grade') }, true, function(src, args)
        local target = targetPlayer(src, args[1]); if not target then return end
        local ok, err = target.Functions.SetGang(tostring(args[2]), tonumber(args[3]) or 0)
        if not ok then return notify(src, Lang:t('error.' .. (err or 'invalid_gang')), 'error') end
        if src > 0 then notify(src, Lang:t('success.gang_set', { gang = args[2], grade = args[3] or 0, name = target.PlayerData.name }), 'success') end
    end, 'admin')

    Commands.Add('ooc', T('command.ooc.help'), {}, false, function(src, args)
        local message = table.concat(args, ' ')
        if message == '' then return end
        local player = LXRCore.Functions.GetPlayer(src); if not player then return end
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        local label = ('%s (%s) | OOC'):format(player.PlayerData.charinfo.firstname, src)
        for id in pairs(LXRCore.Players) do
            local dist = #(GetEntityCoords(GetPlayerPed(id)) - coords)
            if dist <= 20.0 then
                TriggerClientEvent('chat:addMessage', id, { color = Config.Commands.oocColor, multiline = true, args = { label, message } })
            end
        end
        LXRCore.Log.info('chat', ('%s: %s'):format(label, message))
    end, 'user')

    Commands.Add('me', T('command.me.help'), { P('me.params.message') }, false, function(src, args)
        local message = table.concat(args, ' ')
        if message == '' then return end
        local coords = GetEntityCoords(GetPlayerPed(src))
        for id in pairs(LXRCore.Players) do
            if #(GetEntityCoords(GetPlayerPed(id)) - coords) <= (Config.Commands.meRange or 12.0) then
                TriggerClientEvent('LXRCore:Command:ShowMe3D', id, src, message)
            end
        end
    end, 'user')

    Commands.Add('id', T('command.id.help'), {}, false, function(src)
        notify(src, Lang:t('info.server_id', { id = src }))
    end, 'user')

    Commands.Add('cid', T('command.cid.help'), {}, false, function(src)
        local player = LXRCore.Functions.GetPlayer(src); if not player then return end
        notify(src, Lang:t('info.citizen_id', { citizenid = player.PlayerData.citizenid }))
    end, 'user')

    Commands.Add('save', T('command.save.help'), {}, false, function(src)
        local player = LXRCore.Functions.GetPlayer(src); if not player then return end
        player.Functions.Save()
        notify(src, Lang:t('success.saved'), 'success')
    end, 'user')

    Commands.Add('logout', T('command.logout.help'), {}, false, function(src)
        local player = LXRCore.Functions.GetPlayer(src); if not player then return end
        LXRCore.Player.Logout(src)
        notify(src, Lang:t('info.logged_out'))
    end, 'admin')

    Commands.Add('deletechar', T('command.deletechar.help'), { P('deletechar.params.citizenid') }, true, function(src, args)
        LXRCore.Player.ForceDeleteCharacter(tostring(args[1]))
        if src > 0 then notify(src, Lang:t('info.char_deleted'), 'success') end
    end, 'god')

    Commands.Add('lxr:metrics', T('command.metrics.help'), {}, false, function(src)
        local m = LXRCore.Metrics.Get()
        local lines = { ('%s — uptime %ds, players %d'):format(Lang:t('info.metrics_header'), m.uptime, m.players) }
        for k, v in pairs(m.counters) do lines[#lines + 1] = ('  %s = %d'):format(k, v) end
        for k, v in pairs(m.timings) do lines[#lines + 1] = ('  %s: n=%d avg=%.1fms max=%dms'):format(k, v.count, v.avg, v.max) end
        local out = table.concat(lines, '\n')
        if src == 0 then print(out) else TriggerClientEvent('chat:addMessage', src, { multiline = true, args = { 'LXRCore', out } }) end
    end, 'admin')

    Commands.Add('vehicle', T('command.vehicle.help'), { P('vehicle.params.model') }, true, function(src, args)
        TriggerClientEvent('LXRCore:Command:SpawnVehicle', src, tostring(args[1]))
    end, 'admin')

    Commands.Add('dv', T('command.dv.help'), {}, false, function(src)
        TriggerClientEvent('LXRCore:Command:DeleteVehicle', src)
    end, 'admin')
end

-- Legacy QBR-style export: AddCommand(name, help, arguments, argsrequired, callback, permission)
exports('AddCommand', function(name, help, arguments, argsRequired, callback, permission, ...)
    return Commands.Add(name, help, arguments, argsRequired, callback, permission, ...)
end)
exports('RefreshCommands', Commands.Refresh)
exports('CallCommand', Commands.Call)
