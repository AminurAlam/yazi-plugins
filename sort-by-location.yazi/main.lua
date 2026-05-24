--- @since 25.12.29

local M = {}

---@type fun(opts: SortConf): nil
local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

---@type fun(): SortConf
local get_config = ya.sync(function(st)
  return st.opts or { default = { by = 'extension', reverse = false } }
end)

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

---@param config SortConf
---@return SortTable
local find_match = function(config)
  local cwd = tostring(cx.active.current.cwd)
  for _, conf in ipairs(config) do
    if cwd:find(conf.pattern) then
      return conf.sort
    end
  end
  return config.default
end

-- TODO: ask in config if new short should be local or global
-- TODO: turn off regex match and do literal match

---@param config SortConf
function M:setup(config)
  set_config(tbl_deep_extend(get_config(), config))
  ps.sub('ind-sort', function()
    return find_match(get_config()) ---@diagnostic disable-line: redundant-return-value
  end)
end

---@param job Job
function M:entry(job)
  local pref = get_config().default
  local by, rev = job.args[1], pref.reverse

  if pref.by == by then
    rev = not rev
  elseif by == 'mtime' or by == 'size' then
    rev = true
  end

  local new = { by = by, reverse = rev }
  ya.dbg(new)
  ya.emit('sort', new)
  -- TODO: change both default and current match
  set_config(tbl_deep_extend(get_config(), { default = new }))
end

return M
