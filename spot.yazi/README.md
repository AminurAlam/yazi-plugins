<img width="1920" height="1080" alt="window with basic metadata" src="https://github.com/user-attachments/assets/d21595a6-d2ed-4133-b31a-14cf004c1631" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot
```

# Dependencies

- `cksum` (part of GNU coreutils) (optional)

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
      { '1', ui.Line('ONE'):fg('red') },
      { '2', ui.Line('TWO'):fg('magenta') },
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
    metadata_section = {
        enable = true,
        hash_cmd = 'cksum', -- other hashing commands can be slower
        hash_filesize_limit = 100, -- in MB, set 0 to disable
    },
    plugins_section = {
        enable = true,
    },
    style = {
        section = 'green',
        key = 'reset',
        value = 'blue',
        colorize_metadata = true,
        height = 20,
        width = 60,
        key_length = 15,
    },
}
```
