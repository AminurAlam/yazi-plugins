# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot-video
```

# Dependencies

- `ffprobe` (part of ffmpeg)

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { name = "video/*", run = "spot-video" }
]
```
