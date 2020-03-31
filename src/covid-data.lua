local curl = require('lcurl')

local json do
  local ok, jsn = pcall(require, 'cjson')

  if not ok then
    jsn = require('dkjson')
  end

  json = jsn
end

local covid_data = {
  _VERSION = '0.2.0-0',
  _DESCRIPTION = 'Lua wrapper for Coronavirus Tracker API',
  _URL = 'https://codeberg.org/imo/lua-covid-data',
  _LICENSE = 'MIT'
}


--- Private functions

-- parses the received JSON data
local function parse_body(body)
  local ok, data = pcall(json.decode, body)

  if not ok then
    return false, data
  end

  return true, data
end

-- with our without timelines
local function with_timelines(tl)
  return (tl == true or covid_data.timelines) and 1 or 0
end

-- build query
local query_format = '%s=%s'
local function build_query(query_data)
  local query = {}

  for k, v in pairs(query_data) do
    table.insert(query, query_format:format(k, v))
  end

  return table.concat(query, '&')
end

-- makes the request and returns the data
local function request(req)
  local headers = { 'Content-Type: application/json' }
  local queue = {}

  local easy = curl.easy()
    :setopt_url(covid_data.api_url .. req)
    :setopt_httpheader(headers)
    :setopt_useragent(covid_data.useragent)
    :setopt_followlocation(true)
    :setopt_writefunction(function(buf)
      table.insert(queue, buf)
    end)

  local ok, err = easy:perform()

  if not ok then
    easy:close()
    return false, err
  end

  local code, body = easy:getinfo_response_code(), table.concat(queue)
  easy:close()

  if code ~= 200 then
    return false, code, body
  end

  local ok, parsed = parse_body(body) -- luacheck: ignore 411/ok

  if not ok then
    return false, parsed, body
  end

  return parsed
end


--- Public variables

-- some default variables
covid_data.timelines = false
covid_data.sources = { jhu = 'jhu', csbs = 'csbs' }
covid_data.source = covid_data.sources.jhu
covid_data.api_url = 'https://coronavirus-tracker-api.herokuapp.com/v2/'
covid_data.useragent = ('lua-covid-data/%s libcurl/%s (%s)')
  :format(covid_data._VERSION, curl.version_info('version'), covid_data._URL)


--- Public functions

-- get latest total data
function covid_data.get_latest(source)
  local query = build_query({
    source = covid_data.sources[source] or covid_data.source
  })

  return request(('latest?%s'):format(query))
end

-- get latest data per location
function covid_data.get_locations(tl, source)
  local query = build_query({
    timelines = with_timelines(tl),
    source = covid_data.sources[source] or covid_data.source
  })

  return request(('locations?%s'):format(query))
end

-- get latest data for a specific location specified by country code
function covid_data.get_by_location_code(country_code, tl, source)
  assert(country_code and type(country_code) == 'string', 'Needs at least one argument - a string')

  local query = build_query({
    country_code = country_code:lower(),
    timelines = with_timelines(tl),
    source = covid_data.sources[source] or covid_data.source
  })

  return request(
    ('locations?%s'):format(query)
  )
end

-- get latest data for a specific location specified by id
function covid_data.get_by_location_id(id, tl, source)
  assert(id and type(id) == 'number', 'Needs at least one argument - a number')

  local query = build_query({
    timelines = with_timelines(tl),
    source = covid_data.sources[source] or covid_data.source
  })

  return request(('locations/%s?%s'):format(id, query))
end

-- returns the available data sources
function covid_data.get_sources()
  return request('sources')
end

if _TEST then -- luacheck: ignore 113/_TEST
  covid_data._build_query = build_query
  covid_data._with_timelines = with_timelines
  covid_data._parse_body = parse_body
end

return covid_data