require('basic_options')

require('ui_config')

require('neodev').setup()
require('neoconf').setup()

require('lsp_config')

require('telescope_config')

require('treesitter_config')

require('vcs_config')

require('Comment').setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
})

-- vim-slime setup, default to tmux, using the pane in the bottom right
vim.g.slime_target = 'tmux'
vim.g.slime_default_config = {
    socket_name = vim.split(os.getenv('TMUX') or '', ',')[1],
    target_pane = '{bottom-right}',
}

local nmap = function(key, effect, desc)
    vim.keymap.set('n', key, effect, { silent = true, noremap = true, desc = desc })
end

local vmap = function(key, effect, desc)
    vim.keymap.set('v', key, effect, { silent = true, noremap = true, desc = desc })
end

local imap = function(key, effect, desc)
    local opts = { silent = true, noremap = true, desc = desc }
    vim.keymap.set('i', key, effect, opts)
end

require('oil').setup()

require('nvim-lastplace').setup()

-- trouble.nvim
local trouble = require('trouble')

-- Lua
nmap('<leader>xx', function()
    trouble.open()
end)
nmap('<leader>xw', function()
    trouble.open('workspace_diagnostics')
end)
nmap('<leader>xd', function()
    trouble.open('document_diagnostics')
end)
nmap('<leader>xq', function()
    trouble.open('quickfix')
end)
nmap('<leader>xl', function()
    trouble.open('loclist')
end)
nmap('gR', function()
    trouble.open('lsp_references')
end)

require('nvim-tree').setup({
    sort = {
        sorter = 'case_sensitive',
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = true,
    },
})

nmap('<leader>ft', require('nvim-tree.api').tree.toggle, 'Toggle nvim-tree')

-- vim-dadbod setup
vim.g.db_ui_env_variable_url = 'DATABASE_URL'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
