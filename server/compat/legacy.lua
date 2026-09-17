--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Compatibility Adapter: Legacy LXR (v1/v2) & QBR (server)
     ═══════════════════════════════════════════════════════════════════════════
     The QBR-era API is an export-per-function surface
       exports['lxr-core']:GetPlayer(src) / :CreateCallback / :AddCommand / …
     which server/*.lua already register natively. This file adds the last
     pieces old resources touch directly:
       • QBRCore:* event names mirrored when a resource fires them
       • exports required by lxr-inventory (legacy) and lxr-multicharacter
       • legacy XP API as server-side exports (old client events were exploitable)
     Disable with Config.Compat.legacy.enabled = false on a clean v3 ecosystem.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

if not Config.Compat.legacy.enabled then return end

-- QBR-named events some ported resources still fire
RegisterNetEvent('QBRCore:Server:TriggerCallback', function(name, ...)
    local src = source
    if type(name) ~= 'string' then return end
    LXRCore.Callback.Invoke(name, src, function(...)
        TriggerClientEvent('QBRCore:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

RegisterNetEvent('QBRCore:UpdatePlayer', function() TriggerEvent('LXRCore:UpdatePlayer') end)
RegisterNetEvent('QBRCore:ToggleDuty', function() TriggerEvent('LXRCore:ToggleDuty') end)

-- Legacy lxr-inventory reads/writes PlayerData.items and expects these helpers
exports('GetItemBySlot', function(source, slot)
    local p = LXRCore.Functions.GetPlayer(source)
    return p and p.Functions.GetItemBySlot(slot) or nil
end)
exports('GetItemByName', function(source, name)
    local p = LXRCore.Functions.GetPlayer(source)
    return p and p.Functions.GetItemByName(name) or nil
end)
exports('GetItemsByName', function(source, name)
    local p = LXRCore.Functions.GetPlayer(source)
    return p and p.Functions.GetItemsByName(name) or {}
end)
exports('SetInventory', function(source, items)
    return LXRCore.Inventory.SetInventory(source, items)
end)
exports('ClearInventory', function(source, filter)
    return LXRCore.Inventory.ClearInventory(source, filter)
end)

-- Legacy XP API (server-side only)
exports('AddXp', function(source, skill, amount)
    local p = LXRCore.Functions.GetPlayer(source)
    return p and p.Functions.AddXp(skill, amount) or false
end)
exports('RemoveXp', function(source, skill, amount)
    local p = LXRCore.Functions.GetPlayer(source)
    return p and p.Functions.RemoveXp(skill, amount) or false
end)

LXRCore.Log.info('compat', 'legacy LXR / QBR adapter active (export-per-function surface)')
