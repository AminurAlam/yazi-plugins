---@since 25.5.31

local DEFAULT_OPTIONS = {
  -- Can't reference Header.RIGHT etc. here (it hangs) so parent and align are strings
  -- 2000 puts it to the right of the indicator, and leaves some room between
  position = { parent = 'Header', align = 'RIGHT', order = 2000 },
  format = 'both',
  bar = true,
  warning_threshold = 90,
  min_width = 12,
  style_label = {},
  style_normal = {},
  style_warning = {},
  padding = { open = '', close = '' },
}

---Deep copy and merge two tables, overwriting values from one table into another
---@param from table Table to take values from
---@param into table Table to merge into
---@return table result Merged table
local function merge(into, from)
  -- Handle nil inputs
  into = into or {}
  from = from or {}

  local result = {}

  -- Deep copy 'into' first
  for k, v in pairs(into) do
    if type(v) == 'table' then
      result[k] = merge({}, v)
    else
      result[k] = v
    end
  end

  -- Merge
  for k, v in pairs(from) do
    if type(v) == 'table' then
      result[k] = merge(result[k], v)
    else
      result[k] = v
    end
  end

  return result
end

---Merge styles from config into a usable style table
---@param style_label table Label style config
---@param style_normal table Normal style config
---@param style_warning table Warning style config
---@return table style Styles usably by bar components
local function build_style(style_label, style_normal, style_warning)
  local label_color = style_label.fg == '' and nil
    or (style_label.fg or th.status.progress_label:fg())

  ---Merge a single style (normal or warning)
  ---@param warning boolean True if the warning style should be used
  ---@return table output Style table
  local function build_style_type(warning)
    local normal_fg = style_normal.fg or th.status.progress_normal:fg()
    local normal_bg = style_normal.bg or th.status.progress_normal:bg()
    local warning_fg = style_warning.fg or th.status.progress_error:fg()
    local warning_bg = style_warning.bg or th.status.progress_error:bg()
    local output = {
      left = ui.Style()
        :fg(label_color or (warning and warning_bg or normal_bg))
        :bg(warning and warning_fg or normal_fg),
      right = ui.Style()
        :fg(label_color or (warning and warning_fg or normal_fg))
        :bg(warning and warning_bg or normal_bg),
      padding = {
        left = ui.Style():fg(warning and warning_fg or normal_fg),
        right = ui.Style():fg(warning and warning_bg or normal_bg),
      },
    }

    if style_label.bold then
      output.left = output.left:bold()
      output.right = output.right:bold()
    end
    if style_label.italic then
      output.left = output.left:italic()
      output.right = output.right:italic()
    end

    return output
  end

  return {
    normal = build_style_type(false),
    warning = build_style_type(true),
  }
end

---Parse source and usage from `df` output
---@param stdout string `df` output
---@return string source Current filesystem name
---@return number? usage Usage percent (0-100), if parseable
local function process_df_output(stdout)
  local usage, source = stdout:match('\n%S+%s+%d+%s+%d+%s+%d+%s+([%d%-]+)%%%s+(.*)\n')

  -- Follow symlinks in source
  if string.sub(source, 1, 1) == '/' then
    source = Command('readlink')
      :arg({ '--silent', '--canonicalize', '--no-newline', source })
      :output().stdout
  end

  return source, tonumber(usage)
end

