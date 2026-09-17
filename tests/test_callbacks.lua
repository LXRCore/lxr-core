-- callback system (server side)
local Shim = ...
T.suite('callbacks')

T.test('Register (return style) answers a client request by request id', function()
    Shim.clientEvents = {}
    LXRCore.Callback.Register('test:sum', function(src, a, b) return a + b, src end)
    Shim.netEvent(7, 'LXRCore:Server:Callback:Request', 'test:sum', 'req-1', 2, 3)
    local ev = Shim.clientEventsNamed('LXRCore:Client:Callback:Response')
    T.eq(#ev, 1)
    T.eq(ev[1].target, 7)
    T.eq(ev[1].args[1], 'req-1')
    T.eq(ev[1].args[2], true)
    T.eq(ev[1].args[3], 5)
    T.eq(ev[1].args[4], 7)
end)

T.test('CreateCallback (RSG cb style) works and double-answers are ignored', function()
    Shim.clientEvents = {}
    LXRCore.Functions.CreateCallback('test:legacy', function(src, cb, x)
        cb(x * 2)
        cb('ignored')
    end)
    Shim.netEvent(7, 'LXRCore:Server:Callback:Request', 'test:legacy', 'req-2', 21)
    local ev = Shim.clientEventsNamed('LXRCore:Client:Callback:Response')
    T.eq(#ev, 1)
    T.eq(ev[1].args[3], 42)
end)

T.test('unknown callback and rate limiting respond with failure', function()
    Shim.clientEvents = {}
    Shim.netEvent(8, 'LXRCore:Server:Callback:Request', 'test:missing', 'req-3')
    local ev = Shim.clientEventsNamed('LXRCore:Client:Callback:Response')
    T.eq(ev[1].args[2], false)
    T.eq(ev[1].args[3], 'unknown_callback')

    Shim.clientEvents = {}
    for i = 1, Config.Security.callbackRateLimit.burst + 5 do
        Shim.netEvent(9, 'LXRCore:Server:Callback:Request', 'test:sum', 'r' .. i, 1, 1)
    end
    local limited = 0
    for _, e in ipairs(Shim.clientEventsNamed('LXRCore:Client:Callback:Response')) do
        if e.args[3] == 'rate_limited' then limited = limited + 1 end
    end
    T.eq(limited, 5)
end)

T.test('erroring callback still responds (nil) and is logged', function()
    Shim.clientEvents = {}
    LXRCore.Callback.Register('test:boom', function() error('boom') end)
    Shim.netEvent(7, 'LXRCore:Server:Callback:Request', 'test:boom', 'req-4')
    local ev = Shim.clientEventsNamed('LXRCore:Client:Callback:Response')
    T.eq(#ev, 1)
    T.eq(ev[1].args[2], true)
    T.eq(ev[1].args[3], nil)
end)

T.test('client callback: Trigger resolves on response, times out otherwise, rejects spoofed source', function()
    Shim.clientEvents = {}
    T.newPlayer(11, 'license:cb11')
    local got
    LXRCore.Callback.Trigger('client:ask', 11, function(v) got = v end, 'payload')
    local req = Shim.clientEventsNamed('LXRCore:Client:Callback:Request')[1]
    T.eq(req.target, 11)
    T.eq(req.args[1], 'client:ask')
    local reqId = req.args[2]
    Shim.netEvent(12, 'LXRCore:Server:Callback:Response', reqId, 'spoof')
    T.eq(got, nil, 'response from another source ignored')
    Shim.netEvent(11, 'LXRCore:Server:Callback:Response', reqId, 'answer')
    T.eq(got, 'answer')

    local timedOut = 'unset'
    LXRCore.Callback.Trigger('client:slow', 11, function(v) timedOut = v end)
    Shim.advance(Config.Security.callbackTimeoutMs + 1)
    T.eq(timedOut, nil, 'timeout resolves nil')
end)

T.test('Await yields until answered', function()
    Shim.clientEvents = {}
    local result
    CreateThread(function()
        result = table.pack(LXRCore.Callback.Await('client:await', 11, 1))
    end)
    local req = Shim.clientEventsNamed('LXRCore:Client:Callback:Request')[1]
    Shim.netEvent(11, 'LXRCore:Server:Callback:Response', req.args[2], 'x', 'y')
    Shim.advance(5)
    T.ok(result, 'await returned')
    T.eq(result[1], 'x')
    T.eq(result[2], 'y')
end)

T.test('legacy v2 protocol still answered by name', function()
    Shim.clientEvents = {}
    Shim.netEvent(7, 'LXRCore:Server:TriggerCallback', 'test:sum', 4, 4)
    local ev = Shim.clientEventsNamed('LXRCore:Client:TriggerCallback')
    T.eq(#ev, 1)
    T.eq(ev[1].args[1], 'test:sum')
    T.eq(ev[1].args[2], 8)
end)
