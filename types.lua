--- @since 25.5.31

---@diagnostic disable: duplicate-doc-alias
---@diagnostic disable: duplicate-doc-field

---@type File
File = File

---@class Job
---@field file File
---@field skip number
---@field units number
---@field mime string
---@field area ui.Rect
---@field args string[]

---@class (exact) Command
---@field PIPED number

---@class (exact) tab__Tab
---@field finder boolean

---@class (exact) ya
---@field manager_emit fun(command: string, opts: table)
---@field json_decode fun(data: string): table
---@field image_info fun(path: Url): table

---@class (exact) ui
---@field truncate fun(data: string, opts: table): string
---@field redraw fun(data: table): table

---@class (exact) fs
---@field calc_size fun(url: Url): integer

---@class th

-- fchar.yazi
---@alias FCharConf { insensitive: boolean, skip_symbols: boolean, skip_prefix: string[], search_location: "start"|"ext"|"word"|"all", aliases: table<string, string> }

-- spot.yazi
---@alias SpotConf_plug { enable: boolean }
---@alias SpotConf_meta { enable: boolean, hash_cmd: "xxhsum"|"cksum"|"md5sum"|"sha1sum", hash_filesize_limit: number, relative_time: boolean, time_format: string, show_compression: boolean }
---@alias SpotConf_style_color { metadata: boolean, title: AsColor, key: AsColor, value: AsColor, selected: AsColor }
---@alias SpotConf_style_size  { height: integer, width: integer, auto_resize: boolean, min_width: integer, max_width: integer, min_height: integer, max_height: integer }
---@alias SpotConf_style { color: SpotConf_style_color, size: SpotConf_style_size, max_key_length: integer, key_indent_size: number }
---@alias SpotConf { plugins_section: SpotConf_plug, metadata_section: SpotConf_meta, style: SpotConf_style }

---@alias Section { title: string }|table<number, table<string, Renderable>>
---@alias Sections table<number, Section>

-- sort-by-location.yazi
---@alias SortTable { by: "none"|"mtime"|"btime"|"extension"|"alphabetical"|"natural"|"size"|"random", reverse: boolean }
---@alias SortConf table<integer, {pattern: string, sort: SortTable}>|table<"default", SortTable>
