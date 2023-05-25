--[[
Copyright ©️ 2022 Kasey Fitton, ESX-Framework
All rights reserved. 

use of this source, with or without modification, are permitted provided that the following conditions are met: 

   Even if 'All rights reserved' is very clear :

  You shall not use any piece of this software in a commercial product / service
  You shall not resell this software
  You shall not provide any facility to install this particular software in a commercial product / service
  This copyright should appear in every part of the project code
]] 
fx_version 'cerulean'

game 'gta5'
lua54 'yes'

author 'ESX-Framework'
description 'Official ESX-Legacy Property System'
version '3.0 ALPHA'

shared_scripts {'@es_extended/imports.lua','config.lua'}

ui_page 'web/build/index.html'

files {
    'web/build/index.html',
    'web/build/**/*',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
  'server/classes/*.lua',
	'server/*.lua',
}

client_scripts {
  'client/classes/*.lua',
	'client/*.lua',
}

dependencies {
	'es_extended'
}
