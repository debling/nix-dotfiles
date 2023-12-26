local M = {}

local default_opts = { silent = true, noremap = true }

---@param modes ('i' | 'n' | 'v' | 's' | 't')[]
---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.map(modes, key, effect, opts)
    local mergedOpts = vim.tbl_extend('keep', opts or {}, default_opts)
    vim.keymap.set(modes, key, effect, mergedOpts)
end

---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.nmap(key, effect, opts)
    M.map({ 'n' }, key, effect, opts)
end

---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.vmap(key, effect, opts)
    M.map({ 'v' }, key, effect, opts)
end

---@param key string
---@param effect fun(): nil
---@param opts table | nil
function M.imap(key, effect, opts)
    M.map({ 'i' }, key, effect, opts)
end

return M
