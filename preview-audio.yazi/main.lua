--- @since 25.12.29

local M = {}

---@param lines string[]
---@param key string
---@param value string
local function add_line(lines, key, value)
  if value and value ~= '' then
    table.insert(lines, string.format('%s: %s', key, value))
  end
end

---@param value any
---@return string
local function join_tag(value)
  if type(value) == 'table' then
    return table.concat(value, ' / ')
  end
  return value or ''
end

---@param ... any
---@return any
local function first(...)
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    if v ~= nil and v ~= '' then
      return v
    end
  end
end

---@param file File
---@return ui.Line[]
local audio_exiftool = function(file)
  local output, err = Command('exiftool'):arg({
    '-j',
    '-a',
    '-s',
    file.name,
  }):output()

  if not output or err then
    return { Err('Failed to start `exiftool`, error: %s', err) }
  end

  local json = ya.json_decode(output.stdout)
  if not json then
    return { Err('Failed to decode `exiftool` output: %s', output.stdout) }
  elseif type(json) ~= 'table' then
    return { Err('Invalid `exiftool` output: %s', output.stdout) }
  end
  -- ya.dbg(json)

  local tags = json[1] or {}

  local data = {} ---@type string[]
  local artist = join_tag(tags.Artist)
  local title = tags.Title
  local album = tags.Album
  local genre = join_tag(tags.Genre)
  -- TODO: uniq instead of first
  local date = first(tags.Originaldate, tags.Date, tags.DateTimeOriginal, tags.CreateDate)
  local duration = tags.Duration
  local cover = tags.PictureType or ''
  if tags.PictureWidth and tags.PictureHeight then
    cover = string.format('%s %sx%s', cover, tags.PictureWidth, tags.PictureHeight)
  end

  table.insert(data, artist .. ' - ' .. title)
  add_line(data, 'Album', album)
  add_line(data, 'Genre', genre)
  add_line(data, 'Duration', duration)
  add_line(data, 'Date', date)
  add_line(data, 'Cover', cover)

  local sr = first(tags.AudioSampleRate, tags.SampleRate)
  local bd = first(tags.AudioBitsPerSample, tags.BitsPerSample)
  if sr then
    sr = string.format('%.1f kHz', tonumber(sr) / 1000)
  end

  table.insert(data, '')
  table.insert(data, '# spec')
  add_line(data, 'Format', first(tags.AudioFormat, tags.FileType))
  add_line(data, 'Sample Rate', sr)
  add_line(data, 'Bit Depth', (bd and (bd .. ' bit')))
  add_line(data, 'BitRate', first(tags.AvgBitrate, tags.AudioBitrate))
  add_line(data, 'Channels', first(tags.AudioChannels, tags.ChannelMode, tags.Channels))

  -- ya.dbg(data)
  return data
end

---@param job Job
function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end

  local err = self:preload(job)
  if err then
    ya.dbg(tostring(err)) -- TODO: fix random Failed to rename error
  end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
  local img_area, err = ya.image_show(cache, job.area)
  if err then
    -- ya.preview_widget(job, err) -- ignore because we have more stuff to print
    -- return
  end

  local img_height = (img_area and img_area.h or 0)

  ya.preview_widget(job, {
    ---@diagnostic disable-next-line: assign-type-mismatch
    ui.Text(audio_exiftool(job.file)):area(ui.Rect {
      x = job.area.x,
      y = job.area.y + img_height,
      w = job.area.w,
      h = job.area.h - img_height,
    }),
  })
end

function M:seek() end

---@param job Job
---@return Error?
function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache then
    return
  end

  local cha = fs.cha(cache)
  if cha and cha.len > 0 then
    return
  end

  -- stylua: ignore
  local output, err = Command('ffmpeg')
      :arg({
        '-hide_banner',
        '-loglevel', 'warning',
        '-i', tostring(job.file.url),
        '-frames:v', '1',
        '-an',
        -- '-vcodec', 'copy',
        string.format('%s.jpg', cache),
      })
      :stderr(Command.PIPED)
      :output()

  if not output then
    return Err('Failed to start `ffmpeg`, error: %s', err)
  elseif not output.status.success then
    return Err('Failed to get image, stderr: %s', output.stderr)
  end

  local ok, err = fs.rename(Url(string.format('%s.jpg', cache)), cache)
  if ok then
    return
  else
    return Err('Failed to rename: %s', err)
  end
end

return M
