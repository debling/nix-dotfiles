local luasnip = require('luasnip')
local lspkind = require('lspkind')
local cmp = require('cmp')

local utils = require('config_utils')

-- Expand snippert with or run the normal c-k action
utils.map({ 'i', 's' }, '<c-k>', function()
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    else
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-k>', true, true, true), 'n')
    end
end)

-- move to previous item on the snippert
utils.map({ 'i', 's' }, '<c-h>', function()
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
    else
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-h>', true, true, true), 'n')
    end
end)

-- move to foward item on the snippert
utils.map({ 'i', 's' }, '<c-l>', function()
    if luasnip.jumpable(1) then
        luasnip.jump(1)
    else
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-l>', true, true, true), 'n')
    end
end, { silent = true, noremap = false })

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'copilot' },
        { name = 'luasnip' },
        { name = 'nvim_lsp' },
        { name = 'path' },
    }, {
        { name = 'buffer', keyword_length = 5 },
    }),

    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol',
            maxwidth = 50,
        }),
    },

    view = {
        entries = 'native',
    },

    experimental = {
        ghost_text = true,
    },
})

cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
        { name = 'buffer' },
    }),
})

cmp.setup.filetype({ 'sql', 'mysql', 'plsql' }, {
    sources = cmp.config.sources({
        { name = 'vim-dadbod-completion' },
    }),
})

-- cmp.setup.cmdline({ '/', '?' }, {
--     mapping = cmp.mapping.preset.cmdline(),
--     view = {
--         entries = { name = 'wildmenu', separator = ' | ' },
--     },
--     sources = {
--         { name = 'buffer' },
--     },
-- })

-- cmp.setup.cmdline(':', {
--     mapping = cmp.mapping.preset.cmdline(),
--     view = {
--         entries = { name = 'wildmenu', separator = ' | ' },
--     },
--     sources = cmp.config.sources({
--         { name = 'path' },
--     }, {
--         { name = 'cmdline' },
--     }),
-- })
