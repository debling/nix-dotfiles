-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
local km = vim.keymap
km.set('n', '<space>e', vim.diagnostic.open_float, opts)
km.set('n', '[d', vim.diagnostic.goto_prev, opts)
km.set('n', ']d', vim.diagnostic.goto_next, opts)
km.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    km.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    km.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    km.set('n', 'K', vim.lsp.buf.hover, bufopts)
    km.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    km.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    km.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    km.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    km.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    km.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    km.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
    km.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    km.set('n', 'gr', vim.lsp.buf.references, bufopts)
    km.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local lsp = require('lspconfig')

vim.lsp.set_log_level('debug')

-- Angular templates
lsp.angularls.setup {
  on_attach = on_attach,
}

-- Bash/sh
lsp.bashls.setup {
  on_attach = on_attach,
}

-- C/C++
lsp.ccls.setup {
  on_attach = on_attach,
}

-- GO
lsp.gopls.setup {
  on_attach = on_attach,
}

-- Java
local util = require 'lspconfig.util'
local handlers = require 'vim.lsp.handlers'

local env = {
  HOME = vim.loop.os_homedir(),
  XDG_CACHE_HOME = os.getenv 'XDG_CACHE_HOME',
  JDTLS_JVM_ARGS = os.getenv 'JDTLS_JVM_ARGS',
}

local function get_cache_dir()
  return env.XDG_CACHE_HOME and env.XDG_CACHE_HOME or util.path.join(env.HOME, '.cache')
end

local function get_jdtls_cache_dir()
  return util.path.join(get_cache_dir(), 'jdtls')
end

local function get_jdtls_config_dir()
  return util.path.join(get_jdtls_cache_dir(), 'config')
end

local function get_jdtls_workspace_dir()
  return util.path.join(get_jdtls_cache_dir(), 'workspace')
end

local function get_jdtls_jvm_args()
  local args = {}
  for a in string.gmatch((env.JDTLS_JVM_ARGS or ''), '%S+') do
    local arg = string.format('--jvm-arg=%s', a)
    table.insert(args, arg)
  end
  return unpack(args)
end


lsp.jdtls.setup {
  on_attach = on_attach,
  cmd = {
    'jdt-language-server',
    '-configuration',
    get_jdtls_config_dir(),
    '-data',
    get_jdtls_workspace_dir(),
    get_jdtls_jvm_args(),
    -- Lombok setup
    '-Xbootclasspath/a:/Users/debling/.m2/repository/org/projectlombok/lombok/1.18.24/lombok-1.18.24.jar',
    '-javaagent:/Users/debling/.m2/repository/org/projectlombok/lombok/1.18.24/lombok-1.18.24.jar',
  },
} 

-- Python
lsp.pyright.setup {
  on_attach = on_attach,
}

-- Terraform
lsp.terraformls.setup {
  on_attach = on_attach,
}

-- Typescript
lsp.tsserver.setup {
  on_attach = on_attach,
}
