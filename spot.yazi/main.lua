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

          auto_resize_width = true,
          min_width = 30,
          max_width = 80,

          auto_resize_height = true,
          min_height = 10,
          max_height = 50,

          key_length = 15,
        },

        padding = {
          -- vertical = 1,
          horizontal = 1,
          key = 2,
        },
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
---@return integer
---@return integer
function M:render_table(job, extra, config)
  -- Constructed only one time
  local rows = {}

  local horizontal_pad = config.style.padding.horizontal
  -- local vpad = config.style.padding.vertical
  local key_pad = config.style.padding.key

  local key_prefix = (' '):rep(key_pad)

  local title_style = ui.Style():fg(config.style.color.title)
  local key_style = ui.Style():fg(config.style.color.key)
  local value_style = ui.Style():fg(config.style.color.value)
  local selected_style = ui.Style():fg(config.style.color.selected):reverse()

  local widths = {
    ui.Constraint.Length(horizontal_pad),
    ui.Constraint.Length(config.style.size.key_length + key_pad),
    ui.Constraint.Fill(1),
    ui.Constraint.Length(horizontal_pad),
  }

  local min_width = config.style.size.key_length + key_pad + (2 * horizontal_pad)
  local max_width = min_width

  ---@param value string|Renderable
  ---@param prefix string|nil
  ---@param cell_style ui.Style
  ---@return Renderable
  local function styled_cell(value, prefix, cell_style)
    if type(value) ~= 'string' then
      return value
    end

    return ui.Line((prefix or '') .. value):style(cell_style)
  end

  -- TODO: render multiline if '\n' is present
  ---@param section Section
  local add_section = function(section)
    if #rows ~= 0 then
      rows[#rows + 1] = ui.Row({}) ---@diagnostic disable-line: undefined-field
    end

    rows[#rows + 1] = ui.Row({
      '',
      ui.Line(section.title or 'No title'):style(title_style),
      '',
      '',
    })

    for _, row in ipairs(section) do
      if row ~= nil then
        rows[#rows + 1] = ui.Row({
          '',
          styled_cell(row[1], key_prefix, key_style),
          styled_cell(row[2], nil, value_style),
          '',
        })

        local row_width = min_width + (type(row[2]) == 'string' and #row[2] or 0)
        if row_width > max_width then
          max_width = row_width
        end
      end
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
    add_section({
      title = 'Metadata',
      { 'Mimetype', job.mime },
      { 'Size', size }, -- TODO: update modeline with size
      { 'Mode', permission(job.file, config) },
      { 'Created', fileTimestamp(job.file, 'btime', config) },
      { 'Modified', fileTimestamp(job.file, 'mtime', config) },
      { 'Accessed', fileTimestamp(job.file, 'atime', config) },
      hashrow,
    })
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
      ya.dbg(text)
      return text:sub(1, -3)
    end
    add_section({
      title = 'Plugins',
      { 'Spotter', get_plugin('spotters') },
      { 'Previewer', get_plugin('previewers') },
      { 'Fetchers', get_plugin('fetchers') },
      { 'Preloaders', get_plugin('preloaders') },
    })
  end

  local table_height = #rows
  local table_width = max_width

  return ui
    .Table(rows) ---@diagnostic disable-line: undefined-field
    :row(1)
    :col(2)
    :widths(widths)
    :cell_style(selected_style),
    table_height,
    table_width
  -- :col_style(styles.row_value)
end

---@param job Job
---@param extra Sections
---@param config SpotConf
function M:spot(job, extra, config)
  config = tbl_strict_extend(get_config(), config) ---@type SpotConf

  local ui_table, table_height, table_width = self:render_table(job, extra, config)
  local area_height = config.style.size.height
  if config.style.size.auto_resize_height then
    area_height = math.max(table_height + 2, config.style.size.min_height) -- +2 due to border
    area_height = math.min(area_height, config.style.size.max_height)
  end

  local area_width = config.style.size.width
  if config.style.size.auto_resize_width then
    area_width = math.max(table_width + 2, config.style.size.min_width) -- +2 due to border
    area_width = math.min(area_width, config.style.size.max_width)
  end

  job.area = ui.Pos({ 'center', w = area_width, h = area_height }) ---@diagnostic disable-line: assign-type-mismatch
  ui_table:area(job.area)
  ya.spot_table(job, ui_table) ---@diagnostic disable-line: undefined-field
end

return M
