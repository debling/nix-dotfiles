local lsp = require('lspconfig')
local lsp_setup = require('lsp_server_setup')
local arduino = require('arduino')

arduino.setup({})

lsp.arduino_language_server.setup({
    on_attach = lsp_setup.on_attach,
    capabilities = lsp_setup.capabilities,
    autostart = false,
    on_new_config = arduino.on_new_config,
})

lsp.arduino_language_server.launch()
