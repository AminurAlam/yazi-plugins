local M = {}

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

  ---@diagnostic disable-next-line: redefined-local
  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err)
end

function M:seek() end

---@param job Job
---@return Error?
function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then
    return
  end

  -- TODO: use something better that can get all images inside the epub
  local output, err = Command('gnome-epub-thumbnailer'):arg({
    '-s',
    '0',
    tostring(job.file.url),
    tostring(cache),
  }):output()

  if not output then
    return Err('Failed to start `gnome-epub-thumbnailer`: %s', err)
  elseif not output.status.success then
    return Err('stderr: %s', output.stderr)
  end
end

return M
