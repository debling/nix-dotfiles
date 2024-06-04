local utils = require('debling.config_utils')

local neogit = utils.lazy_require(function()
    local mod = require('neogit')
    mod.setup()
    return mod
end)

utils.nmap('<leader>gg', function()
    if neogit == nil then
        neogit = require('neogit')
        neogit.setup()
    end

    neogit.open()
end)

require('gitsigns').setup()
