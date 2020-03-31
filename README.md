[![Build Status](https://drone.kokolor.es/api/badges/imo/lua-covid-data/status.svg)](https://drone.kokolor.es/imo/lua-covid-data)

# lua-covid-data

Lua wrapper for the [coronavirus-tracker-api](https://github.com/ExpDev07/coronavirus-tracker-api).

## Warning

I am not a programmer, so here's a warning: **This code was written in an exploratory way.** If you encounter problems, see something wrong or something was implemented in a weird way, I would be happy if you tell me about it or create a pull request. Thank you. :)

## Example

```lua
> covid_data = require('covid-data')
> covid_data.get_latest()
{
  latest = {
    confirmed = 242708,
    deaths = 9867,
    recovered = 0
  }
}
> covid_data.get_by_location_code('de', true)
{
  latest = { ... },
  locations = {
    {
      id = 120,
      country = 'Germany',
      ...,
      timelines = { ... }
    }
  }
}
```

## Documentation

* [Installation](#installation)
* [Dependencies](#dependencies)
* [Options](#options)
* [Functions](#functions)
   * [get_sources](#get_sources)
   * [get_latest](#get_latestsourcejhu)
   * [get_locations](#get_locationstimelines0-sourcejhu)
   * [get_by_location_code](#get_by_location_codecountry_codetimelines0-sourcejhu)
   * [get_by_location_id](#get_by_location_ididtimelines0-sourcejhu)
* [Tests](#tests)

## Installation

The easiest way is to install it via [luarocks](https://luarocks.org/modules/imolein/lua-covid-data).

```
luarocks install lua-covid-data
```

## Dependencies

* lua <= 5.3
* [lua-curl](https://github.com/Lua-cURL/Lua-cURLv3)
* [lua-dkjson](http://dkolf.de/src/dkjson-lua.fsl/home)
* **or** [lua-cjson](https://luarocks.org/modules/openresty/lua-cjson) == 2.1.0-1

## Options

### covid_data.timelines
Set to `true` if the timelines should be displayed by default. Defaults to `false`.

### covid_data.sources
Table with available data sources at the time of writing this. The `source` parameter of the functions is checked agains this table and chooses the default if the given source is not in this table. If the API should support other sources in the future, they can be quickly added here without having to modify the module code. Defaults to `{ jhu = 'jhu', csbs = 'csbs' }`.

### covid_data.source
The default data source. Defaults to `'jhu'`.

### covid_data.api_url
The API URL coronavirus tracker API. Change it if you run your own instance of the tracker API. Defaults to `'https://coronavirus-tracker-api.herokuapp.com/v2/'`.

### covid_data.useragent
The useragent string for the request. Change it if you want to use another one. Defaults to `'lua-covid-data/$version libcurl/$version (https://codeberg.org/imo/lua-covid-data)`.

## Functions

### `get_sources()`

Get available data sources.

**Returns:**

(**table** | **false**) data | `false` in case of error  
(**string**) error message  
(**string**) in case of error the raw data (eg. the body)

**See:** [Sources Endpoint](https://github.com/ExpDev07/coronavirus-tracker-api/#sources-endpoint)

### `get_latest([source='jhu'])`

Get latest total data.

**Parameter:**

* *source*: (**string**) the data source [**default**: `'jhu'`]

**Returns:**

(**table** | **false**) data | `false` in case of error  
(**string**) error message  
(**string**) in case of error the raw data (eg. the body)

**See:** [Latest Endpoint](https://github.com/ExpDev07/coronavirus-tracker-api/#latest-endpoint)

### `get_locations([timelines=0[, source='jhu']])`

Get latest data per location.

**Parameter:**

* *timelines*: (**boolean**) set to `true` if you want timelines in the data [**default**: `0`]
* *source*: (**string**) the data source [**default**: `'jhu'`]

**Returns:**

(**table** | **false**) data | `false` in case of error  
(**string**) error message  
(**string**) in case of error the raw data (eg. the body)

**See:** [Locations Endpoint](https://github.com/ExpDev07/coronavirus-tracker-api/#locations-endpoint)

### `get_by_location_code(country_code[,timelines=0[, source='jhu']])`

Get latest data for a specific location specified by a country code.

**Parameter:**

* *country_code*: (**string**) an [alpha-2 country_code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
* *timelines*: (**boolean**) set to `true` if you want timelines in the data [**default**: `0`]
* *source*: (**string**) the data source [**default**: `'jhu'`]

**Returns:**

(**table** | **false**) data | `false` in case of error  
(**string**) error message  
(**string**) in case of error the raw data (eg. the body)

**Raises:** Error if `country_code` is missing or not a `string`

**See:** [Locations Endpoint](https://github.com/ExpDev07/coronavirus-tracker-api/#locations-endpoint)

### `get_by_location_id(id[,timelines=0[, source='jhu']])`

Get latest data for a specific location specified by `id`.

**Parameter:**

* *id*: (**number**) location id
* *timelines*: (**boolean**) set to `true` if you want timelines in the data [**default**: `0`]
* *source*: (**string**) the data source [**default**: `'jhu'`]

**Returns:**

(**table** | **false**) data | `false` in case of error  
(**string**) error message  
(**string**) in case of error the raw data (eg. the body)

**Raises:** Error if `id` is missing or not a `number`

**See:** [Locations Endpoint](https://github.com/ExpDev07/coronavirus-tracker-api/#locations-endpoint)

## Tests

[gambiarra](https://codeberg.org/imo/gambiarra) is needed to run the tests.

```
lua spec/covid-data_spec.lua
```