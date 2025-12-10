<img width="1920" height="1080" alt="window showing metadata of a manga chapter" src="https://github.com/user-attachments/assets/7f56cdc8-83fe-4ebf-8b97-0bfa0a8a24ad" />

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
