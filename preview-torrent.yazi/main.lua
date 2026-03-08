local M = {}

-- TODO: turn the fish script into lua script

---@param job Job
function M:peek(job)
  local output, err = Command('torrent-list'):arg({ tostring(job.file.url) }):output()

  if not output or err then
    ya.preview_widget(job, Err(err))
  elseif not output.status.success then
    ya.preview_widget(job, { ui.Text(output.stderr):area(job.area) })
  else
    ya.preview_widget(job, { ui.Text(output.stdout):area(job.area) })
  end
end

function M:seek() end

return M
