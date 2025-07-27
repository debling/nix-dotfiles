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
vim.o.swapfile = false

-- Enable undo features, even after closing vim
vim.o.undofile = true
vim.o.undodir = os.getenv('HOME') .. '/.cache/nvim'
vim.o.undolevels = 10000

-- Map leader key to <space>
local leaderKey = ' '
vim.g.mapleader = leaderKey
vim.g.maplocalleader = leaderKey
