fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'https://github.com/fpfoscripts'
description 'Bitcoin Mining [ESX]'
version '1.0.0'


client_scripts {
    'client/*.lua',
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}


shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
}
