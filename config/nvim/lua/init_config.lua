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
vim.o.directory = os.getenv 'HOME' .. '/.cache/nvim'
vim.o.backup = true
vim.o.backupdir = os.getenv 'HOME' .. '/.cache/nvim'

-- Enable undo features, even after closing vim
vim.o.undofile = true
vim.o.undodir = os.getenv 'HOME' .. '/.cache/nvim'
vim.o.undolevels = 10000

-- Map leader key to <space>
vim.g.mapleader = ' '

require 'colorscheme_config'

require('neodev').setup {}

require 'lsp_config'

require 'telescope_config'

require 'treesitter_config'

require 'orgmode_config'

require('lualine').setup {
  options = {
    icons_enabled = false,
    component_separators = '|',
    section_separators = '',
  },
}

require('Comment').setup()

local neogit = require 'neogit'
neogit.setup {}
vim.keymap.set('n', '<leader>gg', function()
  neogit.open()
end, { noremap = true })

-- vimwiki configurations
vim.g.vimwiki_list = {
  {
    path = '~/workspace/debling/personal-wiki',
    syntax = 'markdown',
    ext = '.md',
    index = 'README',
  },
}
-- Treat only markdown files inside the path above, as vimwiki files
vim.g.vimwiki_global_ext = 0

-- command! LocalTerm let s:term_dir=expand('%:p:h') | below new | call termopen([&shell], {'cwd': s:term_dir })
vim.keymap.set('n', '<leader>tn', function()
  local fileDir = vim.fn.expand '%:p:h'
  vim.cmd('below new | call termopen([&shell], {"cwd": "' .. fileDir .. '"})')
end, { noremap = true })


vim.o.timeout = true
vim.o.timeoutlen = 300
require("which-key").setup { }


-- local iron = require("iron.core")
--
-- iron.setup {
--   config = {
--     -- Whether a repl should be discarded or not
--     scratch_repl = true,
--     -- Your repl definitions come here
--     repl_definition = {
--       sh = {
--         -- Can be a table or a function that
--         -- returns a table (see below)
--         command = {"zsh"}
--       },
--
--       python = {
--         -- Can be a table or a function that
--         -- returns a table (see below)
--         command = {"ipython"}
--       }
--     },
--     -- How the repl window will be displayed
--     -- See below for more information
--     repl_open_cmd = require('iron.view').bottom(40),
--   },
--   -- Iron doesn't set keymaps by default anymore.
--   -- You can set them here or manually add keymaps to the functions in iron.core
--   keymaps = {
--     send_motion = "<space>sc",
--     visual_send = "<space>sc",
--     send_file = "<space>sf",
--     send_line = "<space>sl",
--     send_mark = "<space>sm",
--     mark_motion = "<space>mc",
--     mark_visual = "<space>mc",
--     remove_mark = "<space>md",
--     cr = "<space>s<cr>",
--     interrupt = "<space>s<space>",
--     exit = "<space>sq",
--     clear = "<space>cl",
--   },
--   -- If the highlight is on, you can change how it looks
--   -- For the available options, check nvim_set_hl
--   highlight = {
--     italic = true
--   },
--   ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
-- }
--
-- -- iron also has a list of commands, see :h iron-commands for all available commands
-- vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
-- vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
-- vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
-- vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
