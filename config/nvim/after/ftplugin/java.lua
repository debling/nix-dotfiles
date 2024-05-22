local utils = require('config_utils')
local lsp_setup = require('lsp_server_setup')
local jdtls = require('jdtls')

---@param jdk_version string
---@return string
local function jdk_path(jdk_version)
  return vim.fs.normalize('~/SDKs/Java/' .. jdk_version)
end

local runtimes = {
  {
    name = 'JavaSE-1.8',
    path = jdk_path('8') .. "/zulu-8.jdk/Contents/Home",
  },
  {
    name = 'JavaSE-11',
    path = jdk_path('11') .. "/zulu-11.jdk/Contents/Home",
  },
  {
    name = 'JavaSE-21',
    path = jdk_path('current') .. "/zulu-21.jdk/Contents/Home",
  },
  {
    name = 'JavaSE-22',
    path = jdk_path('22') .. "/zulu-22.jdk/Contents/Home",
  },
}

local jdtls_extensions_path = vim.fn.stdpath('data') .. '/jdtls'

local bundles = {
  -- vs-code java-debug extension
  vim.fn.glob(
    jdtls_extensions_path .. '/java-debug/com.microsoft.java.debug.plugin-*.jar',
    true
  ),
}

vim.list_extend(
  bundles,

  -- vs-code java-test extension
  vim.split(vim.fn.glob(jdtls_extensions_path .. '/java-test/*.jar', true), '\n')
)

local config = {
  cmd = {
    -- FIXME: hardcoded, use nix to build
    vim.fs.normalize('~/.local/bin/jdtls'),
  },
  on_attach = function(_, bufnr)
    lsp_setup.on_attach(_, bufnr)

    local opts = { buffer = bufnr }
    -- If using nvim-dap
    -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
    utils.nmap('<leader>tc', jdtls.test_class, opts)
    utils.nmap('<leader>tm', jdtls.test_nearest_method, opts)
  end,
  capabilities = lsp_setup.capabilities,
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      configuration = {
        runtimes = runtimes,
      },
      -- implementationsCodeLens = {
      --   enabled = true,
      -- },
      -- inlayHints = {
      --   parameterNames = {
      --     enabled = true,
      --   },
      -- },
      signatureHelp = {
        enabled = true,
        description = {
          enabled = true,
        },
      },
      format = {
        settings = {
          url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
          profile = 'GoogleStyle',
        },
      },
    },
  },
}

-- FIXME: hardcoded, use nix to build
jdtls.jol_path = vim.fs.normalize('~/Downloads/jol-cli-latest.jar')
jdtls.start_or_attach(config)
