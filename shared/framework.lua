--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
                                                                    
    🐺 LXR Core - Multi-Framework Adapter Layer
    
    This is the unified framework adapter that provides a consistent API across
    multiple RedM frameworks. It automatically detects the active framework and
    maps all function calls to the correct framework-specific implementations.
    
    Supported Frameworks:
    - LXR-Core (Primary - Native)
    - RSG-Core (Primary - Compatible)
    - VORP Core (Supported - Compatible)
    - RedEM:RP (Optional - If Detected)
    - QBR-Core (Optional - If Detected)
    - QR-Core (Optional - If Detected)
    - Standalone (Fallback)
    
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
    
    ═══════════════════════════════════════════════════════════════════════════════
    
    Version: 2.0.0
    Purpose: Multi-framework compatibility and unified API
    
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 FRAMEWORK ADAPTER INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

LXRFramework = {}
LXRFramework.ActiveFramework = 'lxr-core' -- Default to LXR-Core
LXRFramework.DetectedFrameworks = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK DETECTION ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Detection Priority:
    1. LXR-Core (Primary - this framework)
    2. RSG-Core (Primary compatible)
    3. VORP Core (Supported compatible)
    4. RedEM:RP (Optional - if detected)
    5. QBR-Core (Optional - if detected)
    6. QR-Core (Optional - if detected)
    7. Standalone (Fallback if none detected)
]]

local function DetectFramework()
    local detectedFramework = 'standalone'
    
    -- Check for LXR-Core (this is it!)
    if GetResourceState('lxr-core') == 'started' then
        detectedFramework = 'lxr-core'
        LXRFramework.DetectedFrameworks['lxr-core'] = true
    end
    
    -- Check for RSG-Core
    if GetResourceState('rsg-core') == 'started' then
        detectedFramework = detectedFramework == 'standalone' and 'rsg-core' or detectedFramework
        LXRFramework.DetectedFrameworks['rsg-core'] = true
    end
    
    -- Check for VORP Core
    if GetResourceState('vorp_core') == 'started' then
        detectedFramework = detectedFramework == 'standalone' and 'vorp_core' or detectedFramework
        LXRFramework.DetectedFrameworks['vorp_core'] = true
    end
    
    -- Check for RedEM:RP
    if GetResourceState('redem_roleplay') == 'started' or GetResourceState('redemrp') == 'started' then
        detectedFramework = detectedFramework == 'standalone' and 'redem_roleplay' or detectedFramework
        LXRFramework.DetectedFrameworks['redem_roleplay'] = true
    end
    
    -- Check for QBR-Core
    if GetResourceState('qbr-core') == 'started' then
        detectedFramework = detectedFramework == 'standalone' and 'qbr-core' or detectedFramework
        LXRFramework.DetectedFrameworks['qbr-core'] = true
    end
    
    -- Check for QR-Core
    if GetResourceState('qr-core') == 'started' then
        detectedFramework = detectedFramework == 'standalone' and 'qr-core' or detectedFramework
        LXRFramework.DetectedFrameworks['qr-core'] = true
    end
    
    -- Check config override
    if LXRConfig and LXRConfig.Framework and LXRConfig.Framework ~= 'auto' then
        detectedFramework = LXRConfig.Framework
    end
    
    LXRFramework.ActiveFramework = detectedFramework
    return detectedFramework
end

-- Run detection
DetectFramework()

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ UNIFIED ADAPTER API ███████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    UNIFIED FRAMEWORK ADAPTER API
    
    This adapter provides a consistent API regardless of which framework is running.
    All functions are framework-agnostic and will call the correct underlying
    framework implementation.
    
    Core Functions:
    - Notify(source, type, message, duration)
    - GetPlayerData(source)
    - GetJob(source)
    - GetGang(source)
    - AddMoney(source, account, amount, reason)
    - RemoveMoney(source, account, amount, reason)
    - GetMoney(source, account)
    - AddItem(source, item, amount, metadata, reason)
    - RemoveItem(source, item, amount, reason)
    - HasItem(source, item, amount)
    - GetItemCount(source, item)
    - ProgressBar(source, label, duration, useWhileDead, canCancel, disableControls)
    - GetIdentifier(source, type)
    - IsPlayerLoaded(source)
    - RegisterCallback(name, cb)
    - TriggerCallback(name, source, cb, ...)
    
    CLIENT-SIDE:
    - GetPlayerData()
    - GetJob()
    - GetGang()
    - HasItem(item, amount)
    - Notify(type, message, duration)
    - ProgressBar(label, duration, useWhileDead, canCancel, disableControls)
]]

