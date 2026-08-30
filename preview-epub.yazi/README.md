<img width="1920" height="1080" alt="Cover of Manufacturing Consent by Edward S. Herman and Noam Chomsky" src="https://github.com/user-attachments/assets/d0d130eb-8ec1-46b5-8546-107176fb65ec" />

<img width="1920" height="1080" alt="Cover of Too Many Losing Heroines! volume 02" src="https://github.com/user-attachments/assets/f5934595-c5ea-47ae-a7f5-327721543bdd" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-epub
```

# Dependencies

Install at least one of:

- [gnome-epub-thumbnailer](https://repology.org/project/gnome-epub-thumbnailer/versions)
  — renders a thumbnail from the cover art or the first page. Linux-only.
- [Calibre](https://calibre-ebook.com/) (`ebook-meta`) — extracts the cover
  image only. Cross-platform (Linux, macOS, Windows).

The plugin checks which is installed at runtime and uses it automatically,
preferring `gnome-epub-thumbnailer` when present.

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { mime = '', run = 'preview-epub' },
]

prepend_preloaders = [
  { mime = '', run = 'preview-epub' },
]
```

# How it works

Which backend gets used is decided at runtime, then remembered for the rest of
the session:

1. `gnome-epub-thumbnailer -s 0 <file.epub> <cache>` — thumbnail (cover or first page)
2. `ebook-meta --get-cover <cache> <file.epub>` — cover image only
