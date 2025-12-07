<img>

# Features

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-git
```

# Usage

in `~/.config/yazi/yazi.toml`

```toml
plugin.prepend_previewers = [
  { name = '**/.git/', run = 'preview-git' },
]
```
