fx_version 'adamant'
games { 'rdr3', 'gta5' }

description 'ESX Inventory HUD'

version 'Blacko-version'

ui_page 'html/ui.html'

client_scripts {
  "@es_extended/locale.lua",
  "client/*.lua",
  "locales/fr.lua",
  "config.lua"
}

server_scripts {
  '@es_extended/locale.lua',
  '@mysql-async/lib/MySQL.lua',

  'server/main.lua',
  'locales/fr.lua',
  'config.lua'	
}

files {
    'html/ui.html',
    'html/css/ui.css',
    'html/css/jquery-ui.css',
    'html/js/inventory.js',
    'html/js/config.js',
    -- JS LOCALES
    'html/locales/cs.js',
    'html/locales/en.js',
    'html/locales/fr.js',
    -- IMAGES
    'html/img/*.png',
    -- ICONS
    'html/img/items/*.png',
}
