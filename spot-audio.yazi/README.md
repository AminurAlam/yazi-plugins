<img width="1920" height="1080" alt="window showing audio metadata" src="https://github.com/user-attachments/assets/d6eef132-bbba-4eb3-bb29-0527a38699d8" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-audio
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend plugin
- [ffmpeg](https://repology.org/project/ffmpeg/versions) - for extracting metadata
- [mediainfo](https://repology.org/project/mediainfo/versions) - used as fallback when ffmpeg is not available

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { mime = 'audio/mpegurl', run = 'code' }, # ignore .m3u files
  { url = "audio/*", run = "spot-audio" },
]
```

for customizing the spotter see [spot.yazi](/spot.yazi) documentation
