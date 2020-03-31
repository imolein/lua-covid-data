package.path = './src/?.lua;' .. package.path

local test = require('gambiarra')

-- activate test mode
_TEST = true
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

test('privat function build_query()', function()
  local q1 = cd._build_query({ timelines = 1 })
  local q2 = cd._build_query({
    timelines = 0,
    source = 'jhu',
    country_code = 'de'
  })

  local patt = '^[%a_]+=%w+%&[%a_]+=%w+%&[%a_]+=%w+$'
  local function query_matched(query)
    return query:find(patt) and true or false
  end

  ok(eq(q1, 'timelines=1'), 'query 1 correctly build')
  ok(eq(query_matched(q2), true), 'query 2 correctly build')
end)

test('privat function with_timelines()', function ()
  ok(eq(cd._with_timelines(true), 1), 'with timelines')
  ok(eq(cd._with_timelines(false), 0), 'without timelines')
  ok(eq(cd._with_timelines('miep'), 0), 'params other than boolean return 0')
end)

test('privat function parse_body()', function ()
  local ok1, data1 = cd._parse_body('{ "miep": "no" }')
  local ok2, data2 = cd._parse_body('{ "miep": "no"')

  ok(eq(ok1, true), 'returns true as first value for valid JSON')
  ok(eq(type(data1), 'table'), 'returns the parsed JSON data as table as second value')
  ok(eq(ok2, false), 'returns false as first value for invalid JSON')
  ok(eq(type(data2), 'string'), 'returns error as second value')
end)

test('get_latest()', function()
  local data = cd.get_latest()

  ok(err == nil, 'no error')
  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'latest'), true), 'has latest table')
end)

test('get_latest() with source', function()
  local data = cd.get_latest('csbs')
  ok(err == nil, 'no error')
  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'latest'), true), 'has latest table')
end)

test('get_locations()', function()
  local data = cd.get_locations()

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'locations'), true), '"locations" subtable in received data')
  ok(eq(has(data, 'latest'), true), '"latest" subtable in received data')
  ok(eq(type(data.locations[1]), 'table'), 'returned table is an array of tables')
  ok(eq(has(data.locations[1], 'country'), true), 'correct data in tables')
  ok(eq(has(data.locations[1], 'timelines'), false), 'no timelines')
end)

test('get_locations() with source', function()
  local data = cd.get_locations(true, 'csbs')

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(data.locations[1].country, 'US'), 'country is US cause "csbs" source has only US data')
  ok(eq(has(data.locations[1], 'timelines'), false), '"csbs" source has no timelines')
end)

test('get_locations() with timelines', function()
  local data = cd.get_locations(true)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data.locations[1], 'timelines'), true), 'has timelines')
end)

test('get_locations_by_code()', function()
  local data = cd.get_by_location_code('de')

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data, 'locations'), true), '"locations" subtable in received data')
  ok(eq(has(data, 'latest'), true), '"latest" subtable in received data')
  ok(eq(data.locations[1].country_code, 'DE'), 'correct data in tables')
end)

test('get_locations_by_code() with source', function()
  local data = cd.get_by_location_code('us', true, 'csbs')

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(data.locations[1].country, 'US'), 'country is US cause "csbs" source has only US data')
  ok(eq(has(data.locations[1], 'timelines'), false), '"csbs" source has no timelines')
end)

test('get_locations_by_code() with timelines', function()
  local data = cd.get_by_location_code('de', true)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data.locations[1], 'timelines'), true), 'has timelines')
end)

test('get_locations_by_id()', function()
  local data = cd.get_by_location_id(11)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data.location, 'country'), true), 'correct data in tables')
  ok(eq(has(data.location, 'timelines'), true), 'timelines table in data even if "timelines=0"...')
  ok(#data.location.timelines, '...but it is empty')
end)

test('get_locations_by_id() with source', function()
  local data = cd.get_by_location_id(11, true, 'csbs')

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(data.location.country, 'US'), 'country is US cause "csbs" source has only US data')
  ok(eq(has(data.location, 'timelines'), true), 'timelines table in data even if "csbs" data source has not timeline data')
  ok(#data.location.timelines, '...but it is empty')
end)

test('get_locations_by_id() with timelines', function()
  local data = cd.get_by_location_id(11, true)

  ok(eq(type(data), 'table'), 'table is returned')
  ok(eq(has(data.location, 'timelines'), true), 'has timelines table...')
  ok(eq(has(data.location.timelines, 'confirmed'), true), '...which is not empty')
end)

test('get_sources()', function()
  local data = cd.get_sources()

  ok(eq(type(data), 'table'), 'table is returned')
  ok(#data.sources > 0, 'returned data is an arry > 0')
end)

test('errors', function()
  local data, err, raw = cd.get_by_location_code('de', false, 'csbs')

  ok(eq(data, false), 'country_code "DE" and source "csbs" is not available')
  ok(eq(err, 404), 'it returns a 404')
  ok(eq(raw, '{"detail":"Source `csbs` does not have the desired location data."}'), 'and an error message as JSON, which is returned raw')
end)

report()