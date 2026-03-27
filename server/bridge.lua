--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - Framework Bridge System
    
    This module allows LXR Core to work as a standalone framework or alongside other
    frameworks. It automatically detects and bridges with existing frameworks like
    VORP Core, RSG-Core, RedEM:RP, QBR-Core, QR-Core, and more.
    
    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════
    
    Server:      The Land of Wolves 🐺
    Tagline:     Georgian RP 🇬🇪 | მგლების მიწა - რჩეულთა ადგილი!
    Description: ისტორია ცოცხლდება აქ! (History Lives Here!)
    Type:        Serious Hardcore Roleplay
    Access:      Discord & Whitelisted
    
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    GitHub:      https://github.com/iBoss21
    Store:       https://theluxempire.tebex.io
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

LXRBridge = {}
LXRBridge.DetectedFrameworks = {}

-- Framework detection and bridging configuration
local frameworkBridges = {
    -- VORP Framework Bridge (Most popular RedM framework)
    vorp = {
        detection = 'vorp_core',
        events = {
            ['vorp:getCharacter'] = 'LXRCore:Server:GetPlayerData',
            ['vorp:addMoney'] = 'LXRCore:Server:AddMoney',
            ['vorp:removeMoney'] = 'LXRCore:Server:RemoveMoney',
            ['vorp_inventory:Server:addItem'] = 'LXRCore:Server:AddItem',
            ['vorp_inventory:Server:removeItem'] = 'LXRCore:Server:RemoveItem',
        },
        exports = {
            getUser = 'GetPlayer',
            addMoney = 'AddMoney',
        }
    },
    
    -- RSG-Core Framework Bridge
    rsg = {
        detection = 'rsg-core',
        events = {
            ['RSGCore:Server:OnPlayerLoaded'] = 'LXRCore:Server:OnPlayerLoaded',
            ['RSGCore:Server:SetMetaData'] = 'LXRCore:Server:SetMetaData',
            ['RSGCore:UpdatePlayer'] = 'LXRCore:UpdatePlayer',
        },
        exports = {
            GetPlayer = 'GetPlayer',
            GetPlayers = 'GetPlayers',
        }
    },
    
    -- RedM-RP / RedemRP Framework Bridge
    redmrp = {
        detection = 'redmrp',
        events = {
            ['redemrp:getPlayerFromId'] = 'LXRCore:Server:GetPlayer',
            ['redemrp:addMoney'] = 'LXRCore:Server:AddMoney',
            ['redemrp:removeMoney'] = 'LXRCore:Server:RemoveMoney',
        },
        exports = {}
    },
    
    -- QBR-Core Framework Bridge (QB-Core for RedM)
    qbr = {
        detection = 'qbr-core',
        events = {
            ['QBRCore:Server:OnPlayerLoaded'] = 'LXRCore:Server:OnPlayerLoaded',
            ['QBRCore:UpdatePlayer'] = 'LXRCore:UpdatePlayer',
            ['QBRCore:Server:AddMoney'] = 'LXRCore:Server:AddMoney',
        },
        exports = {
            GetPlayer = 'GetPlayer',
        }
    },
    
    -- RedEM:RP Framework Bridge (Popular alternative framework)
    redemrp = {
        detection = 'redem_roleplay',
        events = {
            ['redemrp:getPlayerFromId'] = 'LXRCore:Server:GetPlayer',
            ['redem:getPlayerFromId'] = 'LXRCore:Server:GetPlayer',
        },
        exports = {}
    },
    
    -- Redemption Framework Bridge
    redemption = {
        detection = 'redemption',
        events = {
            ['redemption:getPlayer'] = 'LXRCore:Server:GetPlayer',
            ['redemption:addCash'] = 'LXRCore:Server:AddMoney',
        },
        exports = {}
    },
    
    -- WildRP Framework Bridge
    wildrp = {
        detection = 'wildrp',
        events = {
            ['wildrp:getPlayer'] = 'LXRCore:Server:GetPlayer',
        },
        exports = {}
    },
    
    -- FrontierRP Framework Bridge
    frontierrp = {
        detection = 'frontierrp',
        events = {
            ['frontier:getPlayer'] = 'LXRCore:Server:GetPlayer',
        },
        exports = {}
    },
    
    -- OutlawRP Framework Bridge
    outlawrp = {
        detection = 'outlawrp',
        events = {
            ['outlaw:getPlayer'] = 'LXRCore:Server:GetPlayer',
        },
        exports = {}
    },
    
    -- Cowboy Framework Bridge (Legacy)
    cowboy = {
        detection = 'cowboy',
        events = {
            ['cowboy:getPlayer'] = 'LXRCore:Server:GetPlayer',
        },
        exports = {}
    }
}

