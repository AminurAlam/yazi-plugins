<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/731bd9b8-b963-43c9-866e-4250885d0bbe" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:coverart
```

# Dependencies

- `ffmpeg`

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { mime = 'audio/mpegurl', run = 'code' }, # ignore .m3u files
  { mime = 'audio/*', run = 'coverart' },
]
prepend_preloaders = [
  { mime = 'audio/mpegurl', run = 'code' }, # ignore .m3u files
  { mime = 'audio/*', run = 'coverart' },
]
```
