local lsp = require('debling.lspconfig')
local arduino = require('arduino')

arduino.setup({})

lsp.arduino_language_server.setup({
    on_new_config = arduino.on_new_config,
})
