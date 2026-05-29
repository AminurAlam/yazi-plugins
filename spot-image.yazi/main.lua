local M = {}

---@param job Job
---@return Sections?
---@return integer?
local image_exif = function(job)
  local output, err = Command('exiv2'):arg({ '-PElt', tostring(job.file.url) }):output()

  if not output or err then
    ya.err('Failed to start `exiv2`: ', tostring(err))
    return
  elseif not output.status.success then
    ya.err(output.stderr)
    return
  elseif output.stdout == '' then
    return
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

  return data, key_len
end

---@param job Job
function M:spot(job)
  local sections = {}
  local info = ya.image_info(job.file.url)
  local exif, key_len = image_exif(job)

  if info then
    sections[#sections + 1] = {
      title = 'Image',
      { 'Format', tostring(info.format) },
      { 'Size', string.format('%dx%d', info.w, info.h) },
      { 'Color', tostring(info.color) },
    }
  end
  if exif then
    sections[#sections + 1] = exif
  end

  require('spot'):spot(job, sections, {
    style = {
      key_length = key_len and ya.clamp(0, key_len, 25),
    },
  })
end

return M
