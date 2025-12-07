local M = {}

-- TODO: colorized outpt
function M:peek(job)
  local ori = Command('git'):arg({ 'remote', 'get-url', 'origin' }):output()
  local ups = Command('git'):arg({ 'remote', 'get-url', 'upstream' }):output()
  local sts = Command('git'):arg({ '--no-optional-locks', 'status', '-bs' }):output()
  local log = Command('git'):arg({ 'log', '--format=%s', '-n15' }):output()

  local text = ''
    .. (ori and ori.stdout ~= '' and ('origin: ' .. ori.stdout) or '')
    .. (ups and ups.stdout ~= '' and ('upstream: ' .. ups.stdout) or '')
    .. '\n'
    .. (sts and sts.stdout)
    .. '\n'
    .. (log and log.stdout)

  ya.preview_widget(job, ui.Text.parse(text):area(job.area))
end

function M:seek() end

return M
