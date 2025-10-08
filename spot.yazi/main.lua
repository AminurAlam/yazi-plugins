local M = {}

---@param file File
---@return string
local permission = function(file)
  local h = file
  if not h then return '' end

  local perm = h.cha:perm()
  if not perm then return '' end

  local spans = ''
  for i = 1, #perm do
    local c = perm:sub(i, i)
    spans = spans .. c
  end
  return spans
end

---@param file File
---@return string
local hash = function(file)
  local h = file
  if h.cha.len > 100000000 then return '' end -- 100M
  local cmd = Command('cksum'):arg { '-acrc', h.name }

  local output, err = cmd:output()
  if not output then return '', Err('Failed to start `ffprobe`, error: %s', err) end
  return output.stdout:gsub('^(%d+ %d+).*', '%1')
end

---@param file File
---@param type "mtime" | "atime" | "btime"
---@return string
local fileTimestamp = function(file, type)
  local h = file
  if not h or h.cha.is_link then return '' end
  local time = math.floor(h.cha[type] or 0)
  if time == 0 then return '' end
  return tostring(os.date('%Y-%m-%d %H:%M', time))
end

function M:render_table(job, extra)
  local styles = {
    header = th.spot.title or ui.Style():fg('green'),
    row_label = ui.Style():fg('reset'),
    row_value = th.spot.tbl_col or ui.Style():fg('blue'),
  }
  local rows = {}
  local file_name_extension = job.file.cha.is_dir and '…' or ('.' .. (job.file.url.ext or ''))

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

  -- Extras
  for _, section in ipairs(extra or {}) do
    add_section(section)
  end

  -- Plugins
  --[[
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
  } --]]

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

function M:spot(job, extra)
  job.area = ui.Pos({ 'center', w = extra and 70 or 60, h = extra and 25 or 20 })
  ya.spot_table(job, self:render_table(job, extra))
end

return M
