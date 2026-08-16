# Features

- different sorting for each directory
- remembers any changes in sorting
- better sorting keymaps

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:sort-by-location
```

# Usage

in `~/.config/yazi/init.lua`

```lua
require('sort-by-location'):setup {
  default = { by = 'extension', reverse = false }, -- required
  -- you can map the following actions to any key:
  -- none,mtime,btime,extension,alphabetical,natural,size,random,reverse
  keys = {
    extension = { 's', 'e' },
    mtime = { 's', 'm' },
    natural = { 's', 'n' },
    size = { 's', 's' }
  },
  { pattern = '.*/Pictures/.*', sort = { by = 'mtime', reverse = true } },  -- sorts sub-folders under Pictures by mtime
  { pattern = '.*/Downloads$', sort = { by = 'mtime', reverse = true } }, -- sorts Downloads folder by mtime
  { pattern = '.*/Videos/anime/.*', sort = { by = 'natural', reverse = false } }, -- sorts files naturally: 1, 2, 3, ..., 10, 11, 12
}
```
