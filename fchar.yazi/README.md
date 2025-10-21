<img width="957" height="487" alt="Screenshot_20251021_225047_grim" src="https://github.com/user-attachments/assets/b734d630-ab08-46a2-a6a0-acaf458d36c0" />

# Features

- case insensitive
- supports aliases
- ignores leading non-alphabet

# Installation

```sh
ya pkg add AminurAlam/yazi-plugins:fchar
```

# Usage

in `~/.config/yazi/keymap.toml`

```toml
[mgr]
prepend_keymap = [
  { on = "f", run = "plugin fchar", desc = "Jump to char" },
]
```

# Configuration

in `~/.config/yazi/init.lua`

```lua
-- default config
require('fchar'):setup {
  insensitive = true,
  keep_searching = { enable = false, limit = 10 },
  aliases = {},
}

-- aliases for German
require('fchar'):setup {
  aliases = {
    a = 'ä',
    o = 'ö',
    u = 'ü',
    s = 'ß'
  },
}

-- aliases for Japanese
require('fchar'):setup {
  aliases = {
    a = 'あア',
    b = 'ばびぶべぼバビブベボ',
    c = 'ちチ',
    d = 'だぢづでどダヂヅデド',
    e = 'えエ',
    g = 'がぎぐげごガギグゲゴ',
    h = 'はひふへほハヒフヘホ',
    i = 'いイ',
    j = 'じジ',
    k = 'かきくけこカキクケコ',
    m = 'まみむめもマミムメモ',
    n = 'なにぬねのんナニヌネノン',
    o = 'おオ',
    p = 'ぱぴぷぺぽパピプペポ',
    r = 'らりるれろラリルレロ',
    s = 'さしすせそサシスセソ',
    t = 'たつてとタツテト',
    u = 'うウ',
    w = 'わをワヲ',
    y = 'やゆよヤユヨ',
    z = 'ざずぜぞザズゼゾ',
  },
}
```
