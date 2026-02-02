local M = {}

-- TODO: cache json

---@param job Job
---@return Sections
local image_info = function(job)
  local output, err = Command('magick'):arg({ tostring(job.file.url), 'json:' }):output()

  if not output or err then
    ya.err('Failed to start `magick`: ', tostring(err))
    return {}
  elseif not output.status.success then
    ya.err(output.stderr)
    return {}
  end

  local t = ya.json_decode(output.stdout)
  if not t or type(t) ~= 'table' then
    ya.err('Bad `magick` output:', output.stdout)
    return {}
  end

  local img = t[1].image
  local properties = img.properties ---@type table<string, string>

  -- BASIC DATA

  local data = { title = 'Image' } ---@type Section

  if img.geometry then
    data[#data + 1] = { 'geometry', img.geometry.width .. 'x' .. img.geometry.height }
  end

  if properties and properties.Software then
    data[#data + 1] = { 'Software', tostring(properties.Software) }
  end

  for _, property in ipairs({
    'format',
    'depth',
    -- 'elapsedTime',
    'colorspace',
    -- 'gamma',
    'numberPixels',
  }) do
    if img[property] then
      data[#data + 1] = { property, tostring(img[property]) }
    end
  end

  if not img.properties then
    return { data }
  end

  -- EXIF

  local exif = { title = 'EXIF' } ---@type Section

  for key, value in pairs(properties) do
    --  TODO: add filter
    if not string.match(key, '^exif:.+') then
      goto continue
    end
    exif[#exif + 1] = { string.sub(key, 6, #key), tostring(value) }
    ::continue::
  end

  ya.dbg(#exif, exif)

  if #exif == 0 then
    return { data }
  else
    return { data, exif }
  end
end

---@param job Job
function M:spot(job)
  local sections = image_info(job) ---@type Sections
  local opts
  if #sections == 2 then
    opts = { style = { key_length = 25 } }
  end
  require('spot'):spot(job, sections, opts)
end

return M
