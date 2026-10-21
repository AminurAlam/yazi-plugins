local M = {}

local set_config = ya.sync(function(st, opts)
  st.opts = opts
end)

local get_config = ya.sync(function(st)
  return st.opts
    or { --
      text = 'ABCDEF abcdef\n0123456789 \noO08 iIlL1 g9qCGQ\n8%& <([{}])>\n.,;: @#$-_="\n== <= >= != ffi\nâéùïøçÃĒÆœ\n및개요これ直楽糸',
      canvas_size = '750x800',
      font_size = 80,
      fg = 'black',
      bg = 'white',
      mimes = { 'font/*' },
      urls = { '*.{otf,ttf,woff,woff2}' },
    }
end)

function M:setup(config)
  local default = get_config()
  for k, v in pairs(default) do
    default[k] = config[k] or v
  end
  set_config(default)

  for _, mime in ipairs(default.mimes or {}) do
    rt.plugin.previewers:insert(1, { mime = mime, run = 'preview-xxx' })
    rt.plugin.preloaders:insert(1, { mime = mime, run = 'preview-xxx' })
  end
  for _, url in ipairs(default.urls or {}) do
    rt.plugin.previewers:insert(1, { url = url, run = 'preview-xxx' })
    rt.plugin.preloaders:insert(1, { url = url, run = 'preview-xxx' })
  end
end

function M:peek(job)
  local start, cache = os.clock(), ya.file_cache(job)
  if not cache then
    return
  end

  local ok, err

  ok, err = self:preload(job)
  if not ok or err then
    return
  end

  ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

  _, err = ya.image_show(cache, job.area)
  ya.preview_widget(job, err and ui.Text(err):area(job.area))
end

-- TODO: change text on seek
function M:seek() end

function M:preload(job)
  local cache = ya.file_cache(job)
  if not cache or fs.cha(cache) then
    return true
  end
  local opts = get_config()

  local status, err = Command('magick'):arg({
    '-size',
    opts.canvas_size,
    '-gravity',
    'center',
    '-font',
    tostring(job.file.path):gsub('\\', '\\\\'),
    '-pointsize',
    opts.font_size,
    'xc:' .. opts.bg,
    '-fill',
    opts.fg,
    '-annotate',
    '+0+0',
    opts.text,
    'PNG:' .. tostring(cache),
  }):status()

  if status then
    return status.success
  else
    return true, Err('Failed to start `magick`, error: %s', err)
  end
end

return M
