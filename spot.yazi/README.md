<img width="1920" height="1080" alt="Screenshot_20251008_142605_grim" src="https://github.com/user-attachments/assets/d21595a6-d2ed-4133-b31a-14cf004c1631" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot
```

# Dependencies

- `cksum` (part of GNU coreutils)

# Usage

this plugin can be used as a spotter for basic metadata or used to build your own custom spotter

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

in `~/.config/yazi/init.lua`

```lua
require('spot'):setup {
  height = 20,
  width = 60,
  render_metadata = true,
  render_plugins = false,
}
```
