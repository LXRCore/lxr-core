-- LXRCore Resource Manifest Template
-- Replace 'your-resource' with your resource name

fx_version 'cerulean'
game 'rdr3'
lua54 'yes'

name 'your-resource'
author 'Your Name'
description 'Description of your resource'
version '1.0.0'

shared_scripts {
    '@lxr-core/shared/locale.lua',
    'shared/*.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

dependencies {
    'lxr-core',
    'oxmysql',
}
