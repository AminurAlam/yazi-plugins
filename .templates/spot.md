<img src="https://http.cat/404">

# Features

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-template
cp ~/.config/yazi/plugins/spot-template.yazi ~/.config/yazi/plugins/spot-{your-plugin-name}.yazi
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend plugin

# Usage

this is a template you can use to build your own custom spotter

in `~/.config/yazi/plugins/spot-{your-plugin-name}.yazi/main.lua`

```lua
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
```

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { url = "", run = "spot-{your-plugin-name}" },
  { mime = "", run = "spot-{your-plugin-name}" },
]
```

for customizing the spotter see [spot.yazi](/spot.yazi) documentation
