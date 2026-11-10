--- @since 25.5.31

---@diagnostic disable: duplicate-doc-alias
---@diagnostic disable: duplicate-doc-field

---@class Time
---@field unix number

---@class Job
---@field file File
---@field skip number
---@field units number
---@field mime string
---@field area ui.Rect|ui.Pos
---@field args string[]

---@class (exact) Command
---@field PIPED number

---@class (exact) tab__Tab
---@field finder boolean

---@class (exact) ya taken from yazi-plugin/src/utils/utils.rs
---@field iter fun(array: table): Iter
---@field json_decode fun(data: string): table?, Error?
---@field json_encode fun(data: table): string?, Error?
---@field spot_table fun(t: table, tt: Table): string?, Error?

---@class (exact) Table taken from yazi-binding/src/elements/table.rs
--- defined as methods
---@field header fun(self, header: Row): Table
---@field footer fun(self, footer: Row): Table
---@field widths fun(self, widths: ui.Constraint[]): Table
---@field spacing fun(self, spacing: integer): Table
---@field row fun(self, idx: integer?): Table
---@field col fun(self, idx: integer?): Table
---@field style fun(self, style: ui.Style): Table
---@field row_style fun(self, style: ui.Style): Table
---@field col_style fun(self, style: ui.Style): Table
---@field cell_style fun(self, style: ui.Style): Table
--- defined in impl
---@field area fun(self, area: ui.Rect|ui.Pos): Table
---
---@field rows Row[]
---@field header Row?
---@field footer Row?
---@field widths ui.Constraint[]
---@field column_spacing integer
---@field style ui.Style
---@field row_highlight_style ui.Style
---@field column_highlight_style ui.Style
---@field cell_highlight_style ui.Style

--@field flex ratatui_core::layout::Flex
--@field state ratatui_widgets::table::TableState
--@field block ui.Block? // TODO
--@field highlight_symbol ui.Text // TODO
--@field highlight_spacing 'Always'|'WhenSelected'|'Never' // TODO

---@class (exact) Row
---@field cells ui.Text[]
---@field height integer
---@field top_margin integer
---@field bottom_margin integer
---@field style ui.Style

---@class (exact) Iter
---@field all fun(self, f: function): boolean, Error? returns whether every item passes `f`
---@field any fun(self, f: function): boolean, Error? returns whether at least one item passes `f`
---@field each fun(self, f: function): boolean, Error? calls `f` for each item and returns when iteration is complete
---@field enumerate fun(self): Iter adds a 1-based index to each item
---@field filter fun(self, f: function): Iter keeps items for which `f` returns a truthy value
---@field find fun(self, f: function): any?, Error? returns the first item for which `f` returns a truthy value
---@field flat_map fun(self, f: function): Iter maps each item to another iterator and flattens the results
---@field fold fun(self, init: any, f: function): any?, Error? reduces the iterator to one value, starting with init
---@field into fun(self, out?: table): table?, Error? collects the iterator into out, creates a new table if omitted
---@field kw fun(self): Iter switches to key-value mode
---@field map fun(self, f: function): Iter transforms each item with `f`
---@field pack fun(self): table?, Error? collects all values returned by each iteration into packed tuples, similar to `table.pack`
---@field skip fun(self, n: integer): Iter skips the first `n` items
---@field take fun(self, n: integer): Iter yields at most `n` items
---@field take_while fun(self, f: function): Iter yields items while `f` returns a truthy value
---@field try fun(self): Iter treats `Error` values as iteration errors
---@field unzip fun(self, n: 1): table, Error?
---@field unzip fun(self, n: 2): table, table, Error?
---@field unzip fun(self, n: 3): table, table, table, Error?
--@field unzip fun(self, n: integer): table..., Error? splits the first `n` returned values into separate arrays

---@class (exact) ui
---@field truncate fun(data: string, opts: table): string
---@field redraw fun(data: table): table
---@field Row fun(row: table): Row
---@field Table fun(rows: Row[]): Table

---@class (exact) fs
---@field calc_size fun(url: Url): integer
---@field read_dir fun(url: Url): DirEntry[]?, Error?

---@class (exact) DirEntry
---@field name string  - the directory entry name
---@field url string - the directory entry URL
---@field lstat fun(self): any?, Error? - gets the entry's `Stat` without following symlinks
---@field file fun(self): File?, Error? - gets the entry's `File`

---@class (exact) rt
---@field plugin { fetchers: plugin, spotters: plugin, previewers: plugin, preloaders: plugin }

---@class (exact) rt__Args
---@field chooser_file Url?

---@class (exact) plugin
---@field insert fun(self: plugin, id: integer, data: table)
---@field match fun(self: plugin, data: table?): { id: integer, url: Url?, mime: string?, run: { name: string } }[]
---@field remove fun(self: plugin, data: table)

---@class th

-- keys
---@alias Key string|string[]

-- imgdir.yazi
---@alias ImgDirConf { cols: integer, rows: integer, width: integer, height: integer, background: string, urls: string[] }

-- fchar.yazi
---@alias FCharConf { insensitive: boolean, skip_symbols: boolean, skip_prefix: string[], aliases: table<string, string>, keys: {start: Key?, ext: Key?, word: Key?, all: Key?} }

-- spot.yazi
---@alias SpotConf_plug { enable: boolean }
---@alias SpotConf_meta { enable: boolean, hash_cmd: "xxhsum"|"cksum"|"md5sum"|"sha1sum", hash_filesize_limit: number, relative_time: boolean, time_format: string, show_compression: boolean }
---@alias SpotConf_style_color { metadata: boolean, title: AsColor, key: AsColor, value: AsColor, selected: AsColor }
---@alias SpotConf_style_size  { height: integer, width: integer, auto_resize: boolean, min_width: integer, max_width: integer, min_height: integer, max_height: integer }
---@alias SpotConf_style { color: SpotConf_style_color, size: SpotConf_style_size, max_key_length: integer, key_indent_size: number }
---@alias SpotConf { plugins_section: SpotConf_plug, metadata_section: SpotConf_meta, style: SpotConf_style }

---@alias Section { title: string }|table<number, table<string, Renderable>>
---@alias Sections Section[]

-- sort-by-location.yazi
---@alias SortTypes "none"|"mtime"|"btime"|"extension"|"alphabetical"|"natural"|"size"|"random"
---@alias SortTable { by: SortTypes, reverse: boolean }
---@alias SortConf table<integer, {pattern: string, sort: SortTable}>|{default: SortTable, keys: table<SortTypes, Key>}
