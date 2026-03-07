--- @since 25.12.29

--- @sync entry

-- TODO: goto begining/end when no more extensions are present
-- TODO: jump to file with matching stem with `*`
-- TODO: select all files with same extension

return {
  ---@param job Job
  entry = function(_, job)
    local cur = cx.active.current ---@type tab__Folder
    local files = cur.files ---@type fs__Files

    local current_index = cur.cursor ---@type number
    local target_index
    -- local pattern = [[.*(%..*)$]]
    local pattern = [[^.*(%..+)$]]
    local get_ext = function(file)
      if file.cha.is_dir then
        return '%dir%'
      else
        return string.rep(string.gsub(file.name, pattern, '%1'))
      end
    end
    -- local ext = string.gsub(cur.hovered.name, cur.hovered.url.stem or '', '') ---@type string
    local ext = get_ext(cur.hovered) ---@type string
    local fwd = (job.args[1] == 'fwd')
    local finish = fwd and #files or 1

    for i = current_index + 1, finish, fwd and 1 or -1 do
      local ext2 = get_ext(files[i])
      if ext ~= ext2 then
        ya.dbg(ext, ext2, i)
        target_index = i - 1
        break
      end
    end

    if target_index then
      ya.emit('arrow', { target_index - current_index })
      -- ya.dbg(target_index, current_index, target_index - current_index)
    end
  end,
}
