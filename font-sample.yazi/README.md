Programming font with ligatures
![JetBrainsMono](https://github.com/user-attachments/assets/61626816-1334-4f9d-9e47-9ccdd42db03d)

Programming font with NerdFont icons (see glasses icon in second row)
![SauceCodePro](https://github.com/user-attachments/assets/092bcfaf-062b-4866-9bea-c53ae637471c)

Font with CJK characters
![NotoSansCJK](https://github.com/user-attachments/assets/0fd08a3d-9b56-43cf-b2ad-569b07273349)

Font with custom text
![GrapeNuts](https://github.com/user-attachments/assets/b93acb09-09df-4092-84b4-33384af6e0b6)

# Features

- easily check for common font features
  - `oO0`, `1lI` distinctions
  - ligatures
  - nerd font
- check if font has CJK characters
- define custom text to show
- define custom colours

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:font-sample
```

# Dependencies

- imagemagick

# Usage

in `~/.config/yazi/yazi.toml`

```toml
plugin.prepend_previewers = [
  { mime = 'font/*', run = 'font-sample' },
  { mime = 'application/ms-opentype', run = 'font-sample' },
  { name = '*.{otf,ttf,woff,woff2}', run = 'font-sample' },
]
plugin.prepend_preloaders = [
  { mime = 'font/*', run = 'font-sample' },
  { mime = 'application/ms-opentype', run = 'font-sample' },
  { name = '*.{otf,ttf,woff,woff2}', run = 'font-sample' },
]
```

in `~/.config/yazi/init.lua`

```lua
-- default config
require('font-sample'):setup {
  text = 'ABCD abcd\noO0 1lI \n0123456789\n@#$%%&=()[]{};\n== <= >= != ffi\n및개요これ直楽糸',
  canvas_size = '750x800',
  font_size = 80,
  -- https://imagemagick.org/script/color.php
  bg = 'white',
  fg = 'black',
}
```
