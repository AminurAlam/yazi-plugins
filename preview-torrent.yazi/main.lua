local M = {}

-- TODO: scroll text
-- TODO: pretty print text

---@param job Job
function M:peek(job)
  local child, err = Command('aria2c')
    :arg({ '-S', tostring(job.file.path) })
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()

  if not child then
    ya.preview_widget(job, ui.List({ Err('Failed to start `aria2c`: %s', err) }):area(job.area))
    return
  end

  local skip, h, out = job.skip, job.area.h, {}
  -- local fin
  for _ = 1, skip do
    child:read_line()
  end
  for _ = 1, h do
    local line, event = child:read_line()
    if not line or event ~= 0 then
      -- fin = true
      break
    end
    out[#out + 1] = line
  end
  -- ya.dbg(skip, fin, #out - h)
  ya.preview_widget(job, ui.List(out):area(job.area))
end

function M:seek(job)
  local h = cx.active.current.hovered
  if not h or h.url ~= job.file.url then
    return
  end

  local step = math.floor(job.units * job.area.h / 15)
  step = step == 0 and ya.clamp(-1, job.units, 1) or step

  ya.emit('peek', {
    math.max(0, cx.active.preview.skip + step),
    only_if = job.file.url,
    tab = job.tab,
  })
end

---@param mu { mimes: string[], urls: string[] }
function M:setup(mu)
  mu = mu or { mimes = { 'application/bittorrent' }, urls = {} }
  for _, mime in ipairs(mu.mimes or {}) do
    rt.plugin.previewers:insert(1, { mime = mime, run = 'preview-torrent' })
  end
  for _, url in ipairs(mu.urls or {}) do
    rt.plugin.previewers:insert(1, { url = url, run = 'preview-torrent' })
  end
end

return M
