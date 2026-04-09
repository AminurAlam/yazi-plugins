<img width="1920" height="1080" alt="preview showing output of `systemctl ststus`" src="https://github.com/user-attachments/assets/a8d79ea1-63e6-4d85-b67d-ca7c8d41bd87" />

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
