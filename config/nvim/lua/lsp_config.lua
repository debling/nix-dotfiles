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

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Angular templates
lsp.angularls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Bash/sh
lsp.bashls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- C/C++
lsp.ccls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- GO
lsp.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
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
  capabilities = capabilities,
  cmd = {
    'jdt-language-server',
    '-configuration',
    get_jdtls_config_dir(),
    '-data',
    get_jdtls_workspace_dir(),
    get_jdtls_jvm_args(),
    -- Lombok setup
    '-Xbootclasspath/a:/Users/debling/Downloads/lombok.jar',
    '-javaagent:/Users/debling/Downloads/lombok.jar',
  },
} 

-- Python
lsp.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Terraform
lsp.terraformls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Typescript
lsp.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- luasnip setup
local luasnip = require 'luasnip'

local lspkind = require 'lspkind'

-- nvim-cmp setup
local cmp = require 'cmp'

cmp.setup {

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
  }),

  sources = {
    { name = "nvim_lua" },
    { name = "orgmode" },
    { name = 'nvim_lsp' },
    { name = "path" },
    { name = 'luasnip' },
    { name = "buffer", keyword_length = 5 },
  },

 formatting = {
    -- Youtube: How to set up nice formatting for your sources.
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
      },
    },
  },

    view = {
        entries = 'native',
    },

  experimental = {
    ghost_text = true,
  },
}
