local M = {}

local default_opts = { silent = true, noremap = true }

---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.nmap(key, effect, opts)
    local mergedOpts = vim.tbl_extend('keep', opts or {}, default_opts)
    vim.keymap.set('n', key, effect, mergedOpts)
end

---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.vmap(key, effect, opts)
    local mergedOpts = vim.tbl_extend('keep', opts or {}, default_opts)
    vim.keymap.set('v', key, effect, mergedOpts)
end

---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.imap(key, effect, opts)
    local mergedOpts = vim.tbl_extend('keep', opts or {}, default_opts)
    vim.keymap.set('i', key, effect, mergedOpts)
end

return M
