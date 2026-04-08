<img width="1920" height="1080" alt="Screenshot_20260408_214859_niri" src="https://github.com/user-attachments/assets/da406b2b-87a9-4936-9af7-8b603d87bb46" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-torrent
```

# Dependencies

- [aria2](https://repology.org/project/aria2/versions) - for fetching torrent info

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { url = '*.torrent', run = 'preview-torrent' },
  { mime = 'application/bittorrent', run = 'preview-torrent' },
]
```
