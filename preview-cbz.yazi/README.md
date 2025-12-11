<img width="1920" height="1080" alt="Yokohama Kaidashi Kikou - Deluxe Edition volume 04" src="https://github.com/user-attachments/assets/f146f8d5-f862-425a-b438-ba591fdb14ce" />
<img width="1920" height="1080" alt="Ajin - Demi-Human volume 14" src="https://github.com/user-attachments/assets/5d3f31e1-f9d3-43c9-9833-96351819a412" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-cbz
```

# Dependencies

- unzip (for .cbz)
- unrar (for .cbr)
- grep
- sort

# Usage

in `~/.config/yazi/yazi.toml`

```toml
plugin.prepend_previewers = [
  { name = '*.cb{z,r}', run = 'preview-cbz' },
]

plugin.prepend_preloaders = [
  { name = '*.cb{z,r}', run = 'preview-cbz' },
]
```
