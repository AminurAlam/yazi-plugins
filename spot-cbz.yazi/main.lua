local M = {}

local comicinfo = function(file)
  local ci = { title = 'ComicInfo' }
  local cout = Command('unzip'):arg({ '-p', file.name, 'ComicInfo.xml' }):output()

  if cout and cout.status.code == 11 then
    cout = Command('unzip'):arg({ '-p', file.name, '1/ComicInfo.xml' }):output()
  end
  if not cout then
    return
  end
  if cout and cout.status.code == 11 then
    return
  end

  local text = cout and cout.stdout

  for i, tag in ipairs({ 'Title', 'Series', 'Writer', 'Penciller', 'Genre' }) do
    local start, finish = string.find(text, string.format('<%s>.*</%s>', tag, tag))
    ci[i] = (start and finish) and { tag, string.sub(text, start + #tag + 2, finish - #tag - 3) }
      or { tag, '' }
  end

  return ci
end

function M:spot(job)
  return require('spot'):spot(job, { comicinfo(job.file) })
end

return M
