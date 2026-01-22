local utils = require('debling.config_utils')

vim.lsp.config('dockerls', {})
vim.lsp.enable('dockerls')

utils.null_ls_register(
  function(builtins)
    return {
      builtins.diagnostics.hadolint,
    }
  end
)
