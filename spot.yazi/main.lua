--- @since 25.12.29

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
        relative_time = true,
        time_format = '%Y-%m-%d %H:%M', -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
      },
      plugins_section = {
        enable = true,
      },
      style = {
        section = 'green',
        key = 'reset',
        value = 'blue',
        colorize_metadata = true,
        height = 20,
        width = 60,
        key_length = 15,
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

  if not config.style.colorize_metadata then
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

  local cmd = Command(config.metadata_section.hash_cmd):arg { file.name }

  local output, err = cmd:output()
  if not output then
    return Err('Error: %s', err)
  end

  local sum = output.stdout:sub(1, -#file.name - 3)

  if not config.style.colorize_metadata then
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
    while true do
      local next = it:recv()
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

  local str = string.format('%.2f', size)
  str = string.gsub(str, '(%d),?0*$', '%1')
  return str .. ' ' .. units[unit_index]
end

---@param job Job
---@param extra table
---@param config SpotConf
---@return Renderable
function M:render_table(job, extra, config)
  local rows = {}

  -- TODO: render multiline if '\n' is present
  ---@param section Section
  local add_section = function(section)
    if #rows ~= 0 then
      rows[#rows + 1] = ui.Row({}) ---@diagnostic disable-line: undefined-field
    end

    rows[#rows + 1] = ui.Row({ section.title or 'No title' })
      :style(ui.Style():fg(config.style.section))
    for _, row in ipairs(section) do
      -- label_max_length = math.max(#row[2], label_max_length)

      local key = row[1]
      if type(row[1]) == 'string' then
        key = ui.Line('  ' .. row[1]):style(ui.Style():fg(config.style.key))
      end

      local val = row[2]
      if type(row[2]) == 'string' then
        val = ui.Line(row[2]):style(ui.Style():fg(config.style.value))
      end

      rows[#rows + 1] = ui.Row({ key, val })
    end
  end

  local hashrow = (
    config.metadata_section.hash_filesize_limit > 0
    and not job.file.cha.is_dir
    and not (job.file.cha.len > (config.metadata_section.hash_filesize_limit * 1000000))
  )
      and { 'Hash', hash(job.file, config) }
    or nil

  -- Metadata
  if config.metadata_section.enable then
    add_section {
      title = 'Metadata',
      { 'Mimetype', job.mime },
      { 'Size', format_size(get_total_size({ job.file.url })) }, -- TODO: update modeline with size
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
    local spotter = rt.plugin.spotter(job.file, job.mime) ---@diagnostic disable-line: undefined-field
    local previewer = rt.plugin.previewer(job.file, job.mime) ---@diagnostic disable-line: undefined-field
    local fetchers = rt.plugin.fetchers(job.file, job.mime) ---@diagnostic disable-line: undefined-field
    local preloaders = rt.plugin.preloaders(job.file, job.mime) ---@diagnostic disable-line: undefined-field

    for i, v in ipairs(fetchers) do
      fetchers[i] = v.cmd
    end
    for i, v in ipairs(preloaders) do
      preloaders[i] = v.cmd
    end

    add_section {
      title = 'Plugins',
      { 'Spotter', spotter and spotter.cmd or '-' },
      { 'Previewer', previewer and previewer.cmd or '-' },
      { 'Fetchers', #fetchers ~= 0 and table.concat(fetchers, ', ') or '-' },
      { 'Preloaders', #preloaders ~= 0 and table.concat(preloaders, ', ') or '-' },
    }
  end

  return ui
    .Table(rows) ---@diagnostic disable-line: undefined-field
    :area(job.area) ---@diagnostic disable-line: undefined-field
    :row(1)
    :col(1)
    :widths({
      ui.Constraint.Length(config.style.key_length),
      ui.Constraint.Fill(1),
    })
    :cell_style(ui.Style():fg(config.style.value):reverse())
  -- :col_style(styles.row_value)
end

---@param job Job
---@param extra Sections
---@param config SpotConf
function M:spot(job, extra, config)
  config = tbl_strict_extend(get_config(), config) ---@type SpotConf
  job.area = ui.Pos({ 'center', w = config.style.width, h = config.style.height }) ---@diagnostic disable-line: inject-field
  ya.spot_table(job, self:render_table(job, extra, config)) ---@diagnostic disable-line: undefined-field
end

return M
