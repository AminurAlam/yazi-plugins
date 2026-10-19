local M = {}

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
  local config = {
    cols = 2,
    rows = 3,
    width = 480,
    height = 480,
    background = '#fff',
  }

  local size = config.cols * config.rows
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
      config.cols .. 'x' .. config.rows,
      '-geometry',
      config.width .. 'x' .. config.height .. '+0+0',
      '-background',
      config.background,
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
