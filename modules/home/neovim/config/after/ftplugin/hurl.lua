require('hurl').setup()

local function nmap(key, effect, opts)
  vim.keymap.set('n', key, effect, opts or { silent = true, noremap = true })
end

local function vmap(key, effect, opts)
  vim.keymap.set('v', key, effect, opts or { silent = true, noremap = true })
end

nmap('<leader>A', '<cmd>HurlRunner<CR>', { desc = 'Run All requests' })
nmap('<leader>a', '<cmd>HurlRunnerAt<CR>', { desc = 'Run Api request' })
nmap('<leader>te', '<cmd>HurlRunnerToEntry<CR>', { desc = 'Run Api request to entry' })
nmap('<leader>tE', '<cmd>HurlRunnerToEnd<CR>', { desc = 'Run Api request from current entry to end' })
nmap('<leader>tm', '<cmd>HurlToggleMode<CR>', { desc = 'Hurl Toggle Mode' })
nmap('<leader>tv', '<cmd>HurlVerbose<CR>', { desc = 'Run Api in verbose mode' })
nmap('<leader>tV', '<cmd>HurlVeryVerbose<CR>', { desc = 'Run Api in very verbose mode' })
vmap('<leader>a', ':HurlRunner<CR>', { desc = 'Hurl Runner' })
