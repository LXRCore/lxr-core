--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Roles: Jobs, Gangs & Shared Registry (server)
     ═══════════════════════════════════════════════════════════════════════════
     • LXRCore.Roles.BuildJob(name, grade)  → validated job table or nil, err
     • LXRCore.Roles.BuildGang(name, grade) → validated gang table or nil, err
     • Registry mutations broadcast to every client so LXRShared stays identical
       on both sides: AddJob(s) / UpdateJob / RemoveJob, AddGang(s) / UpdateGang /
       RemoveGang. Nothing in the framework hard-codes a job name; resources rely
       on job.type / job.name / job.isboss.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCore.Roles = {}
local Roles = LXRCore.Roles

local function gradeKey(grade)
    grade = tonumber(grade) or 0
    return tostring(math.floor(grade)), math.floor(grade)
end

---Build a normalised job table from the shared registry.
---@param name string
---@param grade integer|string|nil
---@param onduty boolean|nil
---@return table|nil job, string|nil err
function Roles.BuildJob(name, grade, onduty)
    if type(name) ~= 'string' then return nil, 'invalid_job' end
    name = name:lower()
    local def = LXRShared.Jobs[name]
    if not def then return nil, 'invalid_job' end
    local key, level = gradeKey(grade)
    local grades = def.grades or {}
    local g = grades[key]
    if not g then
        -- fall back to grade 0 when the requested grade does not exist
        key, level = '0', 0
        g = grades['0']
        if not g then return nil, 'invalid_grade' end
        if grade ~= nil and tostring(grade) ~= '0' then
            LXRCore.Log.debug('roles', 'grade missing, using 0', { job = name, grade = grade })
        end
    end
    local isboss = g.isboss == true
    local payment = tonumber(g.payment) or 0
    if onduty == nil then
        onduty = def.defaultDuty ~= false
    end
    return {
        name = name,
        label = def.label or name,
        type = def.type or 'none',
        onduty = onduty == true,
        isboss = isboss,
        payment = payment,
        grade = { name = g.name or ('Grade ' .. key), level = level, payment = payment, isboss = isboss },
    }
end

---@return table|nil gang, string|nil err
function Roles.BuildGang(name, grade)
    if type(name) ~= 'string' then return nil, 'invalid_gang' end
    name = name:lower()
    local def = LXRShared.Gangs[name]
    if not def then return nil, 'invalid_gang' end
    local key, level = gradeKey(grade)
    local grades = def.grades or {}
    local g = grades[key]
    if not g then
        key, level = '0', 0
        g = grades['0']
        if not g then return nil, 'invalid_grade' end
    end
    local isboss = g.isboss == true
    return {
        name = name,
        label = def.label or name,
        isboss = isboss,
        grade = { name = g.name or ('Grade ' .. key), level = level, isboss = isboss },
    }
end

---Re-validate a stored job against the current registry (used on login).
---Returns a rebuilt job or the default job when the stored one no longer exists.
function Roles.ValidateJob(stored)
    local name = type(stored) == 'table' and stored.name or nil
    local level = type(stored) == 'table' and type(stored.grade) == 'table' and stored.grade.level or 0
    local onduty
    if not LXRShared.ForceJobDefaultDutyAtLogin and type(stored) == 'table' then
        onduty = stored.onduty
    end
    local job = name and Roles.BuildJob(name, level, onduty)
    if job then return job end
    local d = Config.Player.defaults.job
    return Roles.BuildJob(d.name, d.grade.level, d.onduty)
end

function Roles.ValidateGang(stored)
    local name = type(stored) == 'table' and stored.name or nil
    local level = type(stored) == 'table' and type(stored.grade) == 'table' and stored.grade.level or 0
    local gang = name and Roles.BuildGang(name, level)
    if gang then return gang end
    local d = Config.Player.defaults.gang
    return Roles.BuildGang(d.name, d.grade.level)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📚 SHARED REGISTRY MUTATIONS (broadcast to clients)
