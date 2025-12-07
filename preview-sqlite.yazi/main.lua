local M = {}

function M:peek(job)
  local output, err = Command('sqlite3'):arg({
    tostring(job.file.url),
    '.schema --indent',
  }):output()

  if output.status.success and output.stdout then
    ya.preview_widgets(job, { ui.Text(output.stdout):area(job.area) })
  end
end

function M:seek(job) end

return M
