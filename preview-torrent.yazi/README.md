<img src="https://http.cat/404">

# Features

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-torrent
```

# Dependencies

- foo

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { url = '*.torrent', run = 'preview-torrent' },
  { mime = 'application/bittorrent', run = 'preview-torrent' },
]
```
