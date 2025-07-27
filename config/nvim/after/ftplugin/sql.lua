local utils = require('debling.config_utils')

local sqlfluff_args = {
  extra_args = { '--dialect', 'postgres' },
}

utils.null_ls_register(
  function(builtins)
    return {
      builtins.diagnostics.sqlfluff.with(sqlfluff_args),
      builtins.formatting.sqlfluff.with(sqlfluff_args),
    }
  end
)

-- vim-dadbod setup
vim.g.db_ui_env_variable_url = 'DATABASE_URL'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
