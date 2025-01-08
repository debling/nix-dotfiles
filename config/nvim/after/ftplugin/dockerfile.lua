local lsp = require('lspconfig')
local lsp_setup = require('debling.lsp_server_setup')

lsp.dockerls.setup({})

lsp_setup.null_ls_register(
  function(builtins)
    return {
      builtins.diagnostics.hadolint,
    }
  end
)
