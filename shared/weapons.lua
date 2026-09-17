--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Shared Data: Weapons
     ═══════════════════════════════════════════════════════════════════════════
     Keyed by joaat(model). name must equal the item key in shared/items.lua.
     ammotype maps to the ammo item consumed by weapon resources.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRShared = LXRShared or {}

local function weapon(model, label, ammo, kind)
    return { name = model, label = label, ammotype = ammo, type = kind, hash = joaat(model:upper()) }
end

local list = {
    weapon('weapon_revolver_cattleman', 'Cattleman Revolver', 'ammo_revolver', 'revolver'),
    weapon('weapon_revolver_schofield', 'Schofield Revolver', 'ammo_revolver', 'revolver'),
    weapon('weapon_pistol_volcanic', 'Volcanic Pistol', 'ammo_pistol', 'pistol'),
    weapon('weapon_repeater_carbine', 'Carbine Repeater', 'ammo_repeater', 'repeater'),
    weapon('weapon_rifle_springfield', 'Springfield Rifle', 'ammo_rifle', 'rifle'),
    weapon('weapon_shotgun_doublebarrel', 'Double-Barrel Shotgun', 'ammo_shotgun', 'shotgun'),
    weapon('weapon_bow', 'Bow', 'ammo_arrow', 'bow'),
    weapon('weapon_melee_knife', 'Hunting Knife', nil, 'melee'),
    weapon('weapon_melee_hatchet', 'Hatchet', nil, 'melee'),
}

LXRShared.Weapons = {}
LXRShared.WeaponsByName = {}
for _, w in ipairs(list) do
    LXRShared.Weapons[w.hash] = w
    LXRShared.WeaponsByName[w.name] = w
end
