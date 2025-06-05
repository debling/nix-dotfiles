local lsp = require('lspconfig')

local utils = require('debling.config_utils')

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- utils.nmap('<space>e', vim.diagnostic.open_float)
-- utils.nmap('[d', vim.diagnostic.goto_prev)
-- utils.nmap(']d', vim.diagnostic.goto_next)
-- utils.nmap('<space>q', vim.diagnostic.setloclist)

local simple_servers = {
  'angularls',
  'bashls',
  'clangd',
  'gopls',
  'lemminx',
  'texlab',
  'terraformls',
  'ts_ls',
  'kotlin_language_server',
  'tailwindcss',

  -- vscode-langservers-extracted
  'html',
  'biome',
  'cssls',
  'astro',
  'emmet_ls',

  'r_language_server',

  'clojure_lsp',
  'rust_analyzer',
  'zls',

  'marksman',
}

vim.g.zig_fmt_autosave = 0

for _, server in pairs(simple_servers) do
  lsp[server].setup({})
end

local schemaStore = require('schemastore')

-- from vscode-langservers-extracted
lsp.jsonls.setup({
  settings = {
    json = {
      schemas = schemaStore.json.schemas(),
      validate = { enable = true },
    },
  },
})

lsp.yamlls.setup({
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = '',
      },
      schemas = schemaStore.yaml.schemas({
        extra = {
          {
            description = 'Open Api Schema',
            fileMatch = { 'openapi*.yml', 'openapi*.yaml' },
            name = 'OpenAPI Spec',
            url = 'https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.yaml',
          },
        },
      }),
    },
  },
})

lsp.ltex.setup({
  -- removed html and xhtml for now, since the support for it isnt great,
  -- currently, its trying the spellcheck the xml tags it self, ending up
  -- reporting a lot of errors
  filetypes = {
    'bib',
    'gitcommit',
    'markdown',
    'org',
    'plaintex',
    'rst',
    'rnoweb',
    'tex',
    'pandoc',
    'quarto',
    'rmd',
    'context',
    'mail',
    'text',
  },
  on_attach = function(client, bufnr)
    -- your other on_attach functions.
    require('ltex_extra').setup({
      load_langs = { 'en-US', 'pt-BR' }, -- table <string> : languages for witch dictionaries will be loaded
      init_check = true, -- boolean : whether to load dictionaries on startup
    })
  end,
  settings = {
    ltex = {
      language = 'auto',
      additionalRules = {
        motherTongue = 'pt-BR',
        enablePickyRules = true,
      },
      completionEnabled = true,
      checkFrequency = 'save',
    },
  },
})

require('lazydev').setup({
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})

lsp.lua_ls.setup({
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
      hint = { enable = true },
    },
  },
})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.hover.dictionary,
    null_ls.builtins.hover.printenv,

    -- Javascript
    -- null_ls.builtins.formatting.prettier,

    -- General text
    null_ls.builtins.completion.spell,

    -- -- Terraform
    null_ls.builtins.diagnostics.trivy,

    null_ls.builtins.diagnostics.clj_kondo,

    null_ls.builtins.formatting.clang_format,

    null_ls.builtins.diagnostics.checkmake,

    null_ls.builtins.formatting.shfmt,

    null_ls.builtins.formatting.stylua,
  },
})
