# Description

jump to next/previous file that has a different extension, to quickly navigate large directories

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:nextension
```

# Usage

in `~/.config/yazi/keymap.toml`

```toml
# nextension [fwd|bwd]
[mgr]
prepend_keymap = [
  { on = "{", run = "plugin nextension bwd" },
  { on = "}", run = "plugin nextension fwd" },
]
```

in `~/.config/yazi/yazi.toml`

```toml
# recommended for better results
# but not necessary
[mgr]
sort_by = "extension"
```
