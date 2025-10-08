# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-audio
```

# Dependencies

- [spot.yazi](/spot.yazi)
- `mediainfo`
- `ffprobe` (part of ffmpeg, used as fallback)

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { name = "audio/*", run = "spot-audio" }
]
```
