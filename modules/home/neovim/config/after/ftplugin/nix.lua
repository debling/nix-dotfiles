local utils = require('debling.config_utils')

vim.lsp.config('nixd', {
  settings = {
    nixd = {
      formatting = {
        command = { 'nixpkgs-fmt' },
      },
    },
  },
})
vim.lsp.enable('nixd')

utils.null_ls_register(
  function(builtins)
    return {
      builtins.code_actions.statix,
      builtins.diagnostics.statix,
    }
  end
)
