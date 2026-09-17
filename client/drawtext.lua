--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Text Drawing Helpers (client)
     ═══════════════════════════════════════════════════════════════════════════
     DrawText2D / DrawText3D are per-frame primitives; callers own the loop.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local F = LXRCore.Functions

---Draw screen-space text this frame. x,y in 0..1.
function F.DrawText(x, y, width, height, scale, r, g, b, a, str)
    SetTextScale(scale, scale)
    SetTextColor(r, g, b, a)
    SetTextCentre(true)
    SetTextFontForCurrentCommand(1)
    DisplayText(CreateVarString(10, 'LITERAL_STRING', tostring(str)), x - width / 2, y - height / 2 + 0.005)
end

---Draw world-anchored text this frame.
function F.DrawText3D(x, y, z, str)
    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
    if not onScreen then return end
    local cam = GetGameplayCamCoord()
    local dist = #(cam - vector3(x, y, z))
    local scale = (1 / dist) * 2 * (1 / GetGameplayCamFov()) * 100
    SetTextScale(0.0, 0.35 * scale)
    SetTextColor(255, 255, 255, 215)
    SetTextCentre(true)
    SetTextFontForCurrentCommand(1)
    DisplayText(CreateVarString(10, 'LITERAL_STRING', tostring(str)), sx, sy)
end

exports('DrawText', F.DrawText)
exports('DrawText3D', F.DrawText3D)
