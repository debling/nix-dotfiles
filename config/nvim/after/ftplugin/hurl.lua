require('hurl').setup()

local keys = {
  { '<leader>A', '<cmd>HurlRunner<CR>', desc = 'Run All requests' },
  { '<leader>a', '<cmd>HurlRunnerAt<CR>', desc = 'Run Api request' },
  { '<leader>te', '<cmd>HurlRunnerToEntry<CR>', desc = 'Run Api request to entry' },
  {
    '<leader>tE',
    '<cmd>HurlRunnerToEnd<CR>',
    desc = 'Run Api request from current entry to end',
  },
  { '<leader>tm', '<cmd>HurlToggleMode<CR>', desc = 'Hurl Toggle Mode' },
  { '<leader>tv', '<cmd>HurlVerbose<CR>', desc = 'Run Api in verbose mode' },
  { '<leader>tV', '<cmd>HurlVeryVerbose<CR>', desc = 'Run Api in very verbose mode' },
  -- Run Hurl request in visual mode
  { '<leader>a', ':HurlRunner<CR>', desc = 'Hurl Runner', mode = 'v' },
}

for _, key in pairs(keys) do
  local mode = key.mode or 'n'
  vim.api.nvim_set_keymap(
    mode,
    key[1],
    key[2],
    { noremap = true, silent = true, desc = key.desc }
  )
end
