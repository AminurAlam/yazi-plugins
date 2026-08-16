# Description

jump to next/previous file that has a different extension, to quickly navigate large directories

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:nextension
```

# Usage

in `~/.config/yazi/init.lua`

```lua
-- this is optional, use this if you want to change the default bindings
require('nextension'):setup { fwd = '}', bwd = '{' }
```

in `~/.config/yazi/yazi.toml`

```toml
# recommended for better results
# but not necessary
[mgr]
sort_by = "extension"
```
