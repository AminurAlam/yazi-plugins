--- @since 25.12.29

local M = {}

-- TODO: implement cache
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

    data = {
      ui.Line(string.format('%s - %s', artist, title)),
      ui.Line(string.format('%s: %s', 'Album', album)),
      ui.Line(string.format('%s: %s', 'Genre', tags.GENRE or tags.genre)),
      ui.Line(string.format('%s: %s', 'Date', date)),
      c ~= '' and ui.Line(string.format('%s: %s', 'Cover art', c)) or nil,
    }
  end

  local br = tonumber((json.format.bit_rate or 0) // 1000) .. ' kb/s'
  table.insert(data, ui.Line(string.format('%s: %s', 'Format', json.format.format_name)))
  table.insert(data, ui.Line(string.format('%s: %s', 'BitRate', br)))
  table.insert(data, ui.Line(string.format('%s: %s', 'Channels', tostring(stream.channels or '?'))))

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
