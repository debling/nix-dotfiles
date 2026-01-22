local language_servers = { 'pyright', 'ruff' }

for _, server in ipairs(language_servers) do
  vim.lsp.config(server, {})
  vim.lsp.enable(server)
end
