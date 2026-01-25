--- @since 25.5.31

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
---@field finder bool

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
---@alias FCharConf { insensitive: boolean, skip_symbols: boolean, skip_prefix: string[], search_location: "start"|"word"|"all", aliases: table<string, string> }

-- spot.yazi
---@alias SpotConf_plug { enable: boolean }
---@alias SpotConf_meta { enable: boolean, hash_cmd: "xxhsum"|"cksum"|"md5sum"|"sha1sum", hash_filesize_limit: number, relative_time: boolean, time_format: string }
---@alias SpotConf_style { section: AsColor, key: AsColor, value: AsColor, colorize_metadata: boolean, key_length: number, height: number, width: integer }
---@alias SpotConf { plugins_section: SpotConf_plug, metadata_section: SpotConf_meta, style: SpotConf_style }

---@alias Section { title: string }|table<number, table<string, Renderable>>
---@alias Sections table<number, Section>
