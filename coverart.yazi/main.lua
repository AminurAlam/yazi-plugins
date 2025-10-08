local M = {}

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then return end

  local ok, err = self:preload(job)
  if not ok or err then return ya.preview_widget(job, err) end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err)
  -- local output = Command('mediainfo')
  --   :arg({
  --     tostring(job.file.name),
  --     ''
  --       .. [[--Output=General;%Performer% - %Track%\nAlbum: %Album%\n]]
  --       .. [[\nGenre: %Genre%\nReleased: %Recorded_Date%]],
  --   })
  --   :stdout(Command.PIPED)
  --   :output().stdout .. Command('mediainfo')
  --   :arg({
  --     tostring(job.file.name),
  --     [[--Output=Image;\nCover: %Format% %Width%x%Height% %StreamSize/String1%]],
  --   })
  --   :stdout(Command.PIPED)
  --   :output().stdout
  -- ya.preview_widgets(job, { ui.Text.parse(output):area(job.area) })
end

function M:seek(job) end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache then return true end

  local cha = fs.cha(cache)
  if cha and cha.len > 0 then return true end

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
