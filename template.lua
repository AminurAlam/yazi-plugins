local M = {}

local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

local get_config = ya.sync(function(st)
  return st.opts or {}
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

function M:setup(config)
  set_config(tbl_deep_extend(get_config(), config))
end

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end

  local ok, err = self:preload(job)
  if not ok or err then
    return
  end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err and ui.Text(err):area(job.area):wrap(ui.Wrap.YES))
end

function M:seek(job) end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then
    return true
  end

  local output, err = Command(''):arg({
    tostring(job.file.url),
    tostring(cache),
    job.skip + 1,
  }):output()

  if not output then
    return true, Err('Failed to start ``, error: %s', err)
  elseif not output.status.success then
    return true, Err('Failed to get image, stderr: %s', output.stderr)
  end

  return true
end

function M:spot(job)
  require('spot'):spot(job, { { title = 'Something' } })
end

return M
