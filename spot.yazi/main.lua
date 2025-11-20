local M = {}

local set_config = ya.sync(function(st, opts) st.opts = opts end)

local get_config = ya.sync(
  function(st)
    return st.opts
      or {
        height = 20,
        width = 60,
        render_metadata = true,
        render_plugins = false,
      }
  end
)

local permission = function(file)
  if not file then return '' end

  local perm = file.cha:perm()
  if not perm then return '' end

  local spans = ''
  for i = 1, #perm do
    local c = perm:sub(i, i)
    spans = spans .. c
  end
  return spans
end

local hash = function(file)
  -- TODO: make the size limit configurable
  if file.cha.len > 100000000 then return '' end -- 100M
  local cmd = Command('cksum'):arg { '-acrc', file.name }

  local output, err = cmd:output()
  if not output then return '', Err('Failed to start `ffprobe`, error: %s', err) end
  return output.stdout:gsub('^(%d+ %d+).*', '%1')
end

local fileTimestamp = function(file, type)
  local file = file
  if not file or file.cha.is_link then return '' end
  local time = math.floor(file.cha[type] or 0)
  if time == 0 then return '' end
  return tostring(os.date('%Y-%m-%d %H:%M', time))
end

local function tbl_strict_extend(default, config)
  if type(default) ~= type(config) then return default end
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

function M:setup(config) set_config(tbl_strict_extend(get_config(), config)) end

function M:render_table(job, extra, config)
  local styles = {
    header = th.spot.title or ui.Style():fg('green'),
    row_label = ui.Style():fg('reset'),
    row_value = th.spot.tbl_col or ui.Style():fg('blue'),
  }
  local rows = {}

  -- TODO: render multiline if '\n' is present
  ---@param section table
  local add_section = function(section)
    if #rows ~= 0 then rows[#rows + 1] = ui.Row({}) end
    rows[#rows + 1] = ui.Row({ section.title }):style(styles.header)
    for _, value in ipairs(section) do
      -- label_max_length = math.max(#value[2], label_max_length)
      rows[#rows + 1] = ui.Row({
        ui.Line('  ' .. value[1]):style(styles.row_label),
        ui.Text(value[2] or ''):style(styles.row_value),
      })
    end
  end

  if config.render_metadata then
    add_section {
      title = 'Metadata',
      { 'Mimetype', job.mime },
      { 'Mode', permission(job.file) },
      -- TODO: relative
      { 'Created', fileTimestamp(job.file, 'btime') },
      { 'Modified', fileTimestamp(job.file, 'mtime') },
      { 'Accessed', fileTimestamp(job.file, 'atime') },
      { 'Hash', hash(job.file) },
    }
  end

  -- Extras
  for _, section in ipairs(extra or {}) do
    add_section(section)
  end

  -- Plugins
  if config.render_plugins then
    local spotter = rt.plugin.spotter(job.file.url, job.mime)
    local previewer = rt.plugin.previewer(job.file.url, job.mime)
    local fetchers = rt.plugin.fetchers(job.file, job.mime)
    local preloaders = rt.plugin.preloaders(job.file.url, job.mime)

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
      { 'Fetchers', #fetchers ~= 0 and fetchers or '-' },
      { 'Preloaders', #preloaders ~= 0 and preloaders or '-' },
    }
  end

  return ui
    .Table(rows)
    :area(job.area)
    :row(1)
    :col(1)
    -- :col_style(styles.row_value)
    :widths({
      ui.Constraint.Length(15),
      ui.Constraint.Fill(1),
    })
    :cell_style(th.spot.tbl_cell or ui.Style():fg('blue'):reverse())
end

function M:spot(job, extra, config)
  local config = tbl_strict_extend(get_config(), config)
  job.area = ui.Pos({ 'center', w = config.width, h = config.height })
  ya.spot_table(job, self:render_table(job, extra, config))
end

return M
