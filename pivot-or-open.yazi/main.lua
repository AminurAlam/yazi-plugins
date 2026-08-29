--- @since 26.8.15
---@sync entry

local M = {}

---@param job Job
function M:entry(job)
  local v = cx.active.mode.visual
  ya.dbg(cx.active.name)
  if v then
    local c = cx.active.current
    ya.emit('visual_arrow', { math.min(v.start, #c.files - 1) - c.cursor - v.wraps * #c.files })
  else
    ya.emit('open', { interactive = true })
  end
end

return M
