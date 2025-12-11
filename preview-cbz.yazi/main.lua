local M = {}

---@param job Job
---@return false|number
---@return Error|string
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
    return false, Err('Filename does not match cbz/zip/cbr/rar')
  end

  if not child or err then
    return false, Err('zipinfo/unrar: %s', err)
  end

  stdout = child:take_stdout()
  if not stdout then
    return false, Err('No output from zipinfo/unrar')
  end

  child, err = Command('grep')
    :arg({ '-E', [[\.(png|jpg|jpeg|jxl|webp)$]] })
    :stdin(stdout)
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child or err then
    return false, Err('grep: %s', err)
  end

  stdout = child:take_stdout()
  if not stdout then
    return false, Err('No output from grep')
  end

  -- stylua: ignore
  child, err = Command('sort')
    :arg({ '-n' })
    :stdin(stdout)
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child or err then
    return false, Err('sort: %s', err)
  end

  local i, file, event = 0, '', 0
  while i <= job.skip do
    file, event = child:read_line()

    if i == job.skip then
      child:start_kill()
      return job.skip, file
    elseif event == 2 then
      child:start_kill()
      return false, Err('hit end')
    end
    i = i + 1
  end
  return false, Err('output finished without reaching job.skip')
end

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end

  local err_or_bound = self:preload(job)
  if type(err_or_bound) == 'Error' then
    return ya.preview_widget(job, ui.Text(tostring(err_or_bound)):area(job.area))
  elseif type(err_or_bound) == 'number' then
    ya.dbg(err_or_bound)
    ya.emit('peek', { tonumber(err_or_bound) - 2, only_if = job.file.url, upper_bound = true })
    return false
  end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  local _, err = ya.image_show(cache, job.area)
  if err then
    ya.preview_widget(job, ui.Text(tostring(err)):area(job.area))
  end
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

---@param job Job
---@return number|Error?
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

  local found, file_or_err = get_file(job)

  if found and not file_or_err then
    return found
  elseif found and file_or_err and type(file_or_err) ~= 'Error' then
    local file = tostring(file_or_err)
    ya.dbg(file)
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
  elseif type(file_or_err) == 'Error' then
    return Err('error when running get_file(): %s', file_or_err)
  end
end

return M
