local tel_builtin = require 'telescope.builtin'

local km = vim.keymap

km.set('n', '<Leader>ff', tel_builtin.find_files)
km.set('n', '<Leader>fg', tel_builtin.live_grep)
km.set('n', '<Leader>fb', tel_builtin.buffers)
km.set('n', '<Leader>fd', tel_builtin.diagnostics)
km.set('n', '<Leader>fh', tel_builtin.help_tags)
km.set('n', '<Leader>fs', tel_builtin.lsp_dynamic_workspace_symbols)

km.set('n', 'z=', tel_builtin.spell_suggest)

local tel = require 'telescope'
tel.setup {
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
  },
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
tel.load_extension 'fzf'
tel.load_extension 'ui-select'