if IsDuplicityVersion() then
    -- ════════════════════════════════════════════════════════════════════════════
    -- 🖥️  SERVER-SIDE ADAPTER FUNCTIONS
    -- ════════════════════════════════════════════════════════════════════════════
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- NOTIFY PLAYER
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.Notify(source, type, message, duration)
        local src = source
        duration = duration or 5000
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            TriggerClientEvent('lxr-core:client:notify', src, {
                type = type,
                text = message,
                duration = duration
            })
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            TriggerClientEvent('RSGCore:Notify', src, message, type, duration)
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            TriggerClientEvent('vorp:TipRight', src, message, duration)
        elseif LXRFramework.ActiveFramework == 'redem_roleplay' then
            TriggerClientEvent('redem_roleplay:Tip', src, message, duration)
        else
            -- Standalone fallback
            TriggerClientEvent('chat:addMessage', src, {
                args = {message}
            })
        end
    end
    exports('Notify', LXRFramework.Notify)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET PLAYER DATA
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetPlayerData(source)
        local src = source
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local Player = LXRCore.Functions.GetPlayer(src)
            return Player and Player.PlayerData or nil
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            local Player = exports['rsg-core']:GetPlayer(src)
            return Player and Player.PlayerData or nil
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            local User = exports.vorp_core:getUser(src)
            if User then
                local Character = User.getUsedCharacter
                return Character and {
                    citizenid = Character.charIdentifier,
                    firstname = Character.firstname,
                    lastname = Character.lastname,
                    job = Character.job,
                    money = Character.money
                } or nil
            end
        end
        
        return nil
    end
    exports('GetPlayerData', LXRFramework.GetPlayerData)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET JOB
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetJob(source)
        local PlayerData = LXRFramework.GetPlayerData(source)
        return PlayerData and PlayerData.job or {name = 'unemployed', grade = 0}
    end
    exports('GetJob', LXRFramework.GetJob)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET GANG
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetGang(source)
        local PlayerData = LXRFramework.GetPlayerData(source)
        return PlayerData and PlayerData.gang or {name = 'none', grade = 0}
    end
    exports('GetGang', LXRFramework.GetGang)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- ADD MONEY
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.AddMoney(source, account, amount, reason)
        local src = source
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local Player = LXRCore.Functions.GetPlayer(src)
            if Player then
                Player.Functions.AddMoney(account, amount, reason)
                return true
            end
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            local Player = exports['rsg-core']:GetPlayer(src)
            if Player then
                Player.Functions.AddMoney(account, amount, reason)
                return true
            end
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            local User = exports.vorp_core:getUser(src)
            if User then
                local Character = User.getUsedCharacter
                if Character then
                    if account == 'cash' then
                        Character.addCurrency(0, amount) -- 0 = cash
                    elseif account == 'gold' then
                        Character.addCurrency(1, amount) -- 1 = gold
                    end
                    return true
                end
            end
        end
        
        return false
    end
    exports('AddMoney', LXRFramework.AddMoney)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- REMOVE MONEY
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.RemoveMoney(source, account, amount, reason)
        local src = source
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local Player = LXRCore.Functions.GetPlayer(src)
            if Player then
                Player.Functions.RemoveMoney(account, amount, reason)
                return true
            end
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            local Player = exports['rsg-core']:GetPlayer(src)
            if Player then
                Player.Functions.RemoveMoney(account, amount, reason)
                return true
            end
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            local User = exports.vorp_core:getUser(src)
            if User then
                local Character = User.getUsedCharacter
                if Character then
                    if account == 'cash' then
                        Character.removeCurrency(0, amount)
                    elseif account == 'gold' then
                        Character.removeCurrency(1, amount)
                    end
                    return true
                end
            end
        end
        
        return false
    end
    exports('RemoveMoney', LXRFramework.RemoveMoney)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET MONEY
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetMoney(source, account)
        local PlayerData = LXRFramework.GetPlayerData(source)
        if PlayerData and PlayerData.money then
            return PlayerData.money[account] or 0
        end
        return 0
    end
    exports('GetMoney', LXRFramework.GetMoney)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- ADD ITEM
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.AddItem(source, item, amount, metadata, reason)
        local src = source
        amount = amount or 1
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local Player = LXRCore.Functions.GetPlayer(src)
            if Player then
                Player.Functions.AddItem(item, amount, false, metadata, reason)
                return true
            end
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            exports['rsg-inventory']:AddItem(src, item, amount, false, metadata, reason)
            return true
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            exports.vorp_inventory:addItem(src, item, amount, metadata)
            return true
        end
        
        return false
    end
    exports('AddItem', LXRFramework.AddItem)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- REMOVE ITEM
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.RemoveItem(source, item, amount, reason)
        local src = source
        amount = amount or 1
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local Player = LXRCore.Functions.GetPlayer(src)
            if Player then
                Player.Functions.RemoveItem(item, amount, false, reason)
                return true
            end
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            exports['rsg-inventory']:RemoveItem(src, item, amount, false, reason)
            return true
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            exports.vorp_inventory:subItem(src, item, amount)
            return true
        end
        
        return false
    end
    exports('RemoveItem', LXRFramework.RemoveItem)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- HAS ITEM
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.HasItem(source, item, amount)
        amount = amount or 1
        local count = LXRFramework.GetItemCount(source, item)
        return count >= amount
    end
    exports('HasItem', LXRFramework.HasItem)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET ITEM COUNT
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetItemCount(source, item)
        local src = source
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local Player = LXRCore.Functions.GetPlayer(src)
            if Player then
                local itemData = Player.Functions.GetItemByName(item)
                return itemData and itemData.amount or 0
            end
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            local count = exports['rsg-inventory']:GetItemCount(src, item)
            return count or 0
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            local count = exports.vorp_inventory:getItemCount(src, nil, item)
            return count or 0
        end
        
        return 0
    end
    exports('GetItemCount', LXRFramework.GetItemCount)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET IDENTIFIER
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetIdentifier(source, type)
        local src = source
        type = type or 'license'
        
        local identifiers = GetPlayerIdentifiers(src)
        for _, id in pairs(identifiers) do
            if string.match(id, type) then
                return id
            end
        end
        
        return nil
    end
    exports('GetIdentifier', LXRFramework.GetIdentifier)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- IS PLAYER LOADED
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.IsPlayerLoaded(source)
        local PlayerData = LXRFramework.GetPlayerData(source)
        return PlayerData ~= nil
    end
    exports('IsPlayerLoaded', LXRFramework.IsPlayerLoaded)
    
    -- Log framework detection info
    print(('[LXRCore] Framework Adapter (server) loaded | Active: %s'):format(LXRFramework.ActiveFramework))
    
