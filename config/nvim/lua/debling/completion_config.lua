local utils = require('debling.config_utils')

---@enum JumpDirection
local JUMP_DIRECTION = {
    prev = -1,
    next = 1,
}

---@param keys string
---@param direction JumpDirection
local function snippet_jump_or_send_keys(keys, direction)
    ---@cast direction vim.snippet.Direction
    if vim.snippet.active({ direction = direction }) then
        vim.snippet.jump(direction)
    else
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), 'n')
    end
end

-- move to previous item on the snippert
utils.map({ 'i', 's' }, '<c-h>', function()
    snippet_jump_or_send_keys('<c-h>', JUMP_DIRECTION.prev)
end)

-- move to foward item on the snippert
utils.map({ 'i', 's' }, '<c-l>', function()
    snippet_jump_or_send_keys('<c-l>', JUMP_DIRECTION.next)
end, { silent = true, noremap = false })
