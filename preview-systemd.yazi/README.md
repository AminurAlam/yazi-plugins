<img src="https://http.cat/404">

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-systemd
```

# Dependencies

- [systemd](https://repology.org/project/systemd/versions) - for managing service files

# Usage

in `~/.config/yazi/yazi.toml`

```toml
[plugin]
prepend_previewers = [
  { url = "*.service", run = "preview-systemd" },
]
```
