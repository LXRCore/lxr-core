-- locale engine
local Shim = ...
T.suite('locale')

T.test('translates with placeholders and both call styles', function()
    T.eq(Lang:t('info.received_paycheck', { value = 12 }), 'You received your paycheck of $12')
    T.eq(Lang.t('info.received_paycheck', { value = 3 }), 'You received your paycheck of $3')
end)

T.test('missing key returns the key, unknown placeholder stays visible', function()
    T.eq(Lang:t('nope.missing'), 'nope.missing')
    T.eq(Lang:t('info.server_id', {}), 'Your server id: %{id}')
end)

T.test('ka bundle mirrors en keys 1:1', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing, extra = {}, {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    for k in pairs(ka) do if en[k] == nil then extra[#extra + 1] = k end end
    T.eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
    T.eq(#extra, 0, 'ka extra: ' .. table.concat(extra, ', '))
end)

T.test('language switch falls back to english', function()
    Config.Lang = 'ka'
    T.eq(Lang:t('info.on_duty'), 'თქვენ მორიგეობაზე ხართ')
    Config.Lang = 'xx'
    T.eq(Lang:t('info.on_duty'), 'You are now on duty')
    Config.Lang = 'en'
end)
