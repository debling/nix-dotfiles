local lsp_setup = require('lsp_server_setup')
local jdtls = require('jdtls')

---@param jdk_version string
---@return string
local function jdk_path(jdk_version)
    return vim.fs.normalize('~/SDKs/Java/' .. jdk_version)
end

local runtimes = {
    {
        name = 'JavaSE-1.8',
        path = jdk_path('8'),
    },
    {
        name = 'JavaSE-11',
        path = jdk_path('11'),
    },
    {
        name = 'JavaSE-17',
        path = jdk_path('17'),
    },
    {
        name = 'JavaSE-21',
        path = jdk_path('21'),
    },
}

local bundles = {
    -- FIXME: hardcoded, use nix to build
    vim.fn.glob(
        '/Users/debling/Workspace/probe/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar',
        true
    ),
}

vim.list_extend(
    bundles,
    vim.split(
        -- FIXME: hardcoded, use nix to build
        vim.fn.glob('/Users/debling/Workspace/probe/vscode-java-test/server/*.jar', true),
        '\n'
    )
)

local config = {
    cmd = {
        -- FIXME: hardcoded, use nix to build
        vim.fs.normalize('~/.local/bin/jdtls'),
    },
    on_attach = lsp_setup.on_attach,
    capabilities = lsp_setup.capabilities,
    init_options = {
        bundles = bundles,
    },
    settings = {
        java = {
            configuration = {
                runtimes = runtimes,
            },
            format = {
                settings = {
                    url = 'https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml',
                    profile = 'GoogleStyle',
                },
            },
        },
    },
}
jdtls.jol_path = vim.fs.normalize('~/Downloads/jol-cli-latest.jar')
jdtls.start_or_attach(config)
