# Features

- different sorting for each directory
- remembers any changes in sorting
- better sorting keymaps

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:sort-by-location
```

# Usage

in `~/.config/yazi/keymap.toml`

```toml
# sort-by-location [none|mtime|btime|extension|alphabetical|natural|size|random|reverse]
# you can also reverse sort by pressing the same keymap again
[mgr]
prepend_keymap = [
  { on = ["s", "s"], run = "plugin sort-by-location size", desc = "Sort by size" },
  { on = ["s", "m"], run = "plugin sort-by-location mtime", desc = "Sort by mtime" },
  { on = ["s", "r"], run = "plugin sort-by-location reverse", desc = "Reverse sorting order" },
]
```

in `~/.config/yazi/init.lua`

```lua
require('sort-by-location'):setup {
  default = { by = 'extension', reverse = false }, -- required
  { pattern = '.*/Pictures/.*', sort = { by = 'mtime', reverse = true } },  -- sorts sub-folders under Pictures by mtime
  { pattern = '.*/Downloads$', sort = { by = 'mtime', reverse = true } }, -- sorts Downloads folder by mtime
  { pattern = '.*/Videos/anime/.*', sort = { by = 'natural', reverse = false } }, -- sorts files naturally: 1, 2, 3, ..., 10, 11, 12
}
```
