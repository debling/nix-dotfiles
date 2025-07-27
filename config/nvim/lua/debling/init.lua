vim.loader.enable()

require('snacks').setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  indent = { enabled = true },
})

require('debling.basic_options')

require('debling.lsp_config')

require('debling.telescope_config')

require('debling.file_navigation_config')

-- vim-slime setup, default to tmux, using the pane in the bottom right
vim.g.slime_target = 'tmux'
vim.g.slime_default_config = {
  socket_name = vim.split(os.getenv('TMUX') or '', ',')[1],
  target_pane = '{bottom-right}',
}

-- From kicksart.nvim, see: https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = vim.highlight.on_yank,
})

require('obsidian').setup({
  workspaces = {
    {
      name = 'obsidian-vault',
      path = '~/Workspace/debling/obsidian-vault',
    },
    {
      name = 'zeit-docs',
      path = '~/Workspace/zeit/docs-projetos/',
    },
  },
  ui = {
    enable = false,
  },
})

local utils = require('debling.config_utils')
utils.nmap('<leader>og', '<cmd>ObsidianSearch<CR>')
utils.nmap('<leader>of', '<cmd>ObsidianQuickSwitch<CR>')
utils.nmap('<leader>ow', '<cmd>ObsidianWorkspace<CR>')

--[[

vim.g['conjure#mapping#doc_word'] = 'gk'

vim.api.nvim_create_autocmd('DiagnosticChanged', {
  pattern = { 'conjure-log-*' },
  callback = function(args)
    local diagnostics = args.data.diagnostics

    if diagnostics[1] ~= nil then
      local bufnr = diagnostics[1]['bufnr']
      local namespace = diagnostics[1]['namespace']
      vim.diagnostic.enable(false, { bufnr = bufnr })
      vim.diagnostic.reset(namespace, bufnr)
    end
  end,
})
--]]
require('ts-comments').setup()

require('todo-comments').setup()

-- -- Git helper
local neogit = utils.lazy_require(function()
  local mod = require('neogit')
  mod.setup({})
  return mod
end)

utils.nmap('<leader>gg', function()
  if neogit == nil then
    neogit = require('neogit')
    neogit.setup({})
  end

  neogit.open()
end)

require('gitsigns').setup()

-- --
-- -- UI setup
-- --
vim.o.termguicolors = true
vim.o.background = 'light'
vim.cmd.colorscheme('default')
vim.cmd.hi('Normal ctermbg=none guibg=none')

-- Show lsp sever status/progress in the botton right corner
require('fidget').setup({
  notification = {
    window = {
      winblend = 0,
    },
  },
})
