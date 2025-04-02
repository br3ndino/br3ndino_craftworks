-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Br3ndino'
description 'Craftworks 16 in 1 crafting sidejobs'
version '1.0.0'

-- Server script
server_script 'server.lua'

-- Client script
client_script 'client.lua'

-- Dependencies
dependencies {
    'qb-core',
    'qb-target',
    'ox_lib',
    'progressbar' -- Optional for loading bar
}
