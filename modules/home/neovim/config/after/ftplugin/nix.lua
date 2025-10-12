local lsp = require('lspconfig')
local utils = require('debling.config_utils')

lsp.nixd.setup({
  settings = {
    nixd = {
      formatting = {
        command = { 'nixpkgs-fmt' },
      },
    },
  },
})

utils.null_ls_register(
  function(builtins)
    return {
      builtins.code_actions.statix,
      builtins.diagnostics.statix,
    }
  end
)
