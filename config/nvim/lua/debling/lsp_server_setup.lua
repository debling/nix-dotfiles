local null_ls = require('null-ls')
-- local utils = require('debling.config_utils')

local M = {}

-- Null-ls does NOT define a type for its source table
---@alias NullLsSource table

---@param select_sources_fn fun(table): NullLsSource[]
function M.null_ls_register(select_sources_fn)
  local sources = select_sources_fn(null_ls.builtins)
  for _, s in ipairs(sources) do
    if not null_ls.is_registered(s.name) then
      null_ls.register(s)
    end
  end
end

------@param _ unknown
------@param bufnr buffer
---function M.on_attach(_, bufnr)
---  -- Mappings.
---  -- See `:help vim.lsp.*` for documentation on any of the below functions
---  local bufopts = { buffer = bufnr }
---  local bindings = {
---    { 'gD', vim.lsp.buf.declaration },
---    { 'gd', vim.lsp.buf.definition },
---    { 'K', vim.lsp.buf.hover },
---    { 'gi', vim.lsp.buf.implementation },
---    { '<space>wa', vim.lsp.buf.add_workspace_folder },
---    { '<space>wr', vim.lsp.buf.remove_workspace_folder },
---    {
---      '<space>wl',
---      function()
---        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
---      end,
---    },
---    { '<space>D', vim.lsp.buf.type_definition },
---    { '<space>rn', vim.lsp.buf.rename },
---    { '<space>ca', vim.lsp.buf.code_action },
---    { 'gr', vim.lsp.buf.references },
---  }
---
---  for _, binding in ipairs(bindings) do
---    utils.nmap(binding[1], binding[2], bufopts)
---  end
---
---  utils.map({ 'n', 'v' }, '<space>f', function()
---    vim.lsp.buf.format({ async = true })
---  end, bufopts)
---
---  utils.map({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, bufopts)
---end

return M
