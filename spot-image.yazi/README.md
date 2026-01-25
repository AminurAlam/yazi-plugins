<img width="1920" height="1080" alt="Screenshot_20260125_212320_niri" src="https://github.com/user-attachments/assets/d52e6103-e811-49c8-95fb-96deb1973598" />

<img width="1920" height="1080" alt="Screenshot_20260125_212346_niri" src="https://github.com/user-attachments/assets/d4da6108-f0ec-464b-9891-a61b3c41c378" />

# Features

- shows exif data of an image

# Downsides

- slow for large images (5MB+)

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:spot AminurAlam/yazi-plugins:spot-image
```

# Dependencies

- [spot.yazi](/spot.yazi) - backend plugin
- [imagemagick](https://repology.org/project/imagemagick/versions) - for getting metadata
- [inkscape](https://repology.org/project/inkscape/versions) - for getting svg info (optional)

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_spotters = [
  { mime = "image/*", run = "spot-image" },
]
```

for customizing the spotter see [spot.yazi](/spot.yazi) documentation
