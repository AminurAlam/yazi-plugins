<img width="1920" height="1080" alt="Screenshot_20260125_212320_niri" src="https://github.com/user-attachments/assets/d52e6103-e811-49c8-95fb-96deb1973598" />

<img width="1920" height="1080" alt="Screenshot_20260125_212346_niri" src="https://github.com/user-attachments/assets/d4da6108-f0ec-464b-9891-a61b3c41c378" />

# Features

- shows exif data of an image

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-image
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend plugin
- [exiv2](https://repology.org/project/exiv2/versions) - for getting exif data

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { mime = "image/*", run = "spot-image" },
]
```

for customizing the spotter see [spot.yazi](/spot.yazi) documentation
