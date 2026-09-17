--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: rsg-core (shim)
     ═══════════════════════════════════════════════════════════════════════════
     Install this folder as resources/[lxr-bridges]/rsg-core ONLY when the real
     rsg-core is NOT installed. It makes exports['rsg-core']:GetCoreObject()
     return the LXRCore object so unmodified RSG resources start against
     LXRCore. Event names are answered by lxr-core/server/compat/rsg.lua.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'rsg-core (LXRCore bridge)'
author 'iBoss21 / LXRCore'
description 'Forwards rsg-core exports to lxr-core. Do not install next to the real rsg-core.'
version '3.0.0'
lxr_bridge 'rsg'

shared_script 'bridge.lua'

dependency 'lxr-core'
