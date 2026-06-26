--- @since 26.5.6

local M = {}

---@type fun(opts: SpotConf): nil
local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

---@type fun(): SpotConf
local get_config = ya.sync(function(st)
  return st.opts
    or {
      metadata_section = {
        enable = true,
        hash_cmd = 'xxhsum', -- other hashing commands may be slower
        hash_filesize_limit = 150, -- in MB, set 0 to disable
        relative_time = true, -- 2026-01-01 or n days ago
        time_format = '%Y-%m-%d %H:%M', -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
        show_compression = true, ---@type boolean
      },
      plugins_section = {
        enable = true,
      },
      style = {
        color = {
          metadata = true,
          title = 'green',
          key = 'reset',
          value = 'blue',
          selected = 'blue',
        },
        size = {
          height = 20, -- unused when auto_resize is set to true
          width = 60, -- unused when auto_resize is set to true
          auto_resize = true,
          min_width = 60,
          max_width = 80,
          min_height = 20,
          max_height = 40,
        },
        max_key_length = 25,
        key_indent_size = 2,
      },
    }
end)

---@param file File
---@param config SpotConf
---@return Renderable
local permission = function(file, config)
  if not file then
    return ui.Text('no such file exists')
  end

  local perm = file.cha:perm()
  if not perm then
    return ui.Text('couldnt get permissions')
  end

  if not config.style.color.metadata then
    return perm
  end

  local spans = {}
  for i = 1, #perm do
    local c = perm:sub(i, i)
    local style = th.status.perm_type
    if c == '-' or c == '?' then
      style = th.status.perm_sep
    elseif c == 'r' then
      style = th.status.perm_read
    elseif c == 'w' then
      style = th.status.perm_write
    elseif c == 'x' or c == 's' or c == 'S' or c == 't' or c == 'T' then
      style = th.status.perm_exec
    end
    spans[i] = ui.Span(c):style(style)
  end
  return ui.Line(spans)
end

