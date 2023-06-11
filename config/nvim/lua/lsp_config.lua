-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
local km = vim.keymap
km.set('n', '<space>e', vim.diagnostic.open_float, opts)
km.set('n', '[d', vim.diagnostic.goto_prev, opts)
km.set('n', ']d', vim.diagnostic.goto_next, opts)
km.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  local bindings = {
    { 'gD', vim.lsp.buf.declaration },
    { 'gd', vim.lsp.buf.definition },
    { 'K', vim.lsp.buf.hover },
    { 'gi', vim.lsp.buf.implementation },
    { '<C-k>', vim.lsp.buf.signature_help },
    { '<space>wa', vim.lsp.buf.add_workspace_folder },
    { '<space>wr', vim.lsp.buf.remove_workspace_folder },
    {
      '<space>wl',
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
    },
    { '<space>D', vim.lsp.buf.type_definition },
    { '<space>rn', vim.lsp.buf.rename },
    { '<space>ca', vim.lsp.buf.code_action },
    { 'gr', vim.lsp.buf.references },
    {
      '<space>f',
      function()
        vim.lsp.buf.format { async = true }
      end,
    },
  }

  for _, binding in ipairs(bindings) do
    km.set('n', binding[1], binding[2], bufopts)
  end
end

local lsp = require 'lspconfig'

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local simple_servers = {
  'angularls',
  'bashls',
  'ccls',
  'gopls',
  'lemminx',
  'texlab',
  'nil_ls',
  'dockerls',
  'pyright',
  'terraformls',
  'tsserver',
  'kotlin_language_server',
  'tailwindcss',

  -- vscode-langservers-extracted
  'html',
  'eslint',
  'cssls',
}

for _, server in pairs(simple_servers) do
  lsp[server].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

local schemaStore = require('schemastore')

-- from vscode-langservers-extracted
lsp.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      schemas = schemaStore.json.schemas(),
      validate = { enable = true },
    },
  },
}

lsp.yamlls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
      },
      schemas = schemaStore.yaml.schemas(),
    },
  },
}

lsp.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file('', true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}

-- Java
local util = require 'lspconfig.util'

-- intalled via https://github.com/eruizc-dev/jdtls-launcher
lsp.jdtls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    util.path.join(vim.loop.os_homedir(), '.local/bin/jdtls'),
  },
  settings = {
    java = {
      format = {
        settings = {
          url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
          profile = 'GoogleStyle',
        },
      },
      signatureHelp = { enabled = true },
      configuration = {
        updateBuildConfiguration = 'interactive',
      },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
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
      completion = {
        favoriteStaticMembers = {
          'org.hamcrest.MatcherAssert.assertThat',
          'org.hamcrest.Matchers.*',
          'org.hamcrest.CoreMatchers.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
          'org.mockito.Mockito.*',
        },
      },
    },
  },
}

lsp.ltex.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    -- your other on_attach functions.
    require('ltex_extra').setup {
      load_langs = { 'en-US', 'pt-BR' }, -- table <string> : languages for witch dictionaries will be loaded
      init_check = true, -- boolean : whether to load dictionaries on startup
    }
  end,
  settings = {
    ltex = {
      additionalRules = {
        enablePickyRules = true,
      },
    },
  },
}

-- lsp.hls.setup {
--   filetypes = { 'haskell', 'lhaskell', 'cabal' },
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }

-- luasnip setup
local luasnip = require 'luasnip'

-- Expand snippert with or run the normal c-k action
km.set({ 'i', 's' }, '<c-k>', function()
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  else
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-k>', true, true, true), 'n')
  end
end, { silent = true, noremap = false })

-- move to previous item on the snippert
km.set({ 'i', 's' }, '<c-h>', function()
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-h>', true, true, true), 'n')
  end
end, { silent = true, noremap = false })

-- move to foward item on the snippert
km.set({ 'i', 's' }, '<c-l>', function()
  if luasnip.jumpable(1) then
    luasnip.jump(1)
  else
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-l>', true, true, true), 'n')
  end
end, { silent = true, noremap = false })

local lspkind = require 'lspkind'

require('luasnip.loaders.from_vscode').lazy_load()

-- nvim-cmp setup
local cmp = require 'cmp'

cmp.setup {

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-y>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
  },

  sources = cmp.config.sources({
    { name = 'nvim_lua' },
    { name = 'copilot' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer', keyword_length = 5 },
  }),

  formatting = {
    format = lspkind.cmp_format {
      mode = 'symbol',
      maxwidth = 50,
    },
  },

  view = {
    entries = 'native',
  },

  experimental = {
    ghost_text = true,
  },
}

local null_ls = require 'null-ls'

null_ls.setup {
  sources = {
    null_ls.builtins.formatting.trim_newlines,
    null_ls.builtins.hover.dictionary,
    null_ls.builtins.hover.printenv,
    null_ls.builtins.formatting.stylua,

    -- null_ls.builtins.code_actions.eslint_d,
    -- null_ls.builtins.diagnostics.eslint_d,

    null_ls.builtins.formatting.prettier_d_slim,

    null_ls.builtins.code_actions.shellcheck,

    null_ls.builtins.completion.spell,

    -- -- Python
    -- liting
    null_ls.builtins.diagnostics.ruff,
    -- code formatting
    null_ls.builtins.formatting.black,
    -- import sortint
    null_ls.builtins.formatting.isort,

    -- -- nix
    null_ls.builtins.code_actions.statix,
    null_ls.builtins.diagnostics.statix,
  },
}

-- Show lsp sever status/progress in the botton right corner
require('fidget').setup {}

require('indent_blankline').setup {}
