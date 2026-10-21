local M = {}

-- TODO: dedupe remotes
-- TODO: show all branches
-- TODO: show all stash
function M:peek(job)
  local color = { '-c', 'color.ui=always' }
  local rmt = Command('git'):arg({ 'remote', '-v' }):output()
  local sts = Command('git'):arg(color):arg({ '--no-optional-locks', 'status', '-bs' }):output()
  local log = Command('git')
    :arg(color)
    :arg({ 'log', '--graph', '--format=%C(auto)%h %s %C(magenta)(%cr)%C(auto)%d', '-n15' })
    :output()

  local text = ''
    .. 'Remotes:\n'
    .. (rmt and rmt.stdout:gsub('\t', ' '))
    .. '\n'
    .. (sts and sts.stdout ~= '' and ('Status: ' .. sts.stdout) or '')
    .. '\n'
    .. 'Log:\n'
    .. (log and log.stdout)

  ya.preview_widget(job, ui.Text.parse(text):area(job.area))
end

function M:seek() end

---@param mu { mimes: string[], urls: string[] }
function M:setup(mu)
  mu = mu or { mimes = {}, urls = { '**/.git/' } }
  for _, mime in ipairs(mu.mimes or {}) do
    rt.plugin.previewers:insert(1, { mime = mime, run = 'preview-git' })
  end
  for _, url in ipairs(mu.urls or {}) do
    rt.plugin.previewers:insert(1, { url = url, run = 'preview-git' })
  end
end

return M
