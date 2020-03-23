package.path = './src/?.lua;' .. package.path

local test = require('gambiarra')
local cd = require('covid-data')


local passed, failed, errored = 0, 0, 0
test(function(ev, fn, msg)
  if ev == 'begin' then
    io.write(string.format('-- Tests started for: %s\n', fn))
  elseif ev == 'pass' then
    passed = passed + 1
    io.write(string.format('[[32m✓[0m] %s\n', msg))
  elseif ev == 'fail' then
    failed = failed + 1
    io.write(string.format('[[31m✗[0m] %s\n', msg))
  elseif ev == 'except' then
    errored = errored + 1
    io.write(string.format('[[33m![0m] %s\n', msg))
  elseif ev == 'end' then
    io.write('\n')
  end
end)

local function report()
  local count = passed + failed + errored
  local stats = string.format('Passed: %d/%d; Failed: %d/%d; Errored: %d/%d', passed, count, failed,
    count, errored, count)
  if passed == count then
    io.write(string.format('--[ [32m%s[0m ]--\n\n', stats))
    os.exit(0)
  else
    io.write(string.format('--[ [31m%s[0m ]--\n\n', stats))
    os.exit(1)
  end
end

local function has(tbl, key)
  return tbl[key] and true or false
end

io.write('--- Started tests for covid data module\n\n')

test('get_latest()', function()
  local data, err = cd.get_latest()

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'confirmed'), true), 'correct data in table')
end)

test('get_locations()', function()
  local data, err = cd.get_locations()

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(type(data[1]), 'table'), 'returned table is an array of tables')
  ok(eq(has(data[1], 'country'), true), 'correct data in tables')
  ok(eq(has(data[1], 'timelines'), false), 'no timelines')
end)

test('get_locations() with timelines', function()
  local data, err = cd.get_locations(true)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(type(data[1]), 'table'), 'returned table is an array of tables')
  ok(eq(has(data[1], 'timelines'), true), 'has timelines')
end)

test('get_locations_by_code()', function()
  local data, err = cd.get_by_location_code('de')

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'country'), true), 'correct data in tables')
end)

test('get_locations_by_code() with timelines', function()
  local data, err = cd.get_by_location_code('de', true)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'country'), true), 'correct data in tables')
  ok(eq(has(data, 'timelines'), true), 'has timelines')
end)

test('get_locations_by_id()', function()
  local data, err = cd.get_by_location_id(11)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'country'), true), 'correct data in tables')
end)

test('get_locations_by_id() with timelines', function()
  local data, err = cd.get_by_location_id(11, true)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'country'), true), 'correct data in tables')
  ok(eq(has(data, 'timelines'), true), 'has timelines')
end)

test('get_sources()', function()
  local data, err = cd.get_sources()

  ok(eq(type(data), 'table'), 'table is returned')
  ok(data:len() > 0, 'returned data is an arry > 0')
end)

report()