--- @since 25.12.29

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
    return {}, Err('Failed to start `ffprobe`, error: %s', err)
  end

  local json = ya.json_decode(output.stdout)
  if not json then
    return nil, Err('Failed to decode `ffprobe` output: %s', output.stdout)
  elseif type(json) ~= 'table' then
    return nil, Err('Invalid `ffprobe` output: %s', output.stdout)
  end
  ya.dbg(json)

  local audio_stream = json.streams[1]
  local tags = json.format.tags or audio_stream.tags or audio_stream
  local duration = json.format.duration
  if duration then
    duration = tonumber(duration)
    duration = string.format('%d:%02d', math.floor(duration / 60), math.floor(duration % 60))
  end

  local data = {}
  local title, album, aar, ar =
    tags.TITLE or tags.title or '',
    tags.ALBUM or tags.album or '',
    tags.ALBUM_ARTIST or tags.album_artist or '',
    tags.ARTIST or tags.artist or ''

  if title .. album .. ar .. aar ~= '' then
    local img_stream = json.streams[2]
    local date = tags.DATE or tags.date or ''
    local c = ''
    local artist = ar

    if tags.ORIGINALDATE and tags.ORIGINALDATE ~= '' then
      date = date .. ' / ' .. tags.ORIGINALDATE
    end
    if (aar ~= '') and (aar ~= ar) then
      artist = artist .. ' / ' .. aar
    end
    if img_stream then
      c = img_stream.codec_name .. ' ' .. img_stream.width .. 'x' .. img_stream.height
    end

    data = {
      ui.Line(string.format('%s - %s', artist, title)),
      ui.Line(string.format('%s: %s', 'Duration', duration)),
      ui.Line(string.format('%s: %s', 'Album', album)),
      ui.Line(string.format('%s: %s', 'Genre', tags.GENRE or tags.genre or 'No genre')),
      ui.Line(string.format('%s: %s', 'Date', date)),
      c ~= '' and ui.Line(string.format('%s: %s', 'Cover art', c)) or nil,
    }
  end

  local bd = audio_stream.bits_per_raw_sample or '1'
  local sr = audio_stream.sample_rate
  if sr then
    sr = string.format('%.1fkhz', sr / 1000)
  end
  local br = tonumber((audio_stream.bit_rate or json.format.bit_rate or 0) // 1000) .. ' kb/s'
  ya.dbg(bd, sr)
  for _, item in ipairs({
    '',
    '# Specs',
    string.format('%s: %s', 'Format', json.format.format_name),
    string.format('%s: %sbit / %s', 'Quality', bd, sr),
    string.format('%s: %s', 'BitRate', br),
    string.format('%s: %s', 'Channels', tostring(audio_stream.channels or '?')),
  }) do
    data[#data + 1] = ui.Line(item)
  end

  return data
end

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  local ok, err = self:preload(job)

  local img_area
  if cache and fs.cha(cache) then
    ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))
    img_area, err = ya.image_show(cache, job.area)
  end

  ya.preview_widget(job, {
    ui.Text(audio_ffprobe(job.file)):area(ui.Rect {
      x = job.area.x,
      y = job.area.y + (img_area and img_area.h or 0),
      w = job.area.w,
      h = job.area.h,
    }),
  })
end

function M:seek(job) end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache then
    return true
  end

  local cha = fs.cha(cache)
  if cha and cha.len > 0 then
    return true
  end

  -- stylua: ignore
  local output, err = Command('ffmpeg')
    :arg({
      '-hide_banner',
      '-loglevel', 'warning',
      '-i', tostring(job.file.url),
      '-an',
      -- '-vcodec', 'copy',
      string.format('%s.jpg', cache),
    })
    :stderr(Command.PIPED)
    :output()

  if not output then
    return true, Err('Failed to start `ffmpeg`, error: %s', err)
  elseif not output.status.success then
    return true, Err('Failed to get image, stderr: %s', output.stderr)
  end

  local ok, err = os.rename(string.format('%s.jpg', cache), tostring(cache))
  if ok then
    return true
  else
    return true, Err('Failed to rename: %s', err)
  end
end

return M
