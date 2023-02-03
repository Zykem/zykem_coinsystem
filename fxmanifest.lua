fx_version 'cerulean'
author 'zykem'
description 'Coin system with ranks such as VIP included'
game 'gta5'
version '1.0.1'


client_scripts {

    'cl_config.lua',
    'client.lua'

}

server_scripts {

    '@oxmysql/lib/MySQL.lua',
    'cl_config.lua',
    'sv_config.lua',
    'server.lua'

}
server_exports = {

    "getUserCoins",
    "setUserCoins",
    "removeUserCoins",
    "addUserCoins",
    "getRank",
    "updateRank"

}