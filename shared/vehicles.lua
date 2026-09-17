--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Vehicles (wagons, carts, boats)
     ═══════════════════════════════════════════════════════════════════════════
     model = { name, brand, model, price, category, hash, type }
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

local function vehicle(model, label, price, category, kind)
    return { name = label, brand = 'Wagon', model = model, price = price, category = category, type = kind or 'wagon', hash = joaat(model) }
end

LXRShared.Vehicles = {
    cart01        = vehicle('cart01', 'Small Cart', 40, 'cart'),
    cart03        = vehicle('cart03', 'Cart', 60, 'cart'),
    wagon02x      = vehicle('wagon02x', 'Farm Wagon', 150, 'wagon'),
    wagon03x      = vehicle('wagon03x', 'Supply Wagon', 175, 'wagon'),
    wagon04x      = vehicle('wagon04x', 'Hay Wagon', 175, 'wagon'),
    wagontraveller01x = vehicle('wagontraveller01x', 'Traveller Wagon', 300, 'wagon'),
    coach3        = vehicle('coach3', 'Stagecoach', 400, 'coach'),
    stagecoach001x = vehicle('stagecoach001x', 'Fine Stagecoach', 500, 'coach'),
    buggy01       = vehicle('buggy01', 'Buggy', 120, 'buggy'),
    canoe         = vehicle('canoe', 'Canoe', 40, 'boat', 'boat'),
    rowboat       = vehicle('rowboat', 'Rowboat', 60, 'boat', 'boat'),
}
