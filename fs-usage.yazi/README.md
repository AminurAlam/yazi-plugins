<img width="1920" height="1080" alt="yazi with a bar in top-right showing storage usage" src="https://github.com/user-attachments/assets/4120c1e2-20ad-4a44-aff0-d17980b9e851" />

this plugin was forked from <https://github.com/walldmtd/fs-usage.yazi>

# Additional Features

- works with toybox's `df`
- uses a minimum size for bar
- shows mount point instead of file system

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:fs-usage
```

# Usage

in `~/.config/yazi/init.lua`

```lua
require('fs-usage'):setup({
  -- All values are optional

  -- Position of the component
  --   parent: Parent component ("Header" or "Status")
  --   align: Anchor point within parent object ("LEFT" or "RIGHT")
  --   order: Order relative to others in the same parent
  -- Default: { parent = "Header", align = "RIGHT", order = 2000 }
  position = { parent = "Header", align = "RIGHT", order = 2000 },

  -- Text format
  -- One of:
  --   "both": Partition name and percent used
  --   "name": Only partition name
  --   "usage": Only percent used
  -- Default: "both"
  format = "both",

  -- Option to enable or disable the usage bar
  -- Default: true
  bar = true,

  -- Percent usage to use the warning style (-1 to disable)
  -- Default: 90
  warning_threshold = 90,

  -- Makes sure that the bar has a minimum size
  -- Default: 12
  min_width = 12,

  -- For style options, any unset options use the progress bar style
  --   from the Yazi flavor if available, otherwise it falls back to
  --   the default Yazi style.

  -- Label text style
  --   fg: Text colour (String like "white", or hex like "#ffffff")
  --      (Can also be "" to use the reverse of the bar colour)
  --   bold: Make the label bold (bool)
  --   italic: Make the label italic (bool)
  -- Example: style_label = { fg = "", bold = true, italic = false },
  -- Default: {}
  style_label = {},

  -- Usage bar style
  --   fg: Bar colour (String like "blue", or hex like "#0000ff")
  --   bg: Bar background colour (Same format as fg)
  -- Example: style_normal = { fg = "blue", bg = "black" },
  -- Default: {}
  style_normal = {},

  -- Usage bar style when the used space is above the warning threshold
  -- Options are the same as style_normal
  -- Default: {}
  style_warning = {},

  -- Bar padding
  --   open: Character on the left (string)
  --   close: Character on the right (string)
  -- Example: { open = "█", close = "█" } for square corners,
  --   or { open = "", close = "" } for no padding
  -- Default: { open = "", close = "" }
  padding = { open = "", close = "" }
})
```
