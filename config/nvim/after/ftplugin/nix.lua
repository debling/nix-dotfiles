local lsp = require('lspconfig')
local lsp_setup = require('debling.lsp_server_setup')

lsp.nil_ls.setup({
    on_attach = lsp_setup.on_attach,
    capabilities = lsp_setup.capabilities,
    autostart = false,
    settings = {
        ['nil'] = {
            formatting = {
                command = { 'nixpkgs-fmt' },
            },
        },
    },
})

lsp.nil_ls.launch()

lsp_setup.null_ls_register(function(builtins)
    return {
        builtins.code_actions.statix,
        builtins.diagnostics.statix,
    }
end)
