--- @since 25.12.29

local M = {}

function M:peek(job)
  local output, err = Command('sqlite3'):arg({
    tostring(job.file.url),
    '.schema --indent',
  }):output()

  local out
  if not output then
    out = Err('Failed to start `sqlite`: %s', err)
  elseif not output.status.success then
    out = Err('stderr: %s', output.stderr)
  else
    out = {}
    local skip = job.skip
    for i in string.gmatch(output.stdout, '[^\n]+') do
      if skip < 1 then
        out[#out + 1] = i
      else
        skip = skip - 1
      end
      if #out > job.area.h then
        break
      end
    end
    if #out < job.area.h then
      ya.emit('peek', { job.skip - 1, only_if = job.file.url, upper_bound = true })
    end
  end
  ya.preview_widget(job, ui.List(out):area(job.area))
end

function M:seek(job)
  local h = cx.active.current.hovered
  if not h or h.url ~= job.file.url then
    return
  end

  local step = math.floor(job.units * job.area.h / 25)
  step = step == 0 and ya.clamp(-1, job.units, 1) or step

  ya.emit('peek', {
    math.max(0, cx.active.preview.skip + step),
    only_if = job.file.url,
  })
end

return M