-- ═══════════════════════════════════════════════════════════════════════════════

local function broadcastOne(tbl, key, value)
    LXRCore.EmitClient(-1, 'lxr:client:shared', { legacy = 'LXRCore:Client:OnSharedUpdate', rsg = 'RSGCore:Client:OnSharedUpdate' }, tbl, key, value)
    LXRCore.Emit('lxr:shared:updated', nil, tbl, key, value)
    LXRCore.NotifyObjectUpdate()
end

local function broadcastMany(tbl, values)
    LXRCore.EmitClient(-1, 'lxr:client:sharedMany', { legacy = 'LXRCore:Client:OnSharedUpdateMultiple', rsg = 'RSGCore:Client:OnSharedUpdateMultiple' }, tbl, values)
    LXRCore.Emit('lxr:shared:updated', nil, tbl, nil, values)
    LXRCore.NotifyObjectUpdate()
end

local function makeRegistry(tblName, singular)
    local store = LXRShared[tblName]
    local api = {}

    api.add = function(key, data)
        if type(key) ~= 'string' then return false, 'invalid_' .. singular .. '_name' end
        if store[key] then return false, singular .. '_exists' end
        if type(data) ~= 'table' then return false, 'invalid_' .. singular .. '_data' end
        data.name = data.name or key
        store[key] = data
        broadcastOne(tblName, key, data)
        return true, 'success'
    end

    api.addMany = function(list)
        if type(list) ~= 'table' then return false, 'invalid_' .. singular .. '_data' end
        for key, data in pairs(list) do
            if type(key) ~= 'string' then return false, 'invalid_' .. singular .. '_name', data end
            if store[key] then return false, singular .. '_exists', data end
        end
        for key, data in pairs(list) do
            data.name = data.name or key
            store[key] = data
        end
        broadcastMany(tblName, list)
        return true, 'success', nil
    end

    api.update = function(key, data)
        if type(key) ~= 'string' then return false, 'invalid_' .. singular .. '_name' end
        if not store[key] then return false, singular .. '_not_exists' end
        if type(data) ~= 'table' then return false, 'invalid_' .. singular .. '_data' end
        data.name = data.name or key
        store[key] = data
        broadcastOne(tblName, key, data)
        return true, 'success'
    end

    api.remove = function(key)
        if type(key) ~= 'string' then return false, 'invalid_' .. singular .. '_name' end
        if not store[key] then return false, singular .. '_not_exists' end
        store[key] = nil
        broadcastOne(tblName, key, nil)
        return true, 'success'
    end

    return api
end

local jobs = makeRegistry('Jobs', 'job')
local gangs = makeRegistry('Gangs', 'gang')

Roles.AddJob, Roles.AddJobs, Roles.UpdateJob, Roles.RemoveJob = jobs.add, jobs.addMany, jobs.update, jobs.remove
Roles.AddGang, Roles.AddGangs, Roles.UpdateGang, Roles.RemoveGang = gangs.add, gangs.addMany, gangs.update, gangs.remove

-- RSG / QBR-shaped aliases + exports
LXRCore.Functions.AddJob, LXRCore.Functions.AddJobs = jobs.add, jobs.addMany
LXRCore.Functions.UpdateJob, LXRCore.Functions.RemoveJob = jobs.update, jobs.remove
LXRCore.Functions.AddGang, LXRCore.Functions.AddGangs = gangs.add, gangs.addMany
LXRCore.Functions.UpdateGang, LXRCore.Functions.RemoveGang = gangs.update, gangs.remove

exports('AddJob', jobs.add)
exports('AddJobs', jobs.addMany)
exports('UpdateJob', jobs.update)
exports('RemoveJob', jobs.remove)
exports('AddGang', gangs.add)
exports('AddGangs', gangs.addMany)
exports('UpdateGang', gangs.update)
exports('RemoveGang', gangs.remove)
exports('GetJobs', function() return LXRShared.Jobs end)
exports('GetGangs', function() return LXRShared.Gangs end)
