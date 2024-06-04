local lsp = require('lspconfig')
local lsp_setup = require('debling.lsp_server_setup')

lsp.lua_ls.setup({
    on_attach = lsp_setup.on_attach,
    capabilities = lsp_setup.capabilities,
    autostart = false,
    settings = {
        Lua = {
            telemetry = {
                enable = false,
            },
            hint = { enable = true },
        },
    },
})

lsp_setup.null_ls_register(function(builtins)
    return { builtins.formatting.stylua }
end)

lsp.lua_ls.launch()
