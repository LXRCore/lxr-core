--[[ ═══════════════════════════════════════════════════════════════════════════
     🐺 LXR-CORE — Bridge Resource: qbr-core (shim)
     ═══════════════════════════════════════════════════════════════════════════
     Install as resources/[lxr-bridges]/qbr-core ONLY when the real qbr-core is NOT
     installed. Every QBR export-per-function call is forwarded to lxr-core, whose
     legacy surface is the same API.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'qbr-core (LXRCore bridge)'
author 'iBoss21 / LXRCore'
description 'Forwards qbr-core exports to lxr-core. Do not install next to the real qbr-core.'
version '3.0.0'
lxr_bridge 'qbr-core'

shared_script 'bridge.lua'

dependency 'lxr-core'
