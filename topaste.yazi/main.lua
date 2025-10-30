--- @sync entry

return {
  setup = function()
    ps.sub('move', function(body) ya.emit('reveal', { body.items[1].to }) end)
    if rt.args.chooser_file then ya.emit('yank', { cut = true }) end
  end,
}
