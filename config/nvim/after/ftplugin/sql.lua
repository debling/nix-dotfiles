local lsp_setup = require('lsp_server_setup')
local cmp = require('cmp')

local sqlfluff_args = {
    extra_args = { "--dialect", "postgres" },
}

lsp_setup.null_ls_register(function(builtins)
    return {
        builtins.diagnostics.sqlfluff.with(sqlfluff_args),
        builtins.formatting.sqlfluff.with(sqlfluff_args),
    }
end)

cmp.setup.filetype({ 'sql', 'mysql', 'plsql' }, {
    sources = cmp.config.sources({
        { name = 'vim-dadbod-completion' },
    }),
})


-- vim-dadbod setup
vim.g.db_ui_env_variable_url = 'DATABASE_URL'
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_execute_on_save = 0