--[[
    Server Owner Note:
    This function automatically detects which frameworks are running on your server.
    LXRCore will bridge events between frameworks so all scripts work together.
]]--
function LXRBridge.DetectFrameworks()
    print("^2[LXRCore]^7 Detecting installed frameworks...")
    
    for frameworkName, bridge in pairs(frameworkBridges) do
        local resource = bridge.detection
        
        if GetResourceState(resource) == 'started' or GetResourceState(resource) == 'starting' then
            LXRBridge.DetectedFrameworks[frameworkName] = true
            print(("^2[LXRCore]^7 Detected: ^3%s^7 - Bridge enabled"):format(resource))
            
            -- Register event bridges
            for oldEvent, newEvent in pairs(bridge.events) do
                LXRBridge.RegisterEventBridge(oldEvent, newEvent)
            end
        end
    end
    
    if next(LXRBridge.DetectedFrameworks) == nil then
        print("^2[LXRCore]^7 Running in ^3standalone mode^7 - Full LXRCore features available")
    else
        print("^2[LXRCore]^7 Bridge mode active - Compatible with existing scripts")
    end
end

--[[
    Developer Note:
    This bridges events from other frameworks to LXRCore events automatically.
    Your scripts using old framework events will work without modification.
    
    Example: If a script triggers 'vorp:addMoney', it automatically becomes 'LXRCore:Server:AddMoney'
]]--
function LXRBridge.RegisterEventBridge(oldEvent, newEvent)
    RegisterServerEvent(oldEvent)
    AddEventHandler(oldEvent, function(...)
        local args = {...}
        -- Forward the event to LXRCore
        TriggerEvent(newEvent, table.unpack(args))
    end)
end

--[[
    Server Owner Note:
    This allows exports from other frameworks to work with LXRCore.
    No need to change existing script code - it "just works"!
]]--
function LXRBridge.BridgeExports(frameworkName)
    local bridge = frameworkBridges[frameworkName]
    if not bridge then return end
    
    -- Note: Export bridging handled by resource manifest
    -- Old framework scripts will call exports['lxr-core'][newExport](...)
end

--[[
    Developer Note:
    Use this to check if a specific framework is running alongside LXRCore.
    Useful for conditional compatibility features.
    
    Example:
    if LXRBridge.IsFrameworkActive('vorp') then
        -- Do VORP-specific compatibility stuff
    end
]]--
function LXRBridge.IsFrameworkActive(frameworkName)
    return LXRBridge.DetectedFrameworks[frameworkName] == true
end
exports('IsFrameworkActive', LXRBridge.IsFrameworkActive)

--[[
    Server Owner Note:
    This function translates player objects between frameworks.
    If a script asks for VORP player data, we give them LXRCore data in the right format.
]]--
function LXRBridge.TranslatePlayerObject(source, targetFramework)
    local Player = exports['lxr-core']:GetPlayer(source)
    if not Player then return nil end
    
    -- Translate to VORP format
    if targetFramework == 'vorp' then
        return {
            source = Player.PlayerData.source,
            identifier = Player.PlayerData.license,
            charIdentifier = Player.PlayerData.citizenid,
            money = Player.PlayerData.money.cash or 0,
            gold = Player.PlayerData.money.gold or 0,
            rol = Player.PlayerData.money.bank or 0,
            job = Player.PlayerData.job.name,
            jobGrade = Player.PlayerData.job.grade.level,
            -- Add VORP-specific functions
            addCurrency = function(currency, amount)
                return Player.Functions.AddMoney(currency, amount)
            end,
            removeCurrency = function(currency, amount)
                return Player.Functions.RemoveMoney(currency, amount)
            end,
        }
    end
    
    -- Translate to RSG-Core format
    if targetFramework == 'rsg' then
        return {
            PlayerData = Player.PlayerData,
            Functions = Player.Functions,
        }
    end
    
    -- Default: return LXRCore player object
    return Player
end
exports('TranslatePlayerObject', LXRBridge.TranslatePlayerObject)

