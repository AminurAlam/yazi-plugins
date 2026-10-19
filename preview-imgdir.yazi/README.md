<img width="1920" height="1080" alt="yazi with a grid of images as directory preview" src="https://github.com/user-attachments/assets/5a6c0239-7639-4499-bb98-4c8952b4dce0" />

preview any directory that contains images

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-imgdir
```

# Dependencies

- [imagemagick](https://repology.org/project/imagemagick/versions) - for generating images

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { url = '/home/user/Pictures/*/', run = 'preview-imgdir' },
]

prepend_preloaders = [
  { url = '/home/user/Pictures/*/', run = 'preview-imgdir' },
]
```
