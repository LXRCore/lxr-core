LXRConfig = {}
LXRConfig.MaxPlayers = GetConvarInt('sv_maxclients', 48) -- Gets max players from config file, default 48
LXRConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
LXRConfig.UpdateInterval = 5 -- how often to update player data in minutes
LXRConfig.EnablePVP = true -- Enable or disable pvp on the server (Ability to shoot other players)
LXRConfig.Discord = "" -- Discord invite link
LXRConfig.ServerClosed = false -- Set server closed (no one can join except people with ace permission 'lxradmin.join')
LXRConfig.ServerClosedReason = "Server Closed" -- Reason for server being closed
LXRConfig.UseConnectQueue = true -- Use connectqueue resource for queue system
LXRConfig.Permissions = {'god', 'admin', 'mod'} -- Add as many groups as you want here after creating them in your server.cfg

LXRConfig.Money = {}
LXRConfig.Money.MoneyTypes = {['cash'] = 2, ['bank'] = 40} -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
LXRConfig.Money.DontAllowMinus = {'cash'} -- Money that is not allowed going in minus
LXRConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck
LXRConfig.Money.PayCheckSociety = false -- If true paycheck will come from the society account that the player is employed at, requires lxr-bossmenu

LXRConfig.Player = {}
LXRConfig.Player.RevealMap = true
LXRConfig.Player.MaxWeight = 120000 -- Max weight a player can carry (currently 120kg, written in grams)
LXRConfig.Player.MaxInvSlots = 41 -- Max inventory slots for a player
LXRConfig.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

-- Left side is level right side xp needed, you just have to add the skill here and in the metadata in servers/player.lua
-- You dont have to use this if you dont want to, just leave as is
LXRConfig.Levels = {
    ["main"] = {
        [0] = 0,
        [1] = 50,
        [2] = 100,
        [3] = 150,
        [4] = 200,
        [5] = 250,
        [6] = 300,
        [7] = 350,
        [8] = 400,
        [9] = 450,
        [10] = 500,
        [11] = 550,
        [12] = 600,
        [13] = 650,
        [14] = 700,
        [15] = 750,
        [16] = 800,
        [17] = 850,
        [18] = 900,
        [19] = 950,
        [20] = 1000
    },
    ["mining"] = {
        [0] = 0,
        [1] = 50,
        [2] = 100,
        [3] = 150,
        [4] = 200,
        [5] = 250,
        [6] = 300,
        [7] = 350,
        [8] = 400,
        [9] = 450,
        [10] = 500,
        [11] = 550,
        [12] = 600,
        [13] = 650,
        [14] = 700,
        [15] = 750,
        [16] = 800,
        [17] = 850,
        [18] = 900,
        [19] = 950,
        [20] = 1000
    },
    ["herbalism"] = {
        [0] = 0,
        [1] = 50,
        [2] = 100,
        [3] = 150,
        [4] = 200,
        [5] = 250,
        [6] = 300,
        [7] = 350,
        [8] = 400,
        [9] = 450,
        [10] = 500,
        [11] = 550,
        [12] = 600,
        [13] = 650,
        [14] = 700,
        [15] = 750,
        [16] = 800,
        [17] = 850,
        [18] = 900,
        [19] = 950,
        [20] = 1000
    },
    ["hunting"] = {
        [0] = 0,
        [1] = 50,
        [2] = 100,
        [3] = 150,
        [4] = 200,
        [5] = 250,
        [6] = 300,
        [7] = 350,
        [8] = 400,
        [9] = 450,
        [10] = 500,
        [11] = 550,
        [12] = 600,
        [13] = 650,
        [14] = 700,
        [15] = 750,
        [16] = 800,
        [17] = 850,
        [18] = 900,
        [19] = 950,
        [20] = 1000
    },
}

exports('GetConfig', function()
    return LXRConfig
end)
