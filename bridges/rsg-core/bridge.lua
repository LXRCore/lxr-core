--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: rsg-core (shared)
     Every export the RSG ecosystem calls on 'rsg-core' is forwarded to lxr-core.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = 'lxr-core'

local function core()
    return exports[CORE]:GetCoreObject()
end

exports('GetCoreObject', core)
exports('GetCore', core)

-- Exports that RSG registers on rsg-core itself (server side only)
local forwarded = {
    'SetMethod', 'SetField', 'AddJob', 'AddJobs', 'RemoveJob', 'UpdateJob',
    'AddItem', 'AddItems', 'UpdateItem', 'RemoveItem',
    'AddGang', 'AddGangs', 'RemoveGang', 'UpdateGang',
    'GetCoreVersion', 'ExploitBan',
}

if IsDuplicityVersion() then
    for _, name in ipairs(forwarded) do
        exports(name, function(...)
            return exports[CORE][name](nil, ...)
        end)
    end

    CreateThread(function()
        local mine = GetCurrentResourceName()
        if mine ~= 'rsg-core' then
            print(('^1[LXRCore bridge]^7 this resource must be named "rsg-core" (currently "%s")'):format(mine))
        end
        print('^2[LXRCore bridge]^7 rsg-core shim active — RSG resources are served by lxr-core')
    end)
else
    -- rsg-inventory's NUI calls this export on rsg-core
    exports('GenerateCSRFToken', function()
        return exports[CORE]:GenerateCSRFToken()
    end)
end
