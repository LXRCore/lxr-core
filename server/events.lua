-- Event Handler
GlobalState['Count:Players'] = 0

AddEventHandler('playerDropped', function()
    local src = source
    local Player = LXRCore.Players[src]
    GlobalState['Count:Players'] = GetNumPlayerIndices()
    if not Player then return end
    TriggerEvent('lxr-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..')
    Player.Functions.Save()
    LXRCore.Players[src] = nil
end)

local function IsPlayerBanned(plicense)
    local result = MySQL.single.await('SELECT * FROM bans WHERE license = ?', { plicense })
    if not result then return false end
    if os.time() < result.expire then
        local timeTable = os.date('*t', tonumber(result.expire))
        return true, 'You have been banned from the server:\n' .. result.reason .. '\nYour ban expires ' .. timeTable.day .. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
    else
        MySQL.query('DELETE FROM bans WHERE id = ?', { result.id })
        return false
    end
    return false
end

local function IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local id = GetPlayerIdentifierByType(player, 'license')
        if id == license then
            return true
        end
    end
    return false
end

-- Player Connecting

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    if LXRConfig.ServerClosed and not IsPlayerAceAllowed(src, 'whitelisted') then
        return deferrals.done(LXRConfig.ServerClosedReason)
    end
    Wait(0)
    deferrals.update(string.format('Hello %s. Your license is being checked', name))
    local license = GetPlayerIdentifierByType(src, 'license')
    if not license then
        return deferrals.done('No Valid Rockstar License Found')
    elseif IsLicenseInUse(license) then
        return deferrals.done('Duplicate Rockstar License Found')
    end
    Wait(0)
    deferrals.update(string.format('Hello %s. We are checking if you are banned.', name))
    local success, isBanned, reason = pcall(IsPlayerBanned, license)
    if not success then return deferrals.done('A database error occurred while connecting to the server.') end
    if isBanned then return deferrals.done(reason) end
    Wait(0)
    deferrals.update(string.format('Welcome %s to {Server Name}.', name))
	GlobalState['Count:Players'] = GetNumPlayerIndices() + 1
    deferrals.done()
	if LXRConfig.UseConnectQueue then
        Wait(1000)
    	TriggerEvent('connectqueue:playerConnect', name, setKickReason, deferrals)
	end
end

AddEventHandler('playerConnecting', OnPlayerConnecting)

-- Player

RegisterNetEvent('LXRCore:UpdatePlayer', function()
    local Player = GetPlayer(source)
	if not Player then return end
    Player.Functions.Save()
end)

RegisterNetEvent('LXRCore:Server:SetMetaData', function(meta, data)
    local Player = GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData(meta, data)
end)

RegisterNetEvent('LXRCore:ToggleDuty', function()
    local Player = GetPlayer(source)
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('LXRCore:Notify', source, 9, Lang:t('info.off_duty'), 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('LXRCore:Notify', source, 9, Lang:t('info.on_duty'), 5000, 0, 'hud_textures', 'check', 'COLOR_WHITE')
    end
    TriggerClientEvent('LXRCore:Client:SetDuty', source, Player.PlayerData.job.onduty)
end)

-- Items

RegisterNetEvent('LXRCore:Server:UseItem', function(item)
    if item and item.amount > 0 then
        if LXRCore.UseableItems[item.name] then
            LXRCore.UseableItems[item.name](source, item)
        end
    end
end)

RegisterNetEvent('LXRCore:Server:RemoveItem', function(itemName, amount, slot)
    local Player = GetPlayer(source)
    Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterNetEvent('LXRCore:Server:AddItem', function(itemName, amount, slot, info)
    local Player = GetPlayer(source)
    Player.Functions.AddItem(itemName, amount, slot, info)
end)

-- Xp Events

RegisterNetEvent('LXRCore:Player:SetLevel', function(source, skill)
	local Player = GetPlayer(source)
	local Skill = tostring(skill)
	local currentXp = Player.PlayerData.metadata["xp"][Skill]
	local Level = 0
	for k, v in pairs(LXRConfig.Levels[Skill]) do
		if currentXp >= v then
			Player.PlayerData.metadata["levels"][Skill] = k
		end
	end
end)

RegisterNetEvent('LXRCore:Player:GiveXp', function(source, skill, amount) -- adding LXRCore xp if you dont want to import the playerdata or for standalone scripts
	local Player = GetPlayer(source)
	if Player then
		if Player.PlayerData.metadata["xp"][skill] then
			Player.Functions.AddXp(skill, amount)
		end
	end
end)

RegisterNetEvent('LXRCore:Player:RemoveXp', function(source, skill, amount) -- removing LXRCore xp if you dont want to import the playerdata or for standalone scripts
	local Player = GetPlayer(source)
	if Player then
		if Player.PlayerData.metadata["xp"][skill] then
			Player.Functions.RemoveXp(skill, amount)
		end
	end
end)

RegisterNetEvent('LXRCore:Server:TriggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('LXRCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

CreateCallback('LXRCore:HasItem', function(source, cb, items, amount)
    local retval = false
    local Player = GetPlayer(source)
    if Player then
        if type(items) == 'table' then
            local count = 0
            local finalcount = 0
            for k, v in pairs(items) do
                if type(k) == 'string' then
                    finalcount = 0
                    for i, _ in pairs(items) do
                        if i then
                            finalcount = finalcount + 1
                        end
                    end
                    local item = Player.Functions.GetItemByName(k)
                    if item then
                        if item.amount >= v then
                            count = count + 1
                            if count == finalcount then
                                retval = true
                            end
                        end
                    end
                else
                    finalcount = #items
                    local item = Player.Functions.GetItemByName(v)
                    if item then
                        if amount then
                            if item.amount >= amount then
                                count = count + 1
                                if count == finalcount then
                                    retval = true
                                end
                            end
                        else
                            count = count + 1
                            if count == finalcount then
                                retval = true
                            end
                        end
                    end
                end
            end
        else
            local item = Player.Functions.GetItemByName(items)
            if item then
                if amount then
                    if item.amount >= amount then
                        retval = true
                    end
                else
                    retval = true
                end
            end
        end
    end
    cb(retval)
end)
