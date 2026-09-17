--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: vorp_inventory (shim)
     ═══════════════════════════════════════════════════════════════════════════
     Install as resources/[lxr-bridges]/vorp_inventory ONLY when the real
     vorp_inventory is NOT installed. Item exports are forwarded to the LXRCore
     inventory abstraction; weapon / custom-inventory exports log NOT SUPPORTED.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'vorp_inventory (LXRCore bridge)'
author 'iBoss21 / LXRCore'
description 'Forwards vorp_inventory exports to lxr-core. Do not install next to the real vorp_inventory.'
version '3.0.0'
lxr_bridge 'vorp_inventory'

shared_script 'bridge.lua'

dependency 'lxr-core'
