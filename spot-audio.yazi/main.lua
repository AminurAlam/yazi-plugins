local M = {}

---@param section Section
---@param label string
---@param value any
local function add_field(section, label, value)
  if value ~= nil and value ~= '' then
    table.insert(section, { label, tostring(value) })
  end
end

---@param data Sections
---@param section Section
local function add_section(data, section)
  if #section > 0 then
    table.insert(data, section)
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
---@return Sections
---@return Error?
local audio_exiftool = function(file)
  local output, err = Command('exiftool'):arg({
    '-j',
    '-a',
    '-s',
    file.name,
  }):output()

  if not output or err then
    return {}, Err('Failed to start `exiftool`, error: %s', err)
  end

  local json = ya.json_decode(output.stdout)
  if not json then
    return {}, Err('Failed to decode `exiftool` output: %s', output.stdout)
  elseif type(json) ~= 'table' then
    return {}, Err('Invalid `exiftool` output: %s', output.stdout)
  end
  -- ya.dbg(json)

  local data = {} ---@type Sections
  local tags = json[1] or {}

  local gen_sec = { title = 'General' } ---@type Section
  local artist = join_tag(tags.Artist)
  local title = tags.Title
  local album = tags.Album
  local genre = join_tag(tags.Genre)
  local date = first(tags.Originaldate, tags.Date, tags.DateTimeOriginal, tags.CreateDate)
  local duration = tags.Duration
  local cover = tags.PictureType or ''
  if tags.PictureWidth and tags.PictureHeight then
    cover = string.format('%s %sx%s', cover, tags.PictureWidth, tags.PictureHeight)
  end

  add_field(gen_sec, 'Title', title)
  add_field(gen_sec, 'Artist', artist)
  add_field(gen_sec, 'Album', album)
  add_field(gen_sec, 'Genre', genre)
  add_field(gen_sec, 'Duration', duration)
  add_field(gen_sec, 'Date', date)
  add_field(gen_sec, 'Cover', cover)

  local audio_sec = { title = 'Audio' } ---@type Section
  local sr = first(tags.AudioSampleRate, tags.SampleRate)
  local bd = first(tags.AudioBitsPerSample, tags.BitsPerSample)
  if sr then
    sr = string.format('%.1f kHz', tonumber(sr) / 1000)
  end

  add_field(audio_sec, 'Format', first(tags.AudioFormat, tags.FileType))
  add_field(audio_sec, 'Sample Rate', sr)
  add_field(audio_sec, 'Bit Depth', (bd and (bd .. ' bit')))
  add_field(audio_sec, 'BitRate', first(tags.AvgBitrate, tags.AudioBitrate))
  add_field(audio_sec, 'Channels', first(tags.AudioChannels, tags.ChannelMode, tags.Channels))

  add_section(data, gen_sec)
  add_section(data, audio_sec)

  -- ya.dbg(data)
  return data
end

---@param job Job
function M:spot(job)
  local sections, err = audio_exiftool(job.file)
  if not sections or err then
    ya.dbg(err)
  end

  require('spot'):spot(job, sections)
end

return M
