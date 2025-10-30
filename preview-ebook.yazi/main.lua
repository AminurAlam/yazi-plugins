local M = {}

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then return end

  local ok, err = self:preload(job)
  if not ok or err then return end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err and ui.Text(err):area(job.area):wrap(ui.Wrap.YES))
end

function M:seek(job) end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then return true end

  local output, err = Command('gnome-epub-thumbnailer'):arg({
    '-s',
    '0',
    tostring(job.file.url),
    tostring(cache),
  }):output()

  if not output then
    return true, Err('Failed to start `gnome-epub-thumbnailer`, error: %s', err)
  elseif not output.status.success then
    return true, Err('Failed to get image, stderr: %s', output.stderr)
  end

  return true
end

return M
