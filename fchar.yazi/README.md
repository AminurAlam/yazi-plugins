<img width="957" height="487" alt="list of files with highlighted matching characters" src="https://github.com/user-attachments/assets/b734d630-ab08-46a2-a6a0-acaf458d36c0" />

# Features

- case insensitive matching
- supports aliases for different languages
- ignores leading non-alphabet
- can match characters anywhere in filename

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

in `~/.config/yazi/init.lua`

```lua
-- default config
require('fchar'):setup {
  -- if true: f -> file, File, FILE
  insensitive = true,
  -- if true: f -> file, .file, @file, #file, ...file
  skip_symbols = true,
  -- if {"yazi-"}: f -> file, yazi-file
  skip_prefix = {},
  -- start: f -> file
  -- word:  f -> file, also-file
  -- all:   f -> file, also-file, alsofile, elf
  search_location = 'start',
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

-- you may want to turn off the search regex from
-- showing up in the header by doing this
function Header:flags()
  local cwd = self._current.cwd
  local filter = self._current.files.filter

  local t = {}
  if cwd.is_search then
    t[#t + 1] = string.format('search: %s', cwd.domain)
  end
  if filter then
    t[#t + 1] = string.format('filter: %s', filter)
  end
  return #t == 0 and '' or ' (' .. table.concat(t, ', ') .. ')'
end
```
