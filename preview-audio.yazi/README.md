<img width="1920" height="1080" alt="preview of alubum art and some audio metadata" src="https://github.com/user-attachments/assets/731bd9b8-b963-43c9-866e-4250885d0bbe" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-audio
```

# Dependencies

- [ffmpeg](https://repology.org/project/ffmpeg/versions) - for extracting images and metadata

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { mime = 'audio/mpegurl', run = 'code' }, # ignore .m3u files
  { mime = 'audio/*', run = 'preview-audio' },
]
prepend_preloaders = [
  { mime = 'audio/mpegurl', run = 'code' }, # ignore .m3u files
  { mime = 'audio/*', run = 'preview-audio' },
]
```
