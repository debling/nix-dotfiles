local lsp = require('lspconfig')
local lsp_setup = require('debling.lsp_server_setup')

require('lazydev').setup({
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})

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
