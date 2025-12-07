<img width="1920" height="1080" alt="schema of a database" src="https://github.com/user-attachments/assets/98d105a9-14ff-409a-8c73-a7db42b782d0" />

shows the schema of a sqlite database

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:preview-sqlite
```

# Dependencies

- sqlite3

# Usage

in `~/.config/yazi/yazi.toml`

```toml
plugin.prepend_previewers = [
  { name = '*.sqlite3', run = 'preview-sqlite' },
  { mime = 'application/sqlite3', run = 'preview-sqlite' },
]
```
