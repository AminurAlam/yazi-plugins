# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot
```

# Dependencies

- `cksum` (part of GNU coreutils)

# Usage

in `~/.config/yazi/plugins/spot-custom.yazi/main.lua`

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
      { '1', 'ONE' },
      { '2', 'TWO' },
    },
  })
end

return M
```

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { name = "audio/*", run = "spot" }, # use the plugin with default settings
  { name = "video/*", run = "spot-custom" }, # use your custom spotter
]
```
