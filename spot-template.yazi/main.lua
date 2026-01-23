local M = {}

function M:spot(job)
  require('spot'):spot(job, {
    {
      title = 'AAA',
      { '1', 'ONE' },
      { '2', 'TWO' },
    },
    {
      title = 'BBB',
      { '1', ui.Line('ONE'):fg('red') },
      { '2', ui.Line('TWO'):fg('magenta') },
    },
  }, {
    -- you can pass config table here just like in :setup({...})
  })
end

return M
