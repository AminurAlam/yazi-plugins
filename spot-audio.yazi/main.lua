local M = {}

---@param section Section
---@param key string
---@param value nil|string|table
local function add_field(section, key, value)
  if value == nil or value == '' or value == 'None' or value == 'Unknown' then
    return
  end

  if type(value) == 'table' then
    value = table.concat(value, ', ')
  end

  table.insert(section, { key, tostring(value) })
end

-- sep

---@param data Sections
---@param section Section
local function add_section(data, section)
  if #section > 0 then
    table.insert(data, section)
  end
end

---@param items table
---@return string?
local function first(items)
  for _, item in pairs(items) do
    if item ~= nil and item ~= '' then
      return item
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

  local tags = json[1] or {}
  local gen_sec = { title = 'General' } ---@type Section
  local artist = tags.Artist
  if type(artist) == 'table' then
    artist = table.concat(artist, ', ')
  end
  -- TODO: uniq instead of first
  local date = first({ tags.Originaldate, tags.Date, tags.DateTimeOriginal })
  local cover = tags.PictureType or ''
  if tags.PictureWidth and tags.PictureHeight then
    cover = string.format('%s %sx%s', cover, tags.PictureWidth, tags.PictureHeight)
  end

  add_field(gen_sec, 'Title', tags.Title)
  add_field(gen_sec, 'Artist', artist)
  add_field(gen_sec, 'Album', tags.Album)
  add_field(gen_sec, 'Genre', tags.Genre)
  add_field(gen_sec, 'Date', date)
  add_field(gen_sec, 'Cover', cover)

  local audio_sec = { title = 'Audio' } ---@type Section
  local sr = first({ tags.AudioSampleRate, tags.SampleRate })
  local bd = first({ tags.AudioBitsPerSample, tags.BitsPerSample })
  if sr then
    sr = string.format('%.1f kHz', tonumber(sr) / 1000)
  end

  add_field(audio_sec, 'Duration', tags.Duration)
  add_field(audio_sec, 'Format', first({ tags.AudioFormat, tags.FileType }))
  add_field(audio_sec, 'Sample Rate', sr)
  add_field(audio_sec, 'Bit Depth', (bd and (bd .. ' bit')))
  add_field(audio_sec, 'BitRate', first({ tags.AvgBitrate, tags.AudioBitrate }))
  add_field(audio_sec, 'Channels', first({ tags.AudioChannels, tags.ChannelMode, tags.Channels }))

  local data = {} ---@type Sections
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