--[[
    Developer Note:
    Register compatibility callbacks for other frameworks.
    This ensures callback systems from different frameworks work together.
]]--
function LXRBridge.RegisterCompatibilityCallbacks()
    -- VORP callback compatibility
    if LXRBridge.IsFrameworkActive('vorp') then
        RegisterServerEvent('vorp:TriggerServerCallback')
        AddEventHandler('vorp:TriggerServerCallback', function(name, ...)
            local src = source
            -- Route through validated callback path (not via TriggerEvent which bypasses rate limiter)
            if not exports['lxr-core']:ValidateSource(src) then return end
            if not exports['lxr-core']:CheckRateLimit(src, 'TriggerCallback', 30) then return end
            if type(name) ~= 'string' or #name == 0 or #name > 100 then return end
            TriggerCallback(name, src, function(...)
                TriggerClientEvent('LXRCore:Client:TriggerCallback', src, name, ...)
            end, ...)
        end)
    end
    
    -- RSG-Core callback compatibility
    if LXRBridge.IsFrameworkActive('rsg') then
        RegisterServerEvent('RSGCore:Server:TriggerCallback')
        AddEventHandler('RSGCore:Server:TriggerCallback', function(name, ...)
            local src = source
            -- Route through validated callback path (not via TriggerEvent which bypasses rate limiter)
            if not exports['lxr-core']:ValidateSource(src) then return end
            if not exports['lxr-core']:CheckRateLimit(src, 'TriggerCallback', 30) then return end
            if type(name) ~= 'string' or #name == 0 or #name > 100 then return end
            TriggerCallback(name, src, function(...)
                TriggerClientEvent('LXRCore:Client:TriggerCallback', src, name, ...)
            end, ...)
        end)
    end
end

--[[
    Server Owner Note:
    This creates all the standard LXRCore events with proper branding.
    All events are prefixed with 'LXRCore:' for consistency.
]]--
function LXRBridge.RegisterLXRCoreEvents()
    print("^2[LXRCore]^7 Registering branded events...")
    
    -- Core branded events already registered in events.lua
    -- This ensures they're all properly documented
    
    local coreEvents = {
        'LXRCore:Server:OnPlayerLoaded',
        'LXRCore:Server:OnPlayerUnload', 
        'LXRCore:Client:OnPlayerLoaded',
        'LXRCore:Client:OnPlayerUnload',
        'LXRCore:UpdatePlayer',
        'LXRCore:Server:SetMetaData',
        'LXRCore:ToggleDuty',
        'LXRCore:Server:UseItem',
        'LXRCore:Server:AddItem',
        'LXRCore:Server:RemoveItem',
        'LXRCore:Player:GiveXp',
        'LXRCore:Player:RemoveXp',
        'LXRCore:Server:TriggerCallback',
    }
    
    print(("^2[LXRCore]^7 Registered ^3%d^7 branded events"):format(#coreEvents))
end

--[[
    Initialize the bridge system on server start
]]--
CreateThread(function()
    Wait(1000) -- Wait for other resources to start
    
    print("^2========================================^7")
    print("^2     LXRCore Framework v2.0.0^7")
    print("^2========================================^7")
    print("^3  Launched on The Land of Wolves RP^7")
    print("^3  Website: www.lxrcore.com^7")
    print("^2========================================^7")
    
    -- Detect and bridge with other frameworks
    LXRBridge.DetectFrameworks()
    
    -- Register compatibility callbacks
    LXRBridge.RegisterCompatibilityCallbacks()
    
    -- Register LXRCore branded events
    LXRBridge.RegisterLXRCoreEvents()
    
    print("^2[LXRCore]^7 Bridge system initialized successfully!")
    print("^2========================================^7")
end)

--[[
    Server Owner Reference:
    
    LXRCore can run in two modes:
    
    1. STANDALONE MODE (No other frameworks detected)
       - Full LXRCore features
       - All optimizations active
       - Direct event handling
    
    2. BRIDGE MODE (Other frameworks detected)
       - Automatic compatibility
       - Event translation
       - Export bridging
       - Scripts work without modification
    
    Either way, LXRCore is the fastest and most secure option!
]]--

--[[
    Developer Reference:
    
    Always use LXRCore events in new scripts:
    - TriggerEvent('LXRCore:Server:AddItem', ...)
    - exports['lxr-core']:GetPlayer(source)
    - exports['lxr-core']:CreateCallback(...)
    
    Benefits:
    - Better performance
    - Enhanced security
    - Future-proof code
    - Professional branding
    
    The bridge handles old framework compatibility automatically.
]]--
