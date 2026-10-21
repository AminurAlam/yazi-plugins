local M = {}

---@type fun(opts: table) nil
local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

---@type fun() table
local get_config = ya.sync(function(st)
  return st.opts or {}
end)

--- merge configs overwriting `LEFT` with `RIGHT`
--- unless `LEFT` is an empty table
---@generic T
---@param default T
---@param config any
---@return T
local function tbl_extend(default, config)
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

  local count = 0
  for key, _ in pairs(default) do
    default[key] = tbl_extend(default[key], config[key])
    count = count + 1
  end

  -- the left table was empty so we
  -- probably always want the right table
  if count == 0 then
    return config
  end

  return default
end

----------------------------------------------------------------------

---@param config any
function M:setup(config)
  set_config(tbl_extend(get_config(), config))

  local config = get_config()
  -- do something with config
end

return M
