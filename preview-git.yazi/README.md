<img width="1920" height="1080" alt="preview of git remote get-url, git status, git log" src="https://github.com/user-attachments/assets/257f5167-c192-4152-a4c2-e2a2dfeb2895" />

shows the following things:

- remote urls
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
