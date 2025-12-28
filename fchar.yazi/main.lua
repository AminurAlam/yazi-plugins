--- @since 25.5.31

local M = {}

local changed = ya.sync(function(st, new)
  local b = st.last ~= new
  st.last = new
  return b or not cx.active.finder
end)

local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

local get_config = ya.sync(function(st)
  return st.opts
    or {
      -- f true: f -> file, File, FILE
      insensitive = true,

      -- if true: f -> file, .file, @file, #file, ...file
      skip_symbols = true,

      -- if true: f -> file, alsofile, elf
      search_entire_string = false,

      aliases = {},
    }
end)

local function tbl_deep_extend(default, config)
  if type(config) ~= 'table' then
    return config
  end

  default = (type(default) == 'table') and default or {}
  for key, _ in pairs(config) do
    default[key] = tbl_deep_extend(default[key], config[key])
  end

  return default
end

function M:setup(config)
  set_config(tbl_deep_extend(get_config(), config))
end

-- TODO: process `--flags`
function M:entry()
  local cands = {
    { on = '0' },
    { on = '1' },
    { on = '2' },
    { on = '3' },
    { on = '4' },
    { on = '5' },
    { on = '6' },
    { on = '7' },
    { on = '8' },
    { on = '9' },
    { on = '_' },
    { on = 'a' },
    { on = 'b' },
    { on = 'c' },
    { on = 'd' },
    { on = 'e' },
    { on = 'f' },
    { on = 'g' },
    { on = 'h' },
    { on = 'i' },
    { on = 'j' },
    { on = 'k' },
    { on = 'l' },
    { on = 'm' },
    { on = 'n' },
    { on = 'o' },
    { on = 'p' },
    { on = 'q' },
    { on = 'r' },
    { on = 's' },
    { on = 't' },
    { on = 'u' },
    { on = 'v' },
    { on = 'w' },
    { on = 'x' },
    { on = 'y' },
    { on = 'z' },
    { on = 'A' },
    { on = 'B' },
    { on = 'C' },
    { on = 'D' },
    { on = 'E' },
    { on = 'F' },
    { on = 'G' },
    { on = 'H' },
    { on = 'I' },
    { on = 'J' },
    { on = 'K' },
    { on = 'L' },
    { on = 'M' },
    { on = 'N' },
    { on = 'O' },
    { on = 'P' },
    { on = 'Q' },
    { on = 'R' },
    { on = 'S' },
    { on = 'T' },
    { on = 'U' },
    { on = 'V' },
    { on = 'W' },
    { on = 'X' },
    { on = 'Y' },
    { on = 'Z' },
  }
  local opts = get_config()

  if opts.skip_symbols then
    local additional_keys = '~.!@#-'
    for i = 1, #additional_keys do
      cands[#cands + 1] = { on = additional_keys:sub(i, i) }
    end
  end

  local idx = ya.which { cands = cands, silent = true }
  if not idx then
    return
  end

  local re = (opts.search_entire_string and '' or '^')
    .. (opts.skip_symbols and [[\W?]] or '')
    .. '['
    .. cands[idx].on
    .. (opts.aliases[cands[idx].on] or '')
    .. ']'
  if changed(re) then
    ya.emit('find_do', { re, insensitive = opts.insensitive })
  else
    ya.emit('find_arrow', {})
  end
end

return M
