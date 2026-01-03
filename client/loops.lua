local sid, isLoggedIn = GetPlayerServerId(PlayerId())

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(sid), function(_, _, value)
    isLoggedIn = value
end)

-- Performance: Optimized loop with proper wait times
CreateThread(function()
    while true do
        if isLoggedIn then
            Wait((1000 * 60) * LXRConfig.UpdateInterval)
            TriggerServerEvent('LXRCore:UpdatePlayer')
        else
            -- Wait longer when not logged in to save resources
            Wait(5000)
        end
    end
end)
