local M = {}

-- TODO: cache json

---@param job Job
---@return Sections
---@return integer?
local image_info = function(job)
  -- TODO: replace with exiv2
  local output, err = Command('exiv2'):arg({ '-PElt', tostring(job.file.url) }):output()

  if not output or err then
    ya.err('Failed to start `exiv2`: ', tostring(err))
    return {}
  elseif not output.status.success then
    ya.err(output.stderr)
    return {}
  elseif output.stdout == '' then
    return {}
  end

  local data, key_len = { title = 'EXIF' }, 0
  for line in output.stdout:gmatch('[^\n]+') do
    local s, e = line:find(' %s+')
    if not s or not e then
      goto continue
    end
    if s > key_len then
      key_len = s
    end
    data[#data + 1] = { line:sub(0, s - 1), line:sub(e + 1, #line) }
    ::continue::
  end

  return { data }, key_len
end

---@param job Job
function M:spot(job)
  local sections, key_len = image_info(job) ---@type Sections
  local opts
  if key_len and key_len > 0 then
    opts = { style = { key_length = ya.clamp(0, key_len, 25) } }
    ya.dbg('key_len', key_len)
  end
  require('spot'):spot(job, sections, opts)
end

return M
