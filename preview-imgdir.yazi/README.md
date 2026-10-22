<img width="1920" height="1080" alt="yazi with a grid of images as directory preview" src="https://github.com/user-attachments/assets/5a6c0239-7639-4499-bb98-4c8952b4dce0" />

preview directory that contains images as a grid of images

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-imgdir
```

# Dependencies

- [imagemagick](https://repology.org/project/imagemagick/versions) - for generating images

# Usage

in `~/.config/yazi/init.lua`

```lua
-- default config
require('preview-imgdir').setup({
  cols = 2,
  rows = 3,
  width = 480,
  height = 480,
  background = '#fff',
  urls = {},
})

-- pass directories on which the previewer should run
require('preview-imgdir').setup({
  urls = {
    '/home/user/Video/screenshots/*/', -- use for a list of dirs
    '/home/user/Pictures/**/', -- use for all subdirectories
    '/home/user/Pictures/{cats,dogs}/', -- use for some specific dirs
    ...
  }
})
```
