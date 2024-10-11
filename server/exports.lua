-- Single add job function which should only be used if you planning on adding a single job
exports('AddJob', function(jobName, job)
    if type(jobName) ~= "string" then
        return false, "invalid_job_name"
    end

    if LXRShared.Jobs[jobName] then
        return false, "job_exists"
    end

    LXRShared.Jobs[jobName] = job
    TriggerClientEvent('LXRCore:Client:OnSharedUpdate', -1,'Jobs', jobName, job)
    TriggerEvent('LXRCore:Server:UpdateObject')
    return true, "success"
end)

-- Multiple Add Jobs
exports('AddJobs', function(jobs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil
    for key, value in pairs(jobs) do
        if type(key) ~= "string" then
            message = 'invalid_job_name'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        if LXRShared.Jobs[key] then
            message = 'job_exists'
            shouldContinue = false
            errorItem = jobs[key]
            break
        end

        LXRShared.Jobs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('LXRCore:Client:OnSharedUpdateMultiple', -1, 'Jobs', jobs)
    TriggerEvent('LXRCore:Server:UpdateObject')
    return true, message, nil
end)

-- Single add item
exports('AddItem', function(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if LXRShared.Items[itemName] then
        return false, "item_exists"
    end

    LXRShared.Items[itemName] = item
    TriggerClientEvent('LXRCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('LXRCore:Server:UpdateObject')
    return true, "success"
end)

-- Multiple Add Items
exports('AddItems', function(items)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil
    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if LXRShared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        LXRShared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('LXRCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('LXRCore:Server:UpdateObject')
    return true, message, nil
end)

-- Single Add Gang
exports('AddGang', function(gangName, gang)
    if type(gangName) ~= "string" then
        return false, "invalid_gang_name"
    end
    if LXRShared.Gangs[gangName] then
        return false, "gang_exists"
    end

    LXRShared.Gangs[gangName] = gang
    TriggerClientEvent('LXRCore:Client:OnSharedUpdate', -1, 'Gangs', gangName, gang)
    TriggerEvent('LXRCore:Server:UpdateObject')
    return true, "success"
end)

-- Multiple Add Gangs
exports('AddGangs', function(gangs)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil
    for key, value in pairs(gangs) do
        if type(key) ~= "string" then
            message = "invalid_gang_name"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end

        if LXRShared.Gangs[key] then
            message = "gang_exists"
            shouldContinue = false
            errorItem = gangs[key]
            break
        end
        LXRShared.Gangs[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('LXRCore:Client:OnSharedUpdateMultiple', -1, 'Gangs', gangs)
    TriggerEvent('LXRCore:Server:UpdateObject')
    return true, message, nil
end)
