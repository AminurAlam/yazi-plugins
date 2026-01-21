<img width="1920" height="1080" alt="window with basic metadata" src="https://github.com/user-attachments/assets/4cd526bb-11fe-4aa5-9d2c-27328fab37c9" />

spot.yazi + [spot-video.yazi](/spot-video.yazi)
<img width="1920" height="1080" alt="another window showing multiple streams" src="https://github.com/user-attachments/assets/933b124d-4f1f-44f2-b1d8-128a3fcbdf5d" />

spot.yazi + [spot-audio.yazi](/spot-audio.yazi)
<img width="1920" height="1080" alt="window showing audio metadata" src="https://github.com/user-attachments/assets/d6eef132-bbba-4eb3-bb29-0527a38699d8" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot
```

# Dependencies

- `cksum`/`md5sum`/`sha256sum` - optional dependency for showing unique file hash

# Usage

<!-- TODO: move custom stuff to template -->

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
  # use the plugin for a specific mime type
  { mime = "audio/*", run = "spot" },
  # use your custom spotter that you wrote in `yazi/plugins/spot-custom.yazi/main.lua`
  { mime = "video/*", run = "spot-custom" },
  # use as a spotter for all directories
  { mime = "*/", run = "spot" },
  # use as a fallback for all files that don't have a spotter
  { mime = "*", run = "spot" },
]
```

in `~/.config/yazi/init.lua`

```lua
require('spot'):setup {
  metadata_section = {
    enable = true,
    hash_cmd = 'cksum', -- other hashing commands can be slower
    hash_filesize_limit = 150, -- in MB, set 0 to disable
    relative_time = true,
    time_format = '%Y-%m-%d %H:%M', -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
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
