fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'LXRCore RedM Edition - Fully converted and maintained by iBoss (https://github.com/iboss21)'
version '1.0.3'

shared_scripts {
    'shared/locale.lua', -- Ensure that shared scripts are loaded first
    'config.lua',
    'shared/main.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/horse.lua',
    'shared/vehicles.lua',
    'shared/gangs.lua',
    'shared/weapons.lua'
}

client_scripts {
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/notify.js',
    'client/drawtxt.lua',
    'client/prompts.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/locales/en.lua', -- Add your language file here
    'server/debug.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/exports.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css'
}

dependencies {
    'oxmysql',
}

lua54 'yes'
