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

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  # use the plugin for a specific mime type
  { mime = "audio/*", run = "spot" },
  # use as a spotter for all directories
  { url = "*/", run = "spot" },
  # use as a fallback for all files that don't have a spotter
  { url = "*", run = "spot" },
]
```

in `~/.config/yazi/init.lua`

```lua
require('spot'):setup {
  metadata_section = {
    enable = true,
    hash_cmd = 'xxhsum', -- other hashing commands may be slower
    hash_filesize_limit = 150, -- in MB, set 0 to disable
    relative_time = true, -- 2026-01-01 or n days ago
    time_format = '%Y-%m-%d %H:%M', -- https://www.man7.org/linux/man-pages/man3/strftime.3.html
    show_compression = 'size', ---@type false|"size"|"percentage"
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

# Footnote

see [spot-template.yazi](/spot-template.yazi) to make your own spotter

list of plugins using spot.yazi as a base

- [spot-audio.yazi](/spot-audio.yazi)
- [spot-video.yazi](/spot-video.yazi)
- [spot-cbz.yazi](/spot-cbz.yazi)

if you are building something on top of spot.yazi feel free to add it here
