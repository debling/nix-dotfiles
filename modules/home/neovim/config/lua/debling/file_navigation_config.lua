local utils = require('debling.config_utils')

vim.g.netrw_banner = 0

vim.api.nvim_create_autocmd('FileType', {
  callback = function() pcall(vim.treesitter.start) end,
})

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'


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
