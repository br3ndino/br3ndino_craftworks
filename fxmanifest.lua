-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Br3ndino'
description 'Craftworks 16 in 1 crafting sidejobs'
version '0.0.01a'

-- Shared script (Config must be loaded first)
shared_script 'config.lua'

-- Server scripts
server_scripts {
    'server/s_textile.lua',
    'server/s_cheesemaker.lua',
}

-- Client scripts
client_scripts {
    'client/c_textile.lua',
    'client/c_cheesemaker.lua',
}

-- Dependencies
dependencies {
    'qb-core',
    'qb-target',
    'ox_lib',
    'progressbar' -- Optional for loading bar
}