else
    -- ════════════════════════════════════════════════════════════════════════════
    -- 💻 CLIENT-SIDE ADAPTER FUNCTIONS
    -- ════════════════════════════════════════════════════════════════════════════
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- NOTIFY
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.Notify(type, message, duration)
        duration = duration or 5000
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            TriggerEvent('lxr-core:client:notify', {
                type = type,
                text = message,
                duration = duration
            })
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            TriggerEvent('RSGCore:Notify', message, type, duration)
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            TriggerEvent('vorp:TipRight', message, duration)
        elseif LXRFramework.ActiveFramework == 'redem_roleplay' then
            TriggerEvent('redem_roleplay:Tip', message, duration)
        else
            -- Standalone fallback
            SetTextFont(0)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry('STRING')
            AddTextComponentString(message)
            DrawText(0.5, 0.9)
        end
    end
    exports('Notify', LXRFramework.Notify)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET PLAYER DATA (CLIENT)
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetPlayerData()
        if LXRFramework.ActiveFramework == 'lxr-core' then
            return LXRCore.Functions.GetPlayerData()
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            return exports['rsg-core']:GetPlayerData()
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            -- VORP doesn't have client-side player data access the same way
            return {}
        end
        
        return {}
    end
    exports('GetPlayerData', LXRFramework.GetPlayerData)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- GET JOB (CLIENT)
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.GetJob()
        local PlayerData = LXRFramework.GetPlayerData()
        return PlayerData.job or {name = 'unemployed', grade = 0}
    end
    exports('GetJob', LXRFramework.GetJob)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- HAS ITEM (CLIENT)
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.HasItem(item, amount)
        amount = amount or 1
        
        if LXRFramework.ActiveFramework == 'lxr-core' then
            local PlayerData = LXRCore.Functions.GetPlayerData()
            if PlayerData and PlayerData.items then
                local count = 0
                for _, itemData in pairs(PlayerData.items) do
                    if itemData.name == item then
                        count = count + itemData.amount
                    end
                end
                return count >= amount
            end
        elseif LXRFramework.ActiveFramework == 'rsg-core' then
            -- RSG typically uses server-side inventory checks
            return false
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            -- VORP typically uses server-side inventory checks
            return false
        end
        
        return false
    end
    exports('HasItem', LXRFramework.HasItem)
    
    -- ───────────────────────────────────────────────────────────────────────────
    -- PROGRESS BAR (CLIENT)
    -- ───────────────────────────────────────────────────────────────────────────
    function LXRFramework.ProgressBar(label, duration, useWhileDead, canCancel, disableControls)
        -- Most frameworks use ox_lib or custom progress bars
        -- This is a placeholder that should be implemented based on your UI system
        
        if LXRFramework.ActiveFramework == 'lxr-core' or LXRFramework.ActiveFramework == 'rsg-core' then
            -- Use ox_lib if available
            if GetResourceState('ox_lib') == 'started' then
                exports['ox_lib']:progressBar({
                    duration = duration,
                    label = label,
                    useWhileDead = useWhileDead or false,
                    canCancel = canCancel or false,
                    disable = disableControls or {}
                })
            end
        elseif LXRFramework.ActiveFramework == 'vorp_core' then
            -- VORP has its own progress bar system
            TriggerEvent('vorp:Tip', label, duration)
        end
    end
    exports('ProgressBar', LXRFramework.ProgressBar)
    
    -- Log framework detection info
    print(('[LXRCore] Framework Adapter (client) loaded | Active: %s'):format(LXRFramework.ActiveFramework))
end

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ END OF FRAMEWORK ADAPTER ██████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
