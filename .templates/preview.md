<img src="https://http.cat/404">

# Features

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-template
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend
- foo
- bar

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { url = '', run = 'preview-template' },
  { mime = '', run = 'preview-template' },
]

prepend_preloaders = [
  { url = '', run = 'preview-template' },
  { mime = '', run = 'preview-template' },
]
```
