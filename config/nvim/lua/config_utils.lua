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

---@tag lazy-require

---@brief [[
--- Lazy.nvim is a set of helper functions to make requiring modules easier.
---
--- Feel free to just copy and paste these functions out or just add as a
--- dependency for your plugin / configuration.
---
--- Hope you enjoy (and if you have other kinds of lazy loading you'd like to see,
--- feel free to submit some issues. Metatables can do many fun things).
---
--- Source:
--- - https://github.com/tjdevries/lazy-require.nvim
---
--- Support:
--- - https://github.com/sponsors/tjdevries
---
---@brief ]]

--- Require on index.
---
--- Will only require the module after the first index of a module.
--- Only works for modules that export a table.
M.require_on_index = function(require_path)
    return setmetatable({}, {
        __index = function(_, key)
            return require(require_path)[key]
        end,

        __newindex = function(_, key, value)
            require(require_path)[key] = value
        end,
    })
end

--- Requires only when you call the _module_ itself.
---
--- If you want to require an exported value from the module,
--- see instead |lazy.require_on_exported_call()|
M.require_on_module_call = function(require_path)
    return setmetatable({}, {
        __call = function(_, ...)
            return require(require_path)(...)
        end,
    })
end

--- Require when an exported method is called.
---
--- Creates a new function. Cannot be used to compare functions,
--- set new values, etc. Only useful for waiting to do the require until you actually
--- call the code.
---
--- <pre>
--- -- This is not loaded yet
--- local lazy_mod = lazy.require_on_exported_call('my_module')
--- local lazy_func = lazy_mod.exported_func
---
--- -- ... some time later
--- lazy_func(42)  -- <- Only loads the module now
---
--- </pre>
M.require_on_exported_call = function(require_path)
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                return require(require_path)[k](...)
            end
        end,
    })
end

---@generic T : table
---@param req_fn fun(): T functions that returns the module
---@return T
function M.lazy_require(req_fn)
    local module = nil
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                if module == nil then
                    module = req_fn()
                end
                return module[k](...)
            end
        end,
    })
end

---@alias PathSeparator '/' | '\'
---@type PathSeparator
M.path_sep = vim.loop.os_uname().sysname:match('Windows') and '\\' or '/' --[[@as PathSeparator]]


---@param ... string[]
---@return string
function M.path_join(...)
    return table.concat(vim.tbl_flatten({ ... }), M.path_sep)
end

return M
