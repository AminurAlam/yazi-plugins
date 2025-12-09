local M = {}

local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

local get_config = ya.sync(function(st)
  return st.opts
    or {
      insensitive = true,
      keep_searching = { enable = false, limit = 10 },
      aliases = {},
    }
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

---@param dir File
local get_dirinfo = function(dir)
  if not dir.cha.is_dir then
    return
  end
  local cmd = Command('dust'):arg { '-jPtn5', dir.name }

  local output, err = cmd:output()
  if not output then
    return nil, Err('Failed to start `dust`, error: %s', err)
  end

  local json = ya.json_decode(output.stdout)
  ya.dbg(json)

  return {}
end

function M:setup(config)
  set_config(tbl_deep_extend(get_config(), config))
end

function M:spot(job)
  require('spot'):spot(job, get_dirinfo(job.file))
end

return M
