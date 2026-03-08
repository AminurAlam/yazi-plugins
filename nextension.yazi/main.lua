--- @since 25.12.29

--- @sync entry

-- TODO: jump to file with matching stem with `*`
-- TODO: select all files with same extension

return {
  ---@param job Job
  entry = function(_, job)
    local get_ext = function(file) ---@param file fs__File
      if file.cha.is_dir then
        return '%dir%'
      else
        return string.rep(string.gsub(file.name, [[^.*(%..+)$]], '%1'))
      end
    end
    local cur = cx.active.current ---@type tab__Folder
    local files = cur.files ---@type fs__Files
    local current_index = cur.cursor ---@type number
    local target_index
    local ext = get_ext(cur.hovered) ---@type string
    local fwd = (job.args[1] == 'fwd')
    local finish = fwd and #files or 1

    for i = current_index + 1, finish, fwd and 1 or -1 do
      local ext2 = get_ext(files[i]) ---@type string
      if ext ~= ext2 then
        ya.dbg(ext, ext2, i)
        target_index = i - 1
        break
      end
    end

    if target_index then
      ya.emit('arrow', { target_index - current_index })
    else
      if fwd then
        ya.emit('arrow', { 'bot' })
      else
        ya.emit('arrow', { 'top' })
      end
    end
  end,
}
