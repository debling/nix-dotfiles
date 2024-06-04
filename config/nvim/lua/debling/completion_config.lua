local lspkind = require('lspkind')
local cmp = require('cmp')

local utils = require('debling.config_utils')

-- Expand snippert with or run the normal c-k action
utils.map({ 'i', 's' }, '<c-k>', function()
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    else
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<c-k>', true, true, true), 'n')
    end
end)

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
utils.map({ 'i', 's' }, '<c-h>', function()
    snippet_jump_or_send_keys('<c-h>', JUMP_DIRECTION.prev)
end)

-- move to foward item on the snippert
utils.map({ 'i', 's' }, '<c-l>', function()
    snippet_jump_or_send_keys('<c-l>', JUMP_DIRECTION.next)
end, { silent = true, noremap = false })

-- require('nvim-snippets').setup({
--     create_cmp_source = true,
--     friendly_snippets = true,
-- })

cmp.setup({
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },

    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'copilot' },
        { name = 'snippets' },
        { name = 'nvim_lsp' },
        { name = 'path' },
    }, {
        { name = 'buffer', keyword_length = 5 },
    }),

    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol',
            maxwidth = 50,
            symbol_map = { Copilot = '' },
        }),
    },

    experimental = {
        ghost_text = true,
    },

    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
})

cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' },
    }, {
        { name = 'buffer' },
    }),
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    view = {
        entries = { name = 'wildmenu', separator = ' | ' },
    },
    sources = {
        { name = 'buffer' },
    },
})

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
--     matching = { disallow_symbol_nonprefix_matching = true },
-- })

vim.defer_fn(function()
    require('copilot').setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
    })

    require('copilot_cmp').setup()
end, 0)
