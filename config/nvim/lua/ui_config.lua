vim.opt.termguicolors = true
vim.o.background = 'dark' -- or "light" for light mode

vim.cmd('colorscheme gruvbox')

require('lualine').setup({
  options = {
    theme = 'gruvbox',
    component_separators = '|',
    section_separators = ' ',
    globalstatus = true,
  },
})

-- https://github.com/lukas-reineke/indent-blankline.nvim
require('ibl').setup()

-- Show lsp sever status/progress in the botton right corner
require('fidget').setup()
