fx_version 'adamant'
game 'gta5'

client_script {
    '@vrp/lib/utils.lua',
    'client/*.lua'
}
server_script {
    '@vrp/lib/utils.lua',
    'server/*.lua'
}

files {
    'server/utils/*.lua',
}