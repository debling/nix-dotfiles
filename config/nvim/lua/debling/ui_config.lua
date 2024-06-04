vim.opt.termguicolors = true
vim.o.background = 'dark' -- or "light" for light mode

require("gruvbox").setup({
  contrast = "hard", -- can be "hard", "soft" or empty string
})

vim.cmd('colorscheme gruvbox')

-- require('catppuccin').setup({
--   flavour = 'mocha', -- latte, frappe, macchiato, mocha
--   transparent_background = false, -- disables setting the background color.
--   integrations = {
--     fidget = true,
--     -- harpoon = true,
--   },
-- })
--
-- vim.cmd('colorscheme catppuccin')

require('lualine').setup({
  options = {
    theme = 'gruvbox',
    -- theme = 'catppuccin',
    component_separators = '|',
    section_separators = ' ',
    -- globalstatus = true,
  },
})

-- https://github.com/lukas-reineke/indent-blankline.nvim
require('ibl').setup()

-- Show lsp sever status/progress in the botton right corner
require('fidget').setup({
  notification = {
    window = {
      winblend = 0,
    },
  },
})
