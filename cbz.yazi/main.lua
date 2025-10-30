local M = {}

local comicinfo = function(file)
  local ci = { title = 'ComicInfo' }
  local cout = Command('unzip'):arg({ '-p', file.name, 'ComicInfo.xml' }):output()

  if cout and cout.status.code == 11 then
    cout = Command('unzip'):arg({ '-p', file.name, '1/ComicInfo.xml' }):output()
  end
  if not cout then return end
  if cout and cout.status.code == 11 then return end

  local text = cout and cout.stdout

  for i, tag in ipairs({ 'Title', 'Series', 'Writer', 'Penciller', 'Genre' }) do
    local start, finish = string.find(text, string.format('<%s>.*</%s>', tag, tag))
    ci[i] = (start and finish) and { tag, string.sub(text, start + #tag + 2, finish - #tag - 3) }
      or { tag, '' }
  end

  return ci
end

local zipinfo = function(file)
  local zi = { title = 'ZipInfo' }
  local zout = Command('zipinfo'):arg({ '-h', file.name }):output()

  if zout and zout.stdout then
    zi[1] = { '', string.gsub(zout and zout.stdout or '', '.*, number of entries: ', '') or '' }
  end

  return zi
end

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then return end

  local ok, err = self:preload(job)
  if not ok or err then return end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err and ui.Text(err):area(job.area):wrap(ui.Wrap.YES))
end

function M:seek(job)
  local h = cx.active.current.hovered
  if h and h.url == job.file.url then
    ya.emit('peek', {
      math.max(0, cx.active.preview.skip + ya.clamp(-1, job.units, 1)),
      only_if = job.file.url,
    })
  end
end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then return true end

  local output, err = Command('cbzcover')
    :arg({
      tostring(job.file.url),
      tostring(cache),
      job.skip + 1,
    })
    :stdout(Command.PIPED)
    :output()

  if not output then
    return true, Err('Failed to start `cbzcover`, error: %s', err)
  elseif not output.status.success then
    local max_pages = tonumber(output.stdout) or 0
    if job.skip > 0 and max_pages > 0 then
      ya.emit('peek', { max_pages - 1, only_if = job.file.url, upper_bound = true })
    end
    return true, Err('Failed to get image, stderr: %s', output.stdout)
  end

  return true
end

function M:spot(job) return require('spot'):spot(job, { comicinfo(job.file) }) end

return M