---Format bar text
---@param source string Current filesystem name
---@param usage number Usage percent (0-100)
---@param format string Format string
---@param min_width integer minimum bar width
---@return string text Formatted bar text
local function format_text(source, usage, format, min_width)
  local text = ''
  if format == 'both' then
    text = string.format('%s: %d%%', source, usage)
  elseif format == 'name' then
    text = string.format('%s', source)
  elseif format == 'usage' then
    text = string.format('%d%%', usage)
  end
  if #text < min_width then
    text = text .. string.rep(' ', min_width - #text)
  end
  return text
end

---Set new plugin state and redraw
---@param source string? Current filesystem name
---@param usage number? Usage percent (0-100)
---@param text string? Bar text
---@param bar_len number? Bar length in characters
local set_state = ya.sync(function(st, source, usage, text, bar_len)
  st.source = source
  st.usage = usage
  st.text = text
  st.bar_len = bar_len

  local render = ui.render or ya.render
  render()
end)

---Get plugin state needed by entry
---@return table state Table with useful variables from plugin state
local get_state = ya.sync(function(st)
  return {
    -- Persistent options
    format = st.format,
    bar = st.bar,
    padding = st.padding,
    min_width = st.min_width,

    -- Variables
    source = st.source,
    usage = st.usage,
  }
end)

---Rebuild styles and save to state
local update_style = ya.sync(function(st)
  st.style = build_style(st.style_label, st.style_normal, st.style_warning)
  local render = ui.render or ya.render
  render()
end)

-- Called from init.lua
local function setup(st, opts)
  opts = merge(DEFAULT_OPTIONS, opts)

  -- Allow unsetting some options
  if opts.warning_threshold < 0 then
    opts.warning_threshold = nil
  end

  -- Translate opts.position.parent option into a component reference
  if opts.position.parent == 'Header' then
    opts.position.parent = Header
  elseif opts.position.parent == 'Status' then
    opts.position.parent = Status
  else
    -- Just set it to nil, it's gonna cause errors anyway
    opts.position.parent = nil
  end

  -- Initial state
  st.format = opts.format
  st.bar = opts.bar
  st.warning_threshold = opts.warning_threshold
  st.style_label = opts.style_label
  st.style_normal = opts.style_normal
  st.style_warning = opts.style_warning
  st.padding = opts.padding
  st.min_width = opts.min_width
  st.style = build_style(opts.style_label, opts.style_normal, opts.style_warning)

  -- Add the component to the parent
  opts.position.parent:children_add(function(self)
    -- No point showing anything if usage is nil
    if not st.usage then
      return
    end

    local style = (st.warning_threshold and st.usage >= st.warning_threshold) and st.style.warning
      or st.style.normal

    -- Apply styles to components based on the bar length, and add them to the bar
    local output = {}
    local bar_len = st.bar_len
    local components = {
      -- { text = st.padding.open, style = style.padding },
      { text = st.padding.open, style = style.padding },
      { text = st.text, style = style },
      { text = st.padding.close, style = style.padding },
    }
    for _, component in ipairs(components) do
      -- bar_len_bytes should point to the last byte that should be coloured by the usage bar
      local bar_len_bytes
      if bar_len <= 0 then
        -- 1-indexed, so effectively no bar showing
        bar_len_bytes = 0
      elseif bar_len >= utf8.len(component.text) then
        bar_len_bytes = #component.text
      else
        bar_len_bytes = utf8.offset(component.text, bar_len + 1) - 1
      end

      if bar_len_bytes > 0 then
        table.insert(
          output,
          ui.Span(string.sub(component.text, 1, bar_len_bytes)):style(component.style.left)
        )
      end
      if bar_len_bytes < #component.text then
        table.insert(
          output,
          ui.Span(string.sub(component.text, bar_len_bytes + 1)):style(component.style.right)
        )
      end

      bar_len = bar_len - utf8.len(component.text)
    end

    return ui.Line(output)
  end, opts.position.order, opts.position.parent[opts.position.align])

  ---Pass cwd to the plugin for df
  local function callback()
    ya.emit('plugin', {
      st._id,
      ya.quote(tostring(cx.active.current.cwd)),
    })
  end

  -- Subscribe to events
  ps.sub('cd', callback)
  ps.sub('tab', callback)
  ps.sub('delete', callback)
  ps.sub('theme', update_style)
  -- These are the only relevant events that actually work
  -- Note: df might not immediately reflect usage changes
  --  when deleting files
end

-- Called from ya.emit in the callback
local function entry(_, job)
  local cwd = job.args[1]

  -- Don't set cwd directly for Command() here, it hangs for dirs without read perms
  -- cwd is fine as an argument to df though
  local output = Command('df'):arg({ tostring(cwd) }):output()

  if not output then
    set_state(nil, nil, nil, nil)
    return
  end

  -- If df fails, hide the module
  if not output.status.success then
    set_state(nil, nil, nil, nil)
    return
  end

  local source, usage = process_df_output(output.stdout)

  -- If df read the filesystem but couldn't get a percentage, hide the module
  -- if usage == nil then
  if type(usage) ~= 'number' then
    set_state(nil, nil, nil, nil)
    return
  end

  local st = get_state()

  -- If nothing has changed, don't bother updating
  if source == st.source and usage == st.usage then
    return
  end

  local text = format_text(source, usage, st.format, st.min_width)
  local bar_len = 0 ---@type integer? Start with no bar by default

  -- Only calculate bar length if the bar will be shown
  if st.bar then
    local total_len = utf8.len(st.padding.open .. text .. st.padding.close)

    -- Using ceil so the bar is only empty at 0%
    -- Using len - 1 so the bar isn't full until 100%
    bar_len = (usage < 100) and math.ceil((total_len - 1) / 100 * usage) or total_len
    -- bar_len = bar_len + 5
  end

  set_state(source, usage, text, bar_len)
end

return { setup = setup, entry = entry }
