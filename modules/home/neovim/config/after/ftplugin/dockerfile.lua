local lsp = require('lspconfig')
local utils = require('debling.config_utils')

lsp.dockerls.setup({})

utils.null_ls_register(
  function(builtins)
    return {
      builtins.diagnostics.hadolint,
    }
  end
)
