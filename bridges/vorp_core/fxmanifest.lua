--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: vorp_core (shim)
     ═══════════════════════════════════════════════════════════════════════════
     Install as resources/[lxr-bridges]/vorp_core ONLY when the real vorp_core is NOT
     installed. exports.vorp_core:GetCore() then returns the LXRCore VORP facade
     (lxr-core/server/compat/vorp.lua + client/compat/vorp.lua).
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'vorp_core (LXRCore bridge)'
author 'iBoss21 / LXRCore'
description 'Forwards vorp_core exports to lxr-core. Do not install next to the real vorp_core.'
version '3.0.0'
lxr_bridge 'vorp_core'

shared_script 'bridge.lua'

dependency 'lxr-core'
