local M = {}

---@type fun(opts: ImgDirConf) nil
local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

---@type fun(): ImgDirConf
local get_config = ya.sync(function(st)
  return st.opts
    or {
      cols = 2,
      rows = 3,
      width = 480,
      height = 480,
      background = '#fff',
      patterns = {},
    }
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

---@param config ImgDirConf
function M:setup(config)
  set_config(tbl_extend(get_config(), config))

  local config = get_config()
  for _, url in ipairs(config.patterns or {}) do
    rt.plugin.previewers:insert(1, { url = url, run = 'preview-imgdir' })
    rt.plugin.preloaders:insert(1, { url = url, run = 'preview-imgdir' })
  end
end

---@param job Job
function M:_native_peek(job)
  local start = os.clock()
  local cached = self:_native_preload(job)

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local h = 0
  for _, cache in ipairs(cached) do
    local area = ui.Rect {
      x = job.area.x,
      y = job.area.y + h,
      w = job.area.w / 2,
      h = job.area.h - h,
    }
    local img_area, _ = ya.image_show(cache.url, area)
    h = h + (img_area and img_area.h or 0) + 1
  end
end

---@param job Job
---@return File[]
function M:_native_preload(job)
  return fs.read_dir(job.file.url, { glob = '*.{jpg,png}', limit = 3 }) or {}
end

-----------------------------------------------------------------------------------

---@param job Job
function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end

  local err = self:preload(job)
  if err then
    ya.preview_widget(job, err)
    return
  end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err)
end

---@param job Job
---@return Error?
function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then
    return
  end

  local opts = get_config()
  local size = opts.cols * opts.rows
  -- TODO: sort by mtime
  local files = fs.read_dir(job.file.url, { glob = '*.{jpg,png}', limit = size })
  if not files or #files ~= size then
    return Err('incompatible files')
  end
  local fnames = {}
  for i, file in ipairs(files) do
    fnames[i] = tostring(file.url)
  end

  local output, err = Command('montage')
    :arg(fnames)
    :arg({
      '-tile',
      opts.cols .. 'x' .. opts.rows,
      '-geometry',
      opts.width .. 'x' .. opts.height .. '+0+0',
      '-background',
      opts.background,
      'JPG:' .. tostring(cache),
    })
    :output()

  if not output or err then
    return Err('Failed to start `imagemagick/montage`: %s', err)
  elseif not output.status.success then
    return Err('stderr: %s', output.stderr)
  end
end

return M
