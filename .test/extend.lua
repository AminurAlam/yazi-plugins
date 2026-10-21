local function tbl_eq(o1, o2)
  if o1 == o2 then
    return true
  end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then
    return false
  end
  if o1Type ~= 'table' then
    return false
  end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or tbl_eq(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then
      return false
    end
  end
  return true
end

local function tbl_extend(default, config)
  if type(default) ~= type(config) then
    return default
  end

  if type(default) ~= 'table' then
    if config ~= nil then
      return config
    else
      return default
    end
  end

  local count = 0
  for key, _ in pairs(default) do
    default[key] = tbl_extend(default[key], config[key])
    count = count + 1
  end

  -- the left table was empty so we
  -- probably always want the right table
  if count == 0 then
    return config
  end

  return default
end

local aex = function(l, r, out)
  assert(tbl_eq(tbl_extend(l, r), out))
end

assert(nil == tbl_extend(nil, nil))
assert(nil == tbl_extend(nil, false))
assert(nil == tbl_extend(nil, 1))
assert(nil == tbl_extend(nil, 'right'))

assert(true == tbl_extend(true, nil))
assert(false == tbl_extend(true, false))
assert(true == tbl_extend(true, 1))
assert(true == tbl_extend(true, 'right'))

assert(0 == tbl_extend(0, nil))
assert(0 == tbl_extend(0, false))
assert(1 == tbl_extend(0, 1))
assert(0 == tbl_extend(0, 'right'))

assert('left' == tbl_extend('left', nil))
assert('left' == tbl_extend('left', false))
assert('left' == tbl_extend('left', 1))
assert('right' == tbl_extend('left', 'right'))

assert(0 == tbl_extend(0, nil))
assert(0 == tbl_extend(0, false))
assert(1 == tbl_extend(0, 1))
assert(0 == tbl_extend(0, 'right'))

aex({}, {}, {})
aex({}, { nil }, {})
aex({}, { true }, { true })
aex({}, { false }, { false })
aex({}, { 0 }, { 0 })
aex({}, { 1 }, { 1 })
aex({}, { 'right' }, { 'right' })

aex({}, {}, {})
aex({ nil }, {}, {})
aex({ true }, {}, { true })
aex({ false }, {}, { false })
aex({ 0 }, {}, { 0 })
aex({ 1 }, {}, { 1 })
aex({ 'right' }, {}, { 'right' })

aex({}, {}, {})
aex({ nil }, { nil }, {})
aex({ true }, { true }, { true })
aex({ false }, { false }, { false })
aex({ 0 }, { 0 }, { 0 })
aex({ 1 }, { 1 }, { 1 })
aex({ 'right' }, { 'right' }, { 'right' })

aex({}, {}, {})
aex({ true }, { false }, { false })
aex({ 0 }, { 1 }, { 1 })
aex({ 'left' }, { 'right' }, { 'right' })

aex({ a = true, b = false, c = {} }, { a = false }, { a = false, b = false, c = {} })
aex({ a = true, b = false, c = {} }, {}, { a = true, b = false, c = {} })
aex({ a = true, b = false, c = {} }, { b = 1 }, { a = true, b = false, c = {} })
aex({ a = true, b = false, c = {} }, { b = nil }, { a = true, b = false, c = {} })
aex({ a = true, b = false, c = {} }, { b = 'right' }, { a = true, b = false, c = {} })
aex({ a = true, b = false, c = {} }, { a = {}, b = {}, c = {} }, { a = true, b = false, c = {} })

aex({ a = true, b = {} }, { a = nil, b = nil }, { a = true, b = {} })
aex({ a = true, b = {} }, { a = {}, b = {} }, { a = true, b = {} })
aex({ a = true, b = {} }, { a = { 1 }, b = { false } }, { a = true, b = { false } })
aex({ a = true, b = {} }, { a = 'right', b = { 'right' } }, { a = true, b = { 'right' } })

aex({ a = {} }, { a = { 'right' } }, { a = { 'right' } })
aex({ a = {} }, { b = { 'right' } }, { a = {} })
aex({ a = {} }, { a = { 1, 2, 3 } }, { a = { 1, 2, 3 } })
aex({ a = {} }, { a = { { {} } } }, { a = { { {} } } })
aex({ a = {} }, { a = { { { false }, nil, true } } }, { a = { { { false }, nil, true } } })

aex({ a = { 0 } }, { a = {} }, { a = { 0 } })
aex({ a = { 0 } }, { a = { 1 } }, { a = { 1 } })
aex({ a = { 0 } }, { a = { 1, 2, 3, 4 } }, { a = { 1 } })

aex(
  { a = { foo = 'hello', bar = 'world' } },
  { a = { 1, 2, 3, 4 } },
  { a = { foo = 'hello', bar = 'world' } }
)
aex(
  { a = { foo = 'hello', bar = 'world' } },
  { a = { foo = nil } },
  { a = { foo = 'hello', bar = 'world' } }
)
aex(
  { a = { foo = 'hello', bar = 'world' } },
  { a = { foo = false } },
  { a = { foo = 'hello', bar = 'world' } }
)
aex(
  { a = { foo = 'hello', bar = 'world' } },
  { a = { foo = 'right' } },
  { a = { foo = 'right', bar = 'world' } }
)
aex(
  { a = { foo = 'hello', bar = 'world' } },
  { a = { baz = 'right' } },
  { a = { foo = 'hello', bar = 'world' } }
)
