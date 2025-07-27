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
  vim.lsp.enable(server)
end

local schemaStore = require('schemastore')

-- from vscode-langservers-extracted
vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = schemaStore.json.schemas(),
      validate = { enable = true },
    },
  },
})
vim.lsp.enable('jsonls')

vim.lsp.config('yamlls', {
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
vim.lsp.enable('yamlls')

vim.lsp.config('ltex', {
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
vim.lsp.enable('ltex')

require('lazydev').setup({
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      telemetry = {
        enable = false,
      },
      hint = { enable = true },
    },
  },
})
vim.lsp.enable('lua_ls')

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
    null_ls.builtins.diagnostics.trivy,

    null_ls.builtins.formatting.clang_format,

    null_ls.builtins.diagnostics.checkmake,

    null_ls.builtins.formatting.shfmt,

    null_ls.builtins.formatting.stylua,
  },
})

-- -- Completion and snippets setup
vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    if client:supports_method('textDocument/completion') then
      local chars = {}
      for i = 32, 126 do
        table.insert(chars, string.char(i))
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, {
        autotrigger = true,
      })
    end
  end,
})

---@enum JumpDirection
local JUMP_DIRECTION = {
  prev = -1,
  next = 1,
}

---@param keys string
---@param direction JumpDirection
local function snippet_jump_or_send_keys(keys, direction)
  ---@cast direction vim.snippet.Direction
  if vim.snippet.active({ direction = direction }) then
    vim.snippet.jump(direction)
  else
    vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), 'n')
  end
end

-- move to previous item on the snippert
utils.map(
  { 'i', 's' },
  '<c-h>',
  function() snippet_jump_or_send_keys('<c-h>', JUMP_DIRECTION.prev) end
)

-- move to foward item on the snippert
utils.map(
  { 'i', 's' },
  '<c-l>',
  function() snippet_jump_or_send_keys('<c-l>', JUMP_DIRECTION.next) end,
  { silent = true, noremap = false }
)
