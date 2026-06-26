local M = {}

---@param section Section
---@param key string
---@param value string|table
local function add_field(section, key, value)
  if value == nil or value == '' or value == 'None' or value == 'Unknown' then
    return
  end
  if type(value) == 'table' then
    table.insert(section, { key, table.concat(value, ', ') })
  elseif type(value) == 'string' then
    table.insert(section, { key, value })
  end
end

---@param job Job
---@return Sections?
local image_exiftool = function(job)
  local output, err = Command('exiftool'):arg({ '-j', tostring(job.file.url) }):output()

  if not output or err then
    ya.err('Failed to start `exiftool`: ', tostring(err))
    return
  elseif not output.status.success then
    ya.err(output.stderr)
    return
  end

  local json = ya.json_decode(output.stdout)
  if not json then
    ya.err('Failed to decode `exiftool` output: ', output.stdout)
    return
  elseif type(json) ~= 'table' then
    ya.err('Invalid `exiftool` output: ', output.stdout)
    return
  end

  json = json[1]
  ya.dbg(json)

  local data = { title = 'EXIF' }
  local pinned_keys = {
    'FileType',
    'ImageSize',
    'CreateDate',
    'DateTimeOriginal',
    'ColorType',
    'ColorSpaceData',
    'YCbCrSubSampling',
    'ColorComponents',
    'BitDepth',
    'BitsPerSample',
  }
  local exclude = { -- TODO: let user exclude more keys
    FileAccessDate = true,
    FileInodeChangeDate = true,
    FileModifyDate = true,
    FileName = true,
    FilePermissions = true,
    FileSize = true,
    FileTypeExtension = true,
    Directory = true,
    ImageHeight = true,
    SourceFile = true,
    MIMEType = true,
    ImageWidth = true,
    ExifToolVersion = true,

    ChromaticAdaptation = true,
    HDRGainCurve = true,
    MPImage2 = true,
    ModifyDate = true,
    PixelUnits = true,
    PixelsPerUnitX = true,
    PixelsPerUnitY = true,
    ThumbnailImage = true,
    XResolution = true,
    YResolution = true,

    BlueMatrixColumn = true,
    BlueTRC = true,
    BlueX = true,
    BlueY = true,
    GreenMatrixColumn = true,
    GreenTRC = true,
    GreenX = true,
    GreenY = true,
    RedMatrixColumn = true,
    RedTRC = true,
    RedX = true,
    RedY = true,
  }

  for _, key in ipairs(pinned_keys) do
    add_field(data, key, json[key])
    exclude[key] = true
  end

  for key, val in pairs(json) do
    if exclude[key] then
      goto continue
    end
    add_field(data, key, val)
    ::continue::
  end

  return { data }
end

---@param job Job
function M:spot(job)
  require('spot'):spot(job, image_exiftool(job))
end

return M
