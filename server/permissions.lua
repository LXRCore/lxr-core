--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Permissions (server)
     ═══════════════════════════════════════════════════════════════════════════
     ACE-backed permission model (the only model the FXServer runtime enforces
     natively, so txAdmin / server.cfg principals keep working):

       add_ace lxrcore.<group> <group> allow        (created at boot per group)
       add_principal identifier.license:… lxrcore.admin   (server.cfg / txAdmin)

     LXRCore.Perms.Has(src, 'admin')            → boolean (string or list)
     LXRCore.Perms.Add(src, 'admin')            → runtime grant (player.<src>)
     LXRCore.Perms.Remove(src, 'admin' | nil)  → revoke one or all groups
     LXRCore.Perms.Get(src)                     → { admin = true, … }
     LXRCore.Perms.Group(src)                   → highest group name ('user' default)

     When Compat.rsg is enabled, `rsgcore.<group>` principals are aliased so an
     RSG server.cfg needs no edits.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Perms = {}
local Perms = LXRCore.Perms

local function groups()
    return Config.Server.permissions or {}
end

---Create aces for every configured group. Idempotent.
function Perms.Boot()
    for _, group in ipairs(groups()) do
        ExecuteCommand(('add_ace lxrcore.%s %s allow'):format(group, group))
        ExecuteCommand(('add_ace lxrcore.%s lxrcore.%s allow'):format(group, group))
        if Config.Compat.rsg.enabled then
            -- rsgcore.<group> principals inherit the same aces
            ExecuteCommand(('add_principal rsgcore.%s lxrcore.%s'):format(group, group))
        end
    end
    -- god can run every command
    ExecuteCommand('add_ace lxrcore.god command allow')
    ExecuteCommand('add_ace lxrcore.god lxrcore.join allow')
end

---@param source integer
---@param permission string|string[]
---@return boolean
function Perms.Has(source, permission)
    source = LXRCore.ToSource(source)
    if not source then return false end
    if type(permission) == 'table' then
        for _, p in ipairs(permission) do
            if IsPlayerAceAllowed(source, p) then return true end
        end
        return false
    end
    if type(permission) ~= 'string' then return false end
    return IsPlayerAceAllowed(source, permission) == true
end

---Grant a group at runtime (lasts until the player disconnects or server restarts).
function Perms.Add(source, permission)
    source = LXRCore.ToSource(source)
    if not source or type(permission) ~= 'string' then return false end
    if Perms.Has(source, permission) then return true end
    ExecuteCommand(('add_principal player.%s lxrcore.%s'):format(source, permission))
    LXRCore.Commands.Refresh(source)
    LXRCore.Log.info('perm', 'permission granted', { source = source, permission = permission, by = LXRCore.Invoker() })
    return true
end

---Revoke one group, or every configured group when `permission` is nil.
function Perms.Remove(source, permission)
    source = LXRCore.ToSource(source)
    if not source then return false end
    local list = permission and { permission } or groups()
    for _, p in ipairs(list) do
        if Perms.Has(source, p) then
            ExecuteCommand(('remove_principal player.%s lxrcore.%s'):format(source, p))
        end
    end
    LXRCore.Commands.Refresh(source)
    LXRCore.Log.info('perm', 'permission revoked', { source = source, permission = permission or 'all', by = LXRCore.Invoker() })
    return true
end

---@return table<string, boolean>
function Perms.Get(source)
    local out = {}
    source = LXRCore.ToSource(source)
    if not source then return out end
    for _, p in ipairs(groups()) do
        if IsPlayerAceAllowed(source, p) then out[p] = true end
    end
    return out
end

---Highest configured group (order of Config.Server.permissions), 'user' when none.
---@return string
function Perms.Group(source)
    source = LXRCore.ToSource(source)
    if not source then return 'user' end
    for _, p in ipairs(groups()) do
        if IsPlayerAceAllowed(source, p) then return p end
    end
    return 'user'
end

---Whitelist gate used by the connection handler.
function Perms.IsWhitelisted(source)
    if not Config.Server.whitelist then return true end
    return Perms.Has(source, Config.Server.whitelistPermission)
end

-- RSG / QBR-shaped aliases
LXRCore.Functions.HasPermission = Perms.Has
LXRCore.Functions.AddPermission = Perms.Add
LXRCore.Functions.RemovePermission = Perms.Remove
LXRCore.Functions.GetPermission = Perms.Get
LXRCore.Functions.GetPermissions = Perms.Get
LXRCore.Functions.IsWhitelisted = Perms.IsWhitelisted

exports('HasPermission', Perms.Has)
exports('AddPermission', Perms.Add)
exports('RemovePermission', Perms.Remove)
exports('GetPermissions', Perms.Get)
exports('GetPermissionGroup', Perms.Group)
