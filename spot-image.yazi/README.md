<img width="1920" height="1080" src="https://github.com/user-attachments/assets/1c7b0b09-40bd-47db-9631-73961aaa88e2" />

# Features

- shows exif data of an image

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-image
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend plugin
- [exiftool](https://repology.org/project/exiftool/versions) - for getting exif data

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { mime = "image/*", run = "spot-image" },
]
```

for customizing the spotter see [spot.yazi](/spot.yazi) documentation