---@param file File
---@param config SpotConf
---@return Renderable
local hash = function(file, config)
  local styles = {
    [0] = ui.Style():fg('blue'),
    ui.Style():fg('green'),
    ui.Style():fg('magenta'),
    ui.Style():fg('red'),
    ui.Style():fg('yellow'),
    ui.Style():fg('blue'),
    ui.Style():fg('cyan'),
    ui.Style():fg('magenta'),
    ui.Style():fg('red'),
    ui.Style():fg('yellow'),
  }

  local cmd = Command(config.metadata_section.hash_cmd):arg({ file.name })

  local output, err = cmd:output()
  if not output then
    return Err('Error: %s', err)
  end

  local sum = output.stdout:sub(1, -#file.name - 3)

  if not config.style.color.metadata then
    return ui.Text(sum)
  end
  local spans = {}
  for i = 1, #sum do
    local c = sum:sub(i, i)
    spans[i] = ui.Span(c):style(styles[tonumber(c)] or ui.Style():fg('white'))
  end

  return ui.Line(spans)
end

---@param file File
---@param type "atime"|"btime"|"mtime"
---@param config SpotConf
---@return string
local fileTimestamp = function(file, type, config)
  local file = file ---@diagnostic disable-line: redefined-local
  if not file or file.cha.is_link then
    return ''
  end

  local time = math.floor(file.cha[type] or 0)
  local delta = os.time() - time

  if time == 0 then
    return ''
  end

  if delta < (3600 * 24 * 7) and config.metadata_section.relative_time then
    local relative_format = ''
    if delta < 60 then
      relative_format = delta .. 's ago'
    elseif delta < 3600 then
      relative_format = (delta // 60) .. ' m ago'
    elseif delta < (3600 * 24) then
      relative_format = (delta // 3600) .. 'h ago'
    else
      relative_format = (delta // (3600 * 24)) .. ' days ago'
    end
    return relative_format
  end
  return tostring(os.date(config.metadata_section.time_format, time))
end

local function tbl_strict_extend(default, config)
  if type(default) ~= type(config) then
    return default
  end
  if type(default) ~= 'table' then
    if config ~= nil then
      return config
    else
      return default
    end
  end

  for key, _ in pairs(default) do
    default[key] = tbl_strict_extend(default[key], config[key])
  end

  return default
end

---@param config SpotConf
function M:setup(config)
  set_config(tbl_strict_extend(get_config(), config))
end

---@param urls Url
---@return integer
local get_total_size = function(urls)
  local total = 0
  for _, url in ipairs(urls) do
    local it = fs.calc_size(url)
    while it do
      local next = it:recv() ---@diagnostic disable-line: undefined-field
      if next then
        total = total + next
      else
        break
      end
    end
  end
  return total
end

---@param size integer
---@return string
local format_size = function(size)
  local units = { 'B', 'K', 'M', 'G', 'T' }
  local unit_index = 1
  while size > 1024 and unit_index < #units do
    size = size / 1024
    unit_index = unit_index + 1
  end

  local str = ('%.2f'):format(size)
  str = str:gsub('(%d),?0*$', '%1')
  return str .. ' ' .. units[unit_index]
end

---@param job Job
---@param extra table
---@param config SpotConf
---@return Renderable
function M:render_table(job, extra, config)
  local rows = {}
  local key_pad = config.style.key_indent_size
  local key_width = 0
  local val_width = 0

  ---@param cell string|Renderable
  ---@param cell_style AsColor
  ---@param prefix string?
  ---@return Renderable
  local function styled_cell(cell, cell_style, prefix)
    if type(cell) == 'string' then
      return ui.Line((prefix or '') .. cell):style(ui.Style():fg(cell_style))
    end
    return cell
  end

  -- TODO: render multiline if '\n' is present
  -- TODO: break lines if it exceeds window width
  ---@param section Section
  local add_section = function(section)
    if #rows ~= 0 then
      rows[#rows + 1] = ui.Row({}) ---@diagnostic disable-line: undefined-field
    end

    rows[#rows + 1] = ui.Row({
      ui.Line(section.title or 'No title'):style(ui.Style():fg(config.style.color.title)),
    })

    for _, row in ipairs(section) do
      if not row then
        goto continue
      end
      local key, val = row[1], row[2]
      if not key or not val then
        goto continue
      end
      rows[#rows + 1] = ui.Row({
        styled_cell(key, config.style.color.key, (' '):rep(key_pad)),
        styled_cell(val, config.style.color.value),
      })

      key_width = math.max(key_width, type(key) == 'string' and #key or 0)
      val_width = math.max(val_width, type(val) == 'string' and #val or 0)

      -- ya.dbg(key, val, #key, key_width)

      ::continue::
    end
  end

  local hashrow = (
    config.metadata_section.hash_filesize_limit > 0
    and not job.file.cha.is_dir
    and not (job.file.cha.len > (config.metadata_section.hash_filesize_limit * 1000000))
  )
      and { 'Hash', hash(job.file, config) }
    or nil

  local size = format_size(get_total_size({ job.file.url })) ---@diagnostic disable-line: missing-fields

  if config.metadata_section.show_compression and job.mime == 'application/zip' then
    local output, err = Command('zipinfo'):arg({ '-t', tostring(job.file.url) }):output()

    if not output or err then
      return Err('Error: %s', err)
    end
    if config.metadata_section.show_compression == true then
      size = size
        .. ' ('
        .. format_size(tonumber(output.stdout:gsub('.* (%d+) bytes uncompressed.*', '%1'), 10))
        .. ', '
        .. output.stdout:gsub('.* (%d+%.%d+%%)', '%1')
        .. ')'
    end
  end

  -- Metadata
  if config.metadata_section.enable then
    add_section {
      title = 'Metadata',
      { 'Mimetype', job.mime },
      { 'Size', size }, -- TODO: update modeline with size
      { 'Mode', permission(job.file, config) },
      { 'Created', fileTimestamp(job.file, 'btime', config) },
      { 'Modified', fileTimestamp(job.file, 'mtime', config) },
      { 'Accessed', fileTimestamp(job.file, 'atime', config) },
      hashrow,
    }
  end

  -- Extras
  for _, section in ipairs(extra or {}) do
    add_section(section)
  end

  -- Plugins
  if config.plugins_section.enable then
    local get_plugin = function(type)
      local text = ''
      for _, plugin in pairs(rt.plugin[type]:match({ mime = job.mime, file = job.file })) do
        text = text .. plugin.name .. ', '
      end
      -- ya.dbg(text)
      return text:sub(1, -3)
    end
    add_section {
      title = 'Plugins',
      { 'Spotter', get_plugin('spotters') },
      { 'Previewer', get_plugin('previewers') },
      { 'Fetchers', get_plugin('fetchers') },
      { 'Preloaders', get_plugin('preloaders') },
    }
  end

  key_width = math.min(config.style.max_key_length, key_pad + key_width)
  local conf_size = config.style.size

  return ui
    .Table(rows) ---@diagnostic disable-line: undefined-field
    :area(ui.Pos {
      'center',
      w = conf_size.auto_resize
          and ya.clamp(conf_size.min_width, key_width + val_width + 4, conf_size.max_width)
        or conf_size.width,
      h = conf_size.auto_resize and ya.clamp(conf_size.min_height, #rows + 2, conf_size.max_height)
        or conf_size.height,
    })
    :row(1)
    :col(2)
    :widths({
      ui.Constraint.Length(key_width + 1),
      ui.Constraint.Fill(1),
    })
    :cell_style(ui.Style():fg(config.style.color.selected):reverse())
end

---@param job Job
---@param extra Sections
---@param config SpotConf
function M:spot(job, extra, config)
  config = tbl_strict_extend(get_config(), config) ---@type SpotConf
  ya.spot_table(job, self:render_table(job, extra, config)) ---@diagnostic disable-line: undefined-field
end

return M
