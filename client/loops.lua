local sid, isLoggedIn = GetPlayerServerId(PlayerId())

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(sid), function(_, _, value)
    isLoggedIn = value
end)

CreateThread(function()
    while true do
        Wait(0)
        if isLoggedIn then
            Wait((1000 * 60) * LXRConfig.UpdateInterval)
            TriggerServerEvent('LXRCore:UpdatePlayer')
        end
    end
end)
