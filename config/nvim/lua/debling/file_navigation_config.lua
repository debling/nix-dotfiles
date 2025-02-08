local utils = require('debling.config_utils')

local function load_setup_treesitter()
  require('nvim-treesitter.configs').setup({
    modules = {},
    ensure_installed = {},
    ignore_install = { "all" },
    sync_install = false,
    auto_install = false,
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    refactor = {
      highlight_definitions = {
        enable = true,
        -- Set to false if you have an `updatetime` of ~100.
        clear_on_cursor_move = true,
      },
      navigation = {
        enable = true,
        keymaps = {
          goto_definition = 'gnd',
          list_definitions = 'gnD',
          list_definitions_toc = 'gO',
          goto_next_usage = '<a-*>',
          goto_previous_usage = '<a-#>',
        },
      },
    },
  })
end

vim.defer_fn(load_setup_treesitter, 1)

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

local harpoon = require('harpoon')

-- REQUIRED
harpoon:setup()
-- REQUIRED

utils.nmap('<leader>a', function() harpoon:list():add() end)
utils.nmap('<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

utils.nmap('<leader>h', function() harpoon:list():select(1) end)
utils.nmap('<leader>j', function() harpoon:list():select(2) end)
utils.nmap('<leader>k', function() harpoon:list():select(3) end)
utils.nmap('<leader>l', function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
utils.nmap('<leader>p', function() harpoon:list():prev() end)
utils.nmap('<leader>n', function() harpoon:list():next() end)
