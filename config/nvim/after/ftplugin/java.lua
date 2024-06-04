-- TODO: check https://gist.github.com/JoelWi/c6c50e05d33d6adf79b12671ceeb60f3
local utils = require('debling.config_utils')
local lsp_setup = require('debling.lsp_server_setup')
local jdtls = require('jdtls')

---@param jdk_version string
---@return string
local function jdk_path(jdk_version)
  return vim.fs.normalize(vim.fs.joinpath('~/SDKs/Java/', jdk_version))
end

local runtimes = {
  {
    name = 'JavaSE-1.8',
    path = jdk_path('8'),
  },
  {
    name = 'JavaSE-11',
    path = jdk_path('11'),
  },
  {
    name = 'JavaSE-22',
    path = jdk_path('22'),
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

local java_cmds_au = vim.api.nvim_create_augroup('DEblingJavaCmds', { clear = true })

---@param bufnr buffer
local function jdtls_on_attach(_, bufnr)
  lsp_setup.on_attach(_, bufnr)

  local opts = { buffer = bufnr }
  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  utils.nmap('<leader>tc', jdtls.test_class, opts)
  utils.nmap('<leader>tm', jdtls.test_nearest_method, opts)

  pcall(vim.lsp.codelens.refresh)

  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    group = java_cmds_au,
    desc = 'refresh codelens',
    callback = function()
      pcall(vim.lsp.codelens.refresh)
    end,
  })
end

---@param err table | nil
---@param ctx lsp.HandlerContext
---@param result lsp.Result
---@param result lsp.Confuig
local function actionable_notification_handler(err, result, ctx, config)
end

local config = {
  cmd = {
    -- FIXME: hardcoded, use nix to build
    vim.fs.normalize('~/.local/bin/jdtls'),
  },
  on_attach = jdtls_on_attach,
  capabilities = lsp_setup.capabilities,
  -- capabilities =vim.tbl_deep_extend(
  --   'force',
  --   lsp_setup.capabilities,
  --   { actionableNotificationSupported = true }
  -- ),
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      compile = {
        nullAnalysis = {
          mode= "automatic",
        }
      },
      configuration = {
        runtimes = runtimes,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = 'all', -- literals, all, none
        },
      },
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
