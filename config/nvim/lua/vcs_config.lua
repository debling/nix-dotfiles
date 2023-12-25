local neogit = require('neogit')
neogit.setup({})
vim.keymap.set('n', '<leader>gg', function()
  neogit.open()
end, { noremap = true, silent = true })

require('gitsigns').setup()
