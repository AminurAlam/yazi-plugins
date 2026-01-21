<img width="1920" height="1080" alt="Cover of Manufacturing Consent by Edward S. Herman and Noam Chomsky" src="https://github.com/user-attachments/assets/d0d130eb-8ec1-46b5-8546-107176fb65ec" />

<img width="1920" height="1080" alt="Cover of Too Many Losing Heroines! volume 02" src="https://github.com/user-attachments/assets/f5934595-c5ea-47ae-a7f5-327721543bdd" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-epub
```

# Dependencies

- [gnome-epub-thumbnailer](https://repology.org/project/gnome-epub-thumbnailer/versions)

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
