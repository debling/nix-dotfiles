local lsp = require('lspconfig')
local lsp_setup = require('lsp_server_setup')


local language_servers = {'pyright', 'ruff_lsp'}

for _, server in ipairs(language_servers) do
    lsp[server].setup({
        on_attach = lsp_setup.on_attach,
        capabilities = lsp_setup.capabilities,
        autostart = false,
    })

    lsp[server].launch()
end



lsp_setup.null_ls_register(function(builtins)
    return {
        -- code formatting
        builtins.formatting.black,
        -- import sortint
        builtins.formatting.isort,
    }
end)
