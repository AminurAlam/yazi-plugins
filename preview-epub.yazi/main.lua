local M = {}

-- Backend availability, checked once per session.
local ok = {}
local check_exists = function(bin) return Command(bin):arg('-V'):output() ~= nil end

--- Extract cover with gnome-epub-thumbnailer.
--- @param job Job @param cache Url @return Error?
function M:_gnome(job, cache)
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

--- Extract cover with Calibre's ebook-meta.
--- @param job Job @param cache Url @return Error?
function M:_calibre(job, cache)
  local output, err = Command('ebook-meta'):arg({
    '--get-cover',
    tostring(cache),
    tostring(job.file.url),
  }):output()

  if not output then
    return Err('Failed to start `ebook-meta`: %s', err)
  elseif not output.status.success then
    return Err('stderr: %s', output.stderr)
  end
end

--- @param job Job
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
  for _, spec in ipairs({
    { 'gnome',   'gnome-epub-thumbnailer', '_gnome' },
    { 'calibre', 'ebook-meta',             '_calibre' },
  }) do
    local name, bin, method = spec[1], spec[2], spec[3]
    if ok[name] == nil then ok[name] = check_exists(bin) end
    if ok[name] then
      return self[method](self, job, cache)
    end
  end

  return Err('No epub thumbnailer found. Install either `gnome-epub-thumbnailer` or Calibre (`ebook-meta`).')
end

return M
