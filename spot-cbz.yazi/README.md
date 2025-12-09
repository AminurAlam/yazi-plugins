<img>

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot-cbz
```

# Dependencies

- unzip

# Usage

in `~/.config/yazi/yazi.toml`

```toml
plugin.prepend_spotters = [
  { name = '*.cb{z,r}', run = 'spot-cbz' },
]
```
