local lsp = require('lspconfig')
local lsp_setup = require('lsp_server_setup')

lsp.dockerls.setup({
    on_attach = lsp_setup.on_attach,
    capabilities = lsp_setup.capabilities,
    autostart = false,
})

lsp.dockerls.launch()

lsp_setup.null_ls_register(function(builtins)
    return {
        builtins.diagnostics.hadolint,
    }
end)
