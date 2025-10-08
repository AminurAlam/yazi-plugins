<img width="1920" height="1080" alt="Screenshot_20251008_144913_grim" src="https://github.com/user-attachments/assets/2f5b7d9a-50f4-4ce9-a920-b7f7d0156ad4" />

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
