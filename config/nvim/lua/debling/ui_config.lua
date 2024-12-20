vim.cmd.colorscheme('base16-gruvbox-dark-hard')

--
-- vim.cmd.hi('Normal ctermbg=none guibg=none')
--
-- -- change treesitter context to a bridger color, default is NvimDarkGrey1
-- vim.cmd.hi('NormalFloat guibg=NvimDarkGrey3')

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

vim.diagnostic.config({ float = { source = true } })

require('todo-comments').setup()
