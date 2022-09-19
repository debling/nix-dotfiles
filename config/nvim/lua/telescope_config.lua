local tel_builtin = require 'telescope.builtin'

local km = vim.keymap
-- nnoremap <leader>ff <cmd>Telescope find_files<cr>
km.set('n', '<Leader>ff', tel_builtin.find_files)
-- nnoremap <leader>fg <cmd>Telescope live_grep<cr>
km.set('n', '<Leader>fg', tel_builtin.live_grep)
-- nnoremap <leader>fb <cmd>Telescope buffers<cr>
km.set('n', '<Leader>fb', tel_builtin.buffers)
-- nnoremap <leader>fh <cmd>Telescope help_tags<cr>
km.set('n', '<Leader>fh', tel_builtin.help_tags)

local tel = require 'telescope'
tel.setup {
    extensions = {
        fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
tel.load_extension('fzf')
