--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Unified Notifications (client)
     ═══════════════════════════════════════════════════════════════════════════
     One entry point, many callers:
       LXRCore.Functions.Notify('text')                       → tip, 4s
       LXRCore.Functions.Notify('text', 'error', 6000)
       LXRCore.Functions.Notify({ title = 'x', description = 'y', type = 'success' })
       LXRCore.Functions.Notify(9, 'text', 4000, nil, dict, icon, color)   (legacy QBR numeric id)
     Server: TriggerClientEvent('LXRCore:Notify', src, message, type, duration)
     Backend: Config.Notify.backend = 'native' (RedM feed via notify.js),
              'ox_lib' (lib.notify when started) or 'event' (re-broadcast as
              'lxr-notify:client:show' for a custom HUD).
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local RES = LXRCore.ResourceName
local ICONS = {
    success = { dict = 'generic_textures', icon = 'tick', color = 'COLOR_GREEN' },
    error   = { dict = 'generic_textures', icon = 'cross', color = 'COLOR_RED' },
    warning = { dict = 'generic_textures', icon = 'hud_menu_4a', color = 'COLOR_YELLOW' },
    inform  = { dict = 'generic_textures', icon = 'hud_menu_4a', color = 'COLOR_WHITE' },
}

-- Legacy QBR numeric ids
local LEGACY = {
    [1] = 'ShowTooltip', [2] = 'DisplayRightText', [3] = 'ShowObjective', [4] = 'ShowBasicTopNotification',
    [5] = 'ShowSimpleCenterText', [6] = 'ShowLocationNotification', [7] = 'ShowTopNotification',
    [8] = 'ShowAdvancedLeftNotification', [9] = 'ShowAdvancedRightNotification',
}

local function loadTexture(dict)
    if not dict or dict == '' then return false end
    if not Citizen.InvokeNative(0x7332461FC59EB7EC, dict) then return false end -- DoesStreamedTextureDictExist
    RequestStreamedTextureDict(dict, true)
    local tries = 0
    while not HasStreamedTextureDictLoaded(dict) and tries < 50 do Wait(10) tries = tries + 1 end
    return HasStreamedTextureDictLoaded(dict)
end

local function native(opts)
    local kind = ICONS[opts.type] or ICONS.inform
    local title, desc = opts.title, opts.description
    if title and desc then
        loadTexture(kind.dict)
        exports[RES]:ShowAdvancedLeftNotification(title, desc, kind.dict, kind.icon, opts.duration, kind.color)
    else
        exports[RES]:ShowTooltip(title or desc or '', opts.duration)
    end
end

local function oxlib(opts)
    TriggerEvent('ox_lib:notify', { title = opts.title, description = opts.description, type = opts.type, duration = opts.duration })
end

---Normalise every accepted signature into { title, description, type, duration }.
local function normalise(a, b, c, d, e, f, g)
    local opts
    if type(a) == 'table' then
        opts = { title = a.title or a.text or a.message, description = a.description or a.subtext, type = a.type, duration = a.duration or a.length }
    elseif type(a) == 'number' and LEGACY[a] then
        -- (id, text, duration, subtext, dict, icon, color)
        return { legacy = LEGACY[a], text = b, duration = c, subtext = d, dict = e, icon = f, color = g }
    else
        opts = { title = a, type = b, duration = c }
    end
    opts.type = type(opts.type) == 'string' and opts.type:lower() or 'inform'
    if opts.type == 'info' then opts.type = 'inform' end
    opts.duration = tonumber(opts.duration) or (Config.Notify and Config.Notify.duration) or 4000
    if opts.title then opts.title = tostring(opts.title) end
    if opts.description then opts.description = tostring(opts.description) end
    return opts
end

function LXRCore.Functions.Notify(...)
    local opts = normalise(...)
    if opts.legacy then
        local fn = opts.legacy
        if fn == 'ShowAdvancedLeftNotification' then
            loadTexture(opts.dict or 'generic_textures')
            exports[RES][fn](nil, opts.text, opts.subtext or '', opts.dict or 'generic_textures', opts.icon or 'tick', opts.duration, opts.color)
        elseif fn == 'ShowAdvancedRightNotification' then
            loadTexture(opts.dict or 'generic_textures')
            exports[RES][fn](nil, opts.text, opts.dict or 'generic_textures', opts.icon or 'tick', opts.color or 'COLOR_WHITE', opts.duration)
        elseif fn == 'ShowTopNotification' or fn == 'ShowLocationNotification' then
            exports[RES][fn](nil, opts.text, opts.subtext or '', opts.duration)
        else
            exports[RES][fn](nil, opts.text, opts.duration)
        end
        return
    end
    local backend = (Config.Notify and Config.Notify.backend) or 'native'
    if backend == 'ox_lib' and GetResourceState('ox_lib') == 'started' then
        return oxlib(opts)
    elseif backend == 'event' then
        return TriggerEvent('lxr-notify:client:show', opts)
    end
    native(opts)
end

RegisterNetEvent('lxr:client:notify', function(...) LXRCore.Functions.Notify(...) end)
RegisterNetEvent('LXRCore:Notify', function(...) LXRCore.Functions.Notify(...) end) -- legacy name

-- RSG resources call lib.notify; when ox_lib is absent, route its event to us.
if GetResourceState('ox_lib') ~= 'started' then
    RegisterNetEvent('ox_lib:notify', function(data)
        if type(data) == 'table' then native(normalise(data)) end
    end)
end

exports('Notify', LXRCore.Functions.Notify)
