vim.loader.enable()

require('snacks').setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  indent = { enabled = true },
})

require('debling.basic_options')

require('debling.ui_config')

require('debling.lsp_config')

require('debling.completion_config')

require('debling.telescope_config')

require('debling.file_navigation_config')

require('debling.vcs_config')

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
  callback = function() vim.highlight.on_yank() end,
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
})

local utils = require('debling.config_utils')

utils.nmap('<leader>oq', '<cmd>ObsidianSearch<CR>')

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

require('freeze-code').setup({
  copy = true,
  dir = '/tmp',
  freeze_config = { -- configuration options for `freeze` command
    theme = 'catppuccin-mocha',
  },
})

require('quarto').setup({
  codeRunner = {
    enabled = false,
    default_method = 'slime', -- 'molten' or 'slime'
  },
})

require('ts-comments').setup()
