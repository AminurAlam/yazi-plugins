local M = {}

local audio_ffprobe = function(file)
  -- stylua: ignore
  local cmd = Command('ffprobe'):arg {
    '-v', 'quiet',
    '-show_entries', 'stream_tags:format:stream',
    '-of', 'json=c=1',
    file.name
  }

  local output, err = cmd:output()
  if not output then
    return audio_mediainfo(file), Err('Failed to start `ffprobe`, error: %s', err)
  end

  local json = ya.json_decode(output.stdout)
  if not json then
    return nil, Err('Failed to decode `ffprobe` output: %s', output.stdout)
  elseif type(json) ~= 'table' then
    return nil, Err('Invalid `ffprobe` output: %s', output.stdout)
  end
  ya.dbg(json)

  local stream = json.streams[1]
  local tags = json.format.tags or stream.tags or stream

  local data = {}
  local title, album, aar, ar =
    tags.TITLE or tags.title or '',
    tags.ALBUM or tags.album or '',
    tags.ALBUM_ARTIST or tags.album_artist or '',
    tags.ARTIST or tags.artist or ''

  if title .. album .. ar .. aar ~= '' then
    local cdata = json.streams[2]
    local date = tags.DATE or tags.date or ''
    local c = ''
    local artist = ar

    if tags.ORIGINALDATE and tags.ORIGINALDATE ~= '' then
      date = date .. ' / ' .. tags.ORIGINALDATE
    end
    if (aar ~= '') and (aar ~= ar) then
      artist = artist .. ' / ' .. aar
    end
    if cdata then
      c = cdata.codec_name .. ' ' .. cdata.width .. 'x' .. cdata.height
    end

    data[#data + 1] = {
      title = 'General',
      { 'Title', title },
      { 'Album', album },
      { 'Artist', artist },
      { 'Genre', tags.GENRE or tags.genre },
      { 'Date', date },
      c ~= '' and { 'Cover art', c } or nil,
    }
  end

  data[#data + 1] = {
    title = 'Audio',
    { 'Format', json.format.format_name },
    { 'BitRate', tonumber((json.format.bit_rate or 0) // 1000) .. ' kb/s' },
    { 'Channels', tostring(json.format.nb_streams) },
  }

  ya.dbg(data)
  return data
end

local audio_mediainfo = function(file)
  local cmd = Command('mediainfo'):arg { '--Output=JSON', file.name }

  local output, err = cmd:output()
  if not output then
    return nil, Err('Failed to start `mediainfo`, error: %s', err)
  end

  local json = ya.json_decode(output.stdout)
  if not json then
    return nil, Err('Failed to decode `mediainfo` output: %s', output.stdout)
  elseif type(json) ~= 'table' then
    return nil, Err('Invalid `mediainfo` output: %s', output.stdout)
  end
  ya.dbg(json)

  local data = {}
  local general = json.media.track[1]
  local audio = json.media.track[2]
  local image = json.media.track[3]
  local title, album, aar, ar =
    general.Title or '', general.Album or '', general.Album_Performer or '', general.Performer or ''

  if title .. album .. ar .. aar ~= '' then
    local csize = ''
    local date = general.Recorded_Date
    local artist = ar

    if general.extra and general.extra.ORIGINALDATE then
      date = date .. ' / ' .. general.extra.ORIGINALDATE
    end
    if (aar ~= '') and (aar ~= ar) then
      artist = artist .. ' / ' .. aar
    end
    if image then
      csize = image.Format .. ' ' .. image.Height .. 'x' .. image.Width
    end

    data[#data + 1] = {
      title = 'General',
      { 'Title', title },
      { 'Album', album },
      { 'Artist', ar .. (aar ~= ar and (' / ' .. aar) or '') },
      { 'Genre', general.Genre },
      { 'Date', date },
      csize ~= '' and { 'Cover art', csize } or nil,
    }
  end

  local br = tonumber((audio.BitRate or 0) // 1000) .. ' kb/s'
  local sr = tonumber((audio.SamplingRate or 0) / 1000)
  data[#data + 1] = {
    title = 'Audio',
    { 'Format', audio.Format .. ' ' .. audio.Compression_Mode },
    { 'Quality', (audio.BitDepth or '1') .. '/' .. sr },
    { 'BitRate', br },
    { 'Channels', audio.Channels .. ' ' .. (audio.ChannelLayout or '') },
    -- { 'Duration', audio.Duration },
  }

  ya.dbg(data)

  return data
end

function M:spot(job)
  require('spot'):spot(job, audio_ffprobe(job.file))
end

return M
