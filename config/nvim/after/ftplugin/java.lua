-- TODO: check https://gist.github.com/JoelWi/c6c50e05d33d6adf79b12671ceeb60f3
local jdtls = require('jdtls')
local utils = require('debling.config_utils')
local Path = require('plenary.path')

local lsp_setup = require('debling.lsp_server_setup')


lsp_setup.null_ls_register(
  function(builtins)
    return {
      builtins.diagnostics.pmd.with({
        extra_args = {
          "--cache", "/tmp/pmd",
          "-R", "rulesets/java/quickstart.xml"
        },
      }),
    }
  end
)

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

---@param bufnr number
local function jdtls_on_attach(_, bufnr)
  local opts = { buffer = bufnr }
  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  utils.nmap('<leader>tc', jdtls.test_class, opts)
  utils.nmap('<leader>tm', jdtls.test_nearest_method, opts)
end


local function get_data_dir()
  local proj_dir = vim.fs.root(0, {".git", "mvnw", "gradlew"}) or vim.fn.getcwd()
  local escaped_dir = proj_dir:gsub(Path.path.sep, '%%')

  local state_dir = vim.fn.stdpath('state')

  if (type(state_dir) ~= "string") then
      vim.notify("Failed to get state dir, expected string, got: " .. type(state_dir), vim.log.levels.ERROR)
  end

  return vim.fs.joinpath(
    state_dir --[[@as string]],
    'jdtls-workspace',
    escaped_dir
  )
end


local config = {
  cmd = {
    'jdtls',
    '-data', get_data_dir()
  },
  on_attach = jdtls_on_attach,
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      compile = {
        nullAnalysis = {
          mode = 'automatic',
        },
      },
      configuration = {
        runtimes = runtimes,
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
