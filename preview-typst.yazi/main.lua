local M = {}

---@param job Job
function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end

  local err, bound = self:preload(job)
  if bound and bound > 0 then
    ya.emit('peek', { bound - 1, only_if = job.file.url, upper_bound = true })
    return
  elseif err then
    ya.preview_widget(job, err)
    return
  end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  ---@diagnostic disable-next-line: redefined-local
  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err)
end

function M:seek(job)
  local h = cx.active.current.hovered
  if h and h.url == job.file.url then
    local step = ya.clamp(-1, job.units, 1)
    ya.emit('peek', { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
  end
end

---@param job Job
---@return Error?
---@return integer?
function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then
    return
  end

  if job.skip == -1 then
    return nil, 0
  end

  local output, err = Command('typst'):arg({
    'compile',
    '-f',
    'png',
    '--pages',
    tostring(job.skip + 1),
    tostring(job.file.url),
    tostring(cache),
  }):output()

  if not output or err then
    return Err('Failed to start `typst`: %s', err)
  elseif not output.status.success then
    return Err(output.stderr)
  end

  if job.skip > 0 and not fs.cha(cache) then
    return Err('command did not create any file'), job.skip
  end
end

return M
