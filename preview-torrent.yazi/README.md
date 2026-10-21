<img width="1920" height="1080" alt="preview showing output of `aria2c -S filename.torrent`" src="https://github.com/user-attachments/assets/da406b2b-87a9-4936-9af7-8b603d87bb46" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-torrent
```

# Dependencies

- [aria2](https://repology.org/project/aria2/versions) - for fetching torrent info

# Usage

in `~/.config/yazi/init.lua`

```lua
require('preview-torrent').setup()
```
