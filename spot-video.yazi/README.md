<img width="1920" height="1080" alt="window showing multiple video and audiostreams" src="https://github.com/user-attachments/assets/0a6a9844-d606-416e-9167-540e04c2c4ec" />

<img width="1920" height="1080" alt="another window showing multiple streams" src="https://github.com/user-attachments/assets/933b124d-4f1f-44f2-b1d8-128a3fcbdf5d" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-video
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend plugin
- [ffmpeg](https://repology.org/project/ffmpeg/versions) - for extracting metadata

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { url = "video/*", run = "spot-video" }
]
```

for customizing the spotter see [spot.yazi](/spot.yazi) documentation
