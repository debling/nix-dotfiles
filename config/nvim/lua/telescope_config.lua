local utils = require('config_utils')
local tel = require('telescope')
local tel_builtin = require('telescope.builtin')

utils.nmap('<Leader>ff', tel_builtin.find_files)
utils.nmap('<Leader>fg', tel_builtin.live_grep)
utils.nmap('<Leader>fb', tel_builtin.buffers)
utils.nmap('<Leader>fd', tel_builtin.diagnostics)
utils.nmap('<Leader>fh', tel_builtin.help_tags)
utils.nmap('<Leader>fs', tel_builtin.lsp_dynamic_workspace_symbols)

utils.nmap('z=', tel_builtin.spell_suggest)

tel.setup({
    extensions = {
        fzf = {
            fuzzy = true,             -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },
    },
})
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
tel.load_extension('fzf')
tel.load_extension('ui-select')


-- remember the last place you were editing a file
require('nvim-lastplace').setup()

-- a pretty good file explorer
require('oil').setup()

-- Intellij style file tree, rarely used, so lazy load
local nvim_tree = nil
utils.nmap('<leader>ft',
    function()
        if nvim_tree == nil then
            nvim_tree = require('nvim-tree')
            nvim_tree.setup({
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
        end

        require('nvim-tree.api').tree.toggle()
    end
)
