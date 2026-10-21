local M = {}

---@type fun(opts: table) nil
local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

---@type fun() table
local get_config = ya.sync(function(st)
  return st.opts or {}
end)

---@generic T
---@param default any
---@param config T
---@return T
local function tbl_deep_extend(default, config)
  if type(config) ~= 'table' then
    return config
  end

  default = (type(default) == 'table') and default or {}
  for key, _ in pairs(config) do
    default[key] = tbl_deep_extend(default[key], config[key])
  end

  return default
end

---@generic T
---@param default T
---@param config any
---@return T
local function tbl_strict_extend(default, config)
  if type(default) ~= type(config) then
    return default
  end
  if type(default) ~= 'table' then
    if config ~= nil then
      return config
    else
      return default
    end
  end

  for key, _ in pairs(default) do
    default[key] = tbl_strict_extend(default[key], config[key])
  end

  return default
end

function M:setup(config)
  set_config(tbl_strict_extend(get_config(), config))
  set_config(tbl_deep_extend(get_config(), { key = config.key }))
end

-- TODO: on key call
function M:enter(job) end

-- TODO: move to functional-template.yazi/

return M
