<img width="1920" height="1080" alt="preview of git remote get-url, git status, git log" src="https://github.com/user-attachments/assets/ec8a7334-a4cf-41b1-b85a-c609e48e3217" />

shows the following things:

- remote url (origin and upstream)
- git status
- git log of recent commits

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-git
```

# Usage

in `~/.config/yazi/yazi.toml`

```toml
plugin.prepend_previewers = [
  { url = '**/.git/', run = 'preview-git' },
]
```
