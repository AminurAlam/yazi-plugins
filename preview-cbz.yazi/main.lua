local M = {}

---@param job Job
---@return (Error|string)?
local get_file = function(job)
  local child, stdout, err

  if tostring(job.file.url):find('%.cbz$') or tostring(job.file.url):find('%.zip$') then
    child, err = Command('zipinfo')
      :arg({ '-1', tostring(job.file.url) })
      :stdout(Command.PIPED)
      :stderr(Command.PIPED)
      :spawn()
  elseif tostring(job.file.url):find('%.cbr$') or tostring(job.file.url):find('%.rar$') then
    child, err = Command('unrar')
      :arg({ 'lb', tostring(job.file.url) })
      :stdout(Command.PIPED)
      :stderr(Command.PIPED)
      :spawn()
  else
    return Err('Filename does not match cbz/zip/cbr/rar')
  end

  if not child or err then
    return Err('zipinfo/unrar: %s', err)
  end

  stdout = child:take_stdout()
  if not stdout then
    return Err('No output from zipinfo/unrar')
  end

  child, err = Command('grep')
    :arg({ '-E', [[\.(png|jpg|jpeg|jxl|webp)$]] })
    :stdin(stdout)
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child or err then
    return Err('grep: %s', err)
  end

  stdout = child:take_stdout()
  if not stdout then
    return Err('No output from grep')
  end

  -- stylua: ignore
  child, err = Command('sort')
    :arg({ '-V', '-f' })
    :stdin(stdout)
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child or err then
    return Err('sort: %s', err)
  end

  local i, event = 0, 0
  local file
  while i <= job.skip do
    file, event = child:read_line()

    if i == job.skip then
      child:start_kill()
      return file
    elseif event == 2 then
      child:start_kill()
      return
    end
    i = i + 1
  end
end

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

  local cbz = (tostring(job.file.url):find('%.cbz$') or tostring(job.file.url):find('%.zip$'))
      and true
    or false
  local cbr = (tostring(job.file.url):find('%.cbr$') or tostring(job.file.url):find('%.rar$'))
      and true
    or false

  local efb = get_file(job)
  ya.dbg('ebf', efb)

  if not efb then
    ya.dbg('  end?', efb)
    return Err('reached end of archive'), job.skip
  elseif type(efb) == 'Error' then
    ya.dbg('  err', efb)
    return efb
  elseif type(efb) == 'string' then
    -- elseif found and file_or_err and type(file_or_err) ~= 'Error' then
    local file = tostring(efb)
    ya.dbg('  string', file)
    local output, err, write
    if cbz then
      output, err = Command('unzip')
        :arg({
          '-p',
          tostring(job.file.url),
          file:sub(1, -2):gsub('%[', '\\['):gsub('%]', '\\]'):gsub('%*', '\\*'):gsub('%?', '\\?'),
        })
        :stdout(Command.PIPED)
        :output()
    elseif cbr then
      output, err = Command('unrar')
        :arg({ 'p', tostring(job.file.url), file:sub(1, -2) })
        :stdout(Command.PIPED)
        :output()
    end

    if not output or err then
      return Err('no image output when extracting: %s', err)
    end

    write, err = fs.write(cache, output.stdout)

    if not write then
      return Err('failed to write image to cache: %s', err)
    end

    return
  end
end

return M
