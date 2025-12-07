local M = {}

local set_pref = ya.sync(function(st)
  st.sort = {
    cx.active.pref.sort_by,
    reverse = cx.active.pref.sort_reverse,
    dir_first = cx.active.pref.sort_dir_first,
    translit = cx.active.pref.sort_translit,
    sensitive = cx.active.pref.sort_sensitive,
  }
end)

local get_pref = ya.sync(function(st)
  return st.sort
    or {
      cx.active.pref.sort_by,
      reverse = cx.active.pref.sort_reverse,
      dir_first = cx.active.pref.sort_dir_first,
      translit = cx.active.pref.sort_translit,
      sensitive = cx.active.pref.sort_sensitive,
    }
end)

local find_match = function(config)
  local cwd = cx.active.current.cwd
  for i, conf in ipairs(config) do
    if tostring(cwd):find(conf.pattern) then
      return i
    end
  end
end

function M:setup(config)
  ps.sub('cd', function()
    local match = find_match(config)
    if match then
      set_pref()
      ya.emit('sort', config[match].sort)
    else
      ya.emit('sort', get_pref())
    end
  end)
end

return M
