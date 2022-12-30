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
        { '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end },
        { '<space>D', vim.lsp.buf.type_definition },
        { '<space>rn', vim.lsp.buf.rename },
        { '<space>ca', vim.lsp.buf.code_action },
        { 'gr', vim.lsp.buf.references },
        { '<space>f', function()
            vim.lsp.buf.format { async = true }
        end },
    }

    for _, binding in ipairs(bindings) do
        km.set('n', binding[1], binding[2], bufopts)
    end
end

local lsp = require('lspconfig')

vim.lsp.set_log_level('debug')

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

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

lsp.lemminx.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lsp.texlab.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lsp.rnix.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lsp.dockerls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

lsp.yamlls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.yml",
            },
        },
    }
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
                library = vim.api.nvim_get_runtime_file("", true),
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
        '-data',
        get_jdtls_workspace_dir(),
        get_jdtls_jvm_args(),
        -- get_lombok_arg(),
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

require("luasnip.loaders.from_vscode").lazy_load()

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
        { name = "copilot" },
        { name = "orgmode" },
        { name = 'nvim_lsp' },
        { name = "path" },
        { name = 'luasnip' },
        { name = "buffer", keyword_length = 5 },
    },

    formatting = {
        format = lspkind.cmp_format {
            with_text = true,
            menu = {
                buffer = "[buf]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[api]",
                path = "[path]",
                luasnip = "[snip]",
                copilot = "[copilot]",
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

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.trim_newlines,
        null_ls.builtins.hover.dictionary,
        null_ls.builtins.hover.printenv,
        null_ls.builtins.formatting.stylua,

        null_ls.builtins.code_actions.eslint,
        null_ls.builtins.diagnostics.eslint,

        null_ls.builtins.code_actions.shellcheck,

        null_ls.builtins.completion.spell,
    },
})
