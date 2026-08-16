local M = {}

---@param job Job
function M:peek(job)
  local parent = tostring(job.file.url.parent.name)
  if parent:match('%.wants$') then
    parent = tostring(job.file.url.parent.parent.name)
  end
  ya.dbg(parent)

  local output, err = Command('systemctl'):arg({
    '--' .. parent,
    'status',
    '--no-pager',
    '-n30',
    '-o',
    'cat',
    tostring(job.file.name),
  }):output()

  local text = ''
  if err then
    text = string.format('Failed to start `systemctl`: %s', err)
  elseif not output then
    text = string.format('Failed to start `systemctl`: %s', err)
  else
    text = output.stdout
  end
  ya.preview_widget(job, ui.Text.parse(text):area(job.area))
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
