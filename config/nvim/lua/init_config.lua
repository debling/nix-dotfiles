vim.loader.enable()

require('basic_options')

require('ui_config')

require('neodev').setup()

require('lsp_config')

require('completion_config')

require('telescope_config')

require('file_navigation_config')

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

-- vim-dadbod setup
vim.g.db_ui_env_variable_url = 'DATABASE_URL'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
