--- @since 26.1.22
--- @sync entry

--@param other (0|1)[]

---@param other {[1]: 0|1, [2]: 0|1, [3]: 0|1}
---@return boolean
local function eq(other)
  local r = rt.mgr.ratio
  return other[1] == r.current and other[2] == r.preview
end

local function entry()
  -- TODO: toggle between given states instead of hardcoded paths
  -- local states = {
  --   { 0, 1, 1 },
  --   { 0, 1, 0 },
  --   { 0, 0, 1 },
  -- }
  if eq { 1, 1 } then
    rt.mgr.ratio = { 0, 1, 0 }
  elseif eq { 1, 0 } then
    rt.mgr.ratio = { 0, 0, 1 }
  else
    rt.mgr.ratio = { 0, 1, 1 }
  end

  ya.emit('app:resize', {})
end

return { entry = entry }
