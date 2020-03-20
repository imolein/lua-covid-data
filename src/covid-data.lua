local curl = require('cURL')

local json do
  local ok, jsn = pcall(require, 'cjson')

  if not ok then
    jsn = require('dkjson')
  end

  json = jsn
end

local covid_data = {
  _VERSION = '0.1.0-0',
  _DESCRIPTION = 'Lua wrapper for Coronavirus Tracker API',
  _URL = 'https://codeberg.org/imo/lua-covid-data',
  _LICENSE = 'MIT'
}


--- Private functions

-- parses the received JSON data
local function parse_data(json_data)
  local ok, data = pcall(json.decode, json_data)

  if not ok then
    return false, json_data
  end

  if data.latest then
    data = data.latest
  elseif data.locations then
    if #data.locations > 1 then
      data = data.locations
    else
      data = data.locations[1]
    end
  elseif data.location then
    data = data.location
  end

  return true, data
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

  local code, json_data = easy:getinfo_response_code(), table.concat(queue)
  easy:close()

  if code ~= 200 then
    return false, code
  end

  local ok, parsed = parse_data(json_data) -- luacheck: ignore 411/ok

  if not ok then
    return false, parsed
  end

  return parsed
end

-- with our without timelines
local function with_timelines(tl)
  return (tl or covid_data.timelines) and 1 or 0
end


--- Public functions

-- some default variables
covid_data.timelines = false
covid_data.api_url = 'https://coronavirus-tracker-api.herokuapp.com/v2/'
covid_data.useragent = ('lua-covid-data/%s libcurl/%s (%s)')
  :format(covid_data._VERSION, curl.version_info('version'),covid_data._URL)

-- get latest total data
function covid_data.get_latest()
  return request('latest')
end

-- get latest data per location
function covid_data.get_locations(tl)
  return request(('locations?timelines=%d'):format(with_timelines(tl)))
end

-- get latest data for a specific location specified by country code
function covid_data.get_by_location_code(country_code, tl)
  assert(country_code and type(country_code) == 'string', 'Needs at least one argument - a string')

  return request(
    ('locations?country_code=%s&timelines=%d'):format(country_code:upper(), with_timelines(tl))
  )
end

-- get latest data for a specific location specified by id
function covid_data.get_by_location_id(id, tl)
  assert(id and type(id) == 'number', 'Needs at least one argument - a number')

  return request(('locations/%s?timelines=%d'):format(id, with_timelines(tl)))
end

return covid_data