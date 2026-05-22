--- @since 25.12.29

local M = {}

local set_pref = ya.sync(function(st)
  st.sort = {
    by = cx.active.pref.sort_by,
    reverse = cx.active.pref.sort_reverse,
    dir_first = cx.active.pref.sort_dir_first,
    translit = cx.active.pref.sort_translit,
    sensitive = cx.active.pref.sort_sensitive,
  }
end)

local get_pref = ya.sync(function(st)
  return st.sort
    or {
      by = cx.active.pref.sort_by,
      reverse = cx.active.pref.sort_reverse,
      dir_first = cx.active.pref.sort_dir_first,
      translit = cx.active.pref.sort_translit,
      sensitive = cx.active.pref.sort_sensitive,
    }
end)

---@param config SortConf
---@return SortTable
local find_match = function(config)
  local cwd = tostring(cx.active.current.cwd)
  for _, conf in ipairs(config) do
    if cwd:find(conf.pattern) then
      return conf.sort
    end
  end
  return config.default
end

-- TODO: fix opening new tab with different sorting fucks up previous tab
-- TODO: fix starting at a config directory fucks up other directories

---@param config SortConf
function M:setup(config)
  ps.sub('ind-sort', function()
    ya.dbg(get_pref())
    return find_match(config) ---@diagnostic disable-line: redundant-return-value
  end)
end

-- TODO: sort changing by keymap
function M:entry()
  -- config.default = { by = arg[1], reverse = arg.reverse }
  -- set_pref(config.default)
end

return M
