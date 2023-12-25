-- disable netrw at the very start of your init.lua, recomended for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wrapscan = true
vim.o.hlsearch = true

-- Relative numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Indent options
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

-- Line options
vim.o.showmatch = true
vim.o.showbreak = '+++'
vim.o.textwidth = 79
vim.o.scrolloff = 5
vim.wo.colorcolumn = '90'

-- Set clipboard to work with system copy/paste
vim.opt.clipboard = 'unnamedplus'

-- Move swapfiles and backupfiles to ~/.cache
vim.o.directory = os.getenv('HOME') .. '/.cache/nvim'
vim.o.backup = true
vim.o.backupdir = os.getenv('HOME') .. '/.cache/nvim'

-- Enable undo features, even after closing vim
vim.o.undofile = true
vim.o.undodir = os.getenv('HOME') .. '/.cache/nvim'
vim.o.undolevels = 10000

-- Map leader key to <space>
vim.g.mapleader = ' '

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

-- command! LocalTerm let s:term_dir=expand('%:p:h') | below new | call termopen([&shell], {'cwd': s:term_dir })
vim.keymap.set('n', '<leader>tn', function()
    local fileDir = vim.fn.expand('%:p:h')
    vim.cmd('below new | call termopen([&shell], {"cwd": "' .. fileDir .. '"})')
end, { noremap = true })

vim.o.timeout = true
vim.o.timeoutlen = 300

require('which-key').setup({})

-- slime
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

require('rest-nvim').setup({
    -- Open request results in a horizontal split
    result_split_horizontal = false,
    -- Keep the http file buffer above|left when split horizontal|vertical
    result_split_in_place = false,
    -- Skip SSL verification, useful for unknown certificates
    skip_ssl_verification = false,
    -- Encode URL before making request
    encode_url = true,
    -- Highlight request on run
    highlight = {
        enabled = true,
        timeout = 150,
    },
    result = {
        -- toggle showing URL, HTTP info, headers at top the of result window
        show_url = true,
        show_http_info = true,
        show_headers = true,
        -- executables or functions for formatting response body [optional]
        -- set them to false if you want to disable them
        formatters = {
            json = 'jq',
            html = function(body)
                return vim.fn.system({ 'tidy', '-i', '-q', '-' }, body)
            end,
        },
    },
    -- Jump to request line on run
    jump_to_request = false,
    env_file = '.env',
    custom_dynamic_variables = {},
    yank_dry_run = true,
})

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

vim.g.db_ui_env_variable_url = 'DATABASE_URL'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
