<img width="1920" height="1080" alt="Screenshot_20251008_150551_grim" src="https://github.com/user-attachments/assets/6d7dc8f8-f53c-4ce3-94e7-ff5e77dcef48" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-video
```

# Dependencies

- [spot.yazi](/spot.yazi)
- `ffprobe` (part of ffmpeg)

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { name = "video/*", run = "spot-video" }
]
```
