local M = {}

local changed = ya.sync(function(st, new)
  local b = st.last ~= new
  st.last = new
  return b or not cx.active.finder
end)

local matched = ya.sync(function()
  for _, file in ipairs(cx.active.current.files) do
    local highlights = file:highlights()
    if highlights and #highlights > 0 then return true end
  end
  return false
end)

local set_config = ya.sync(function(st, opts) st.opts = opts end)

local get_config = ya.sync(
  function(st)
    return st.opts
      or {
        insensitive = true,
        keep_searching = { enable = false, limit = 10 },
        aliases = {},
      }
  end
)

local function tbl_deep_extend(default, config)
  if type(config) ~= 'table' then return config end

  default = (type(default) == 'table') and default or {}
  for key, _ in pairs(config) do
    default[key] = tbl_deep_extend(default[key], config[key])
  end

  return default
end

function M:setup(config) set_config(tbl_deep_extend(get_config(), config)) end

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

  local idx = ya.which { cands = cands, silent = true }
  if not idx then return end

  local kw = '[' .. cands[idx].on .. (opts.aliases[cands[idx].on] or '') .. ']'
  local count = 0
  if changed(kw) then
    ya.emit('find_do', { [[^\W?]] .. string.rep('.', count) .. kw, insensitive = opts.insensitive })
    while opts.keep_searching.enable and count < opts.keep_searching.limit and not matched() do
      count = count + 1
      ya.emit('find_do', { [[^\W?]] .. string.rep('.', count) .. kw, insensitive = opts.insensitive })
    end
  else
    ya.emit('find_arrow', {})
  end
end

return M
