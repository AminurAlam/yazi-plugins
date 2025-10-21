<img width="1920" height="1080" alt="Screenshot_20251008_164140_grim" src="https://github.com/user-attachments/assets/e1dde089-f880-458b-bff6-1c252d52b549" />

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
