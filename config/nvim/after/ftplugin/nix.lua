local lsp = require('lspconfig')
local lsp_setup = require('debling.lsp_server_setup')

lsp.nixd.setup({
  settings = {
    nixd = {
      formatting = {
        command = { 'nixpkgs-fmt' },
      },
    },
  },
})

lsp_setup.null_ls_register(
  function(builtins)
    return {
      builtins.code_actions.statix,
      builtins.diagnostics.statix,
    }
  end
)
