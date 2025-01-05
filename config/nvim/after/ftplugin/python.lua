local lsp = require('lspconfig')


local language_servers = {'pyright', 'ruff'}

for _, server in ipairs(language_servers) do
    lsp[server].setup({})
end
