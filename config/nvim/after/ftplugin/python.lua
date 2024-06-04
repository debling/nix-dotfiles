local lsp = require('lspconfig')
local lsp_setup = require('debling.lsp_server_setup')


local language_servers = {'pyright', 'ruff_lsp'}

for _, server in ipairs(language_servers) do
    lsp[server].setup({
        on_attach = lsp_setup.on_attach,
        capabilities = lsp_setup.capabilities,
        autostart = false,
    })

    lsp[server].launch()
end
