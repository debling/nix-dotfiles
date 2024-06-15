local lsp = require('lspconfig')

local lsp_setup = require('debling.lsp_server_setup')
local utils = require('debling.config_utils')

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
utils.nmap('<space>e', vim.diagnostic.open_float)
utils.nmap('[d', vim.diagnostic.goto_prev)
utils.nmap(']d', vim.diagnostic.goto_next)
utils.nmap('<space>q', vim.diagnostic.setloclist)

vim.lsp.set_log_level('WARN')

local simple_servers = {
  'angularls',
  'bashls',
  'clangd',
  'gopls',
  'lemminx',
  'texlab',
  'terraformls',
  'tsserver',
  'kotlin_language_server',
  'tailwindcss',

  -- vscode-langservers-extracted
  'html',
  'eslint',
  'cssls',
  'astro',
  'emmet_ls',

  'r_language_server',

  'clojure_lsp',
}

for _, server in pairs(simple_servers) do
  lsp[server].setup({
    on_attach = lsp_setup.on_attach,
    capabilities = lsp_setup.capabilities,
  })
end

local schemaStore = require('schemastore')

-- from vscode-langservers-extracted
lsp.jsonls.setup({
  on_attach = lsp_setup.on_attach,
  capabilities = lsp_setup.capabilities,
  settings = {
    json = {
      schemas = schemaStore.json.schemas(),
      validate = { enable = true },
    },
  },
})

lsp.yamlls.setup({
  on_attach = lsp_setup.on_attach,
  capabilities = lsp_setup.capabilities,
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
  capabilities = lsp_setup.capabilities,
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
    lsp_setup.on_attach(client, bufnr)
    -- your other on_attach functions.
    require('ltex_extra').setup({
      load_langs = { 'en-US', 'pt-BR' }, -- table <string> : languages for witch dictionaries will be loaded
      init_check = true, -- boolean : whether to load dictionaries on startup
    })
  end,
  settings = {
    ltex = {
      additionalRules = {
        motherTongue = 'pt-BR',
        enablePickyRules = true,
      },
      completionEnabled = true,
      checkFrequency = 'save',
    },
  },
})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.hover.dictionary,
    null_ls.builtins.hover.printenv,

    -- Javascript
    null_ls.builtins.formatting.prettier,

    -- General text
    null_ls.builtins.completion.spell,

    -- -- Terraform
    null_ls.builtins.diagnostics.tfsec,



    null_ls.builtins.diagnostics.clj_kondo,

    null_ls.builtins.formatting.clang_format,

  null_ls.builtins.diagnostics.checkmake
  },
})
