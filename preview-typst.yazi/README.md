<img width="1920" height="1080" alt="" src="https://github.com/user-attachments/assets/899f1b0c-0887-40bb-958c-499f3f3cc3bd" />

<img width="1920" height="1080" alt="" src="https://github.com/user-attachments/assets/50b9aed8-7b3e-4a16-a397-af28bf4d2cc4" />

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-typst
```

# Dependencies

- [typst](https://repology.org/project/typst/versions)

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { url = '*.typ', run = 'preview-typst' },
]

prepend_preloaders = [
  { url = '*.typ', run = 'preview-typst' },
]
```
