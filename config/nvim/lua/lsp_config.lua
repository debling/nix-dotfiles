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

vim.lsp.set_log_level 'debug'

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
}

for _, server in pairs(simple_servers) do
    lsp[server].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

lsp.yamlls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
                ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = 'docker-compose*.yml',
            },
        },
    },
}

lsp.sumneko_lua.setup {
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
    init_options = {
        extendedClientCapabilities = {
            progressReportProvider = false,
        },
    },
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {
        util.path.join(vim.loop.os_homedir(), '.local/bin/jdtls')
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
            path = nil, -- string : path to store dictionaries. Relative path uses current working directory
            log_level = 'none', -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
        }
    end,
    settings = {
        ltex = {
            checkFrequency = 'edit',
            language = 'en-US',
            additionalRules = {
                enablePickyRules = true,
                motherTongue = 'pt-BR',
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
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
        ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    },

    sources = {
        { name = 'nvim_lua' },
        { name = 'copilot' },
        { name = 'orgmode' },
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'luasnip' },
        { name = 'buffer', keyword_length = 5 },
    },

    formatting = {
        format = lspkind.cmp_format {
            symbol_map = {
                Copilot = '',
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

local null_ls = require 'null-ls'

null_ls.setup {
    sources = {
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.hover.dictionary,
        null_ls.builtins.hover.printenv,
        null_ls.builtins.formatting.stylua,

        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.diagnostics.eslint,

        null_ls.builtins.code_actions.shellcheck,

        null_ls.builtins.completion.spell,

        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.flake8,

        -- nix
        null_ls.builtins.code_actions.statix,
        null_ls.builtins.diagnostics.statix,
    },
}

-- Show lsp sever status/progress in the botton right corner
require('fidget').setup {}

require('indent_blankline').setup {}
