# lua-covid-data

Lua wrapper for the [coronavirus-tracker-api](https://github.com/ExpDev07/coronavirus-tracker-api).

## Warning

I am not a programmer, so here's a warning: **This code was written in an exploratory way.** If you encounter problems, see something wrong or something was implemented in a weird way, I would be happy if you tell me about it or create a pull request. Thank you. :)

## Example

```lua
> covid_data = require('covid-data')
> covid_data.get_latest()
{
  confirmed = 242708.0,
  deaths = 9867.0,
  recovered = 84854.0
}
```

## Documentation

* [Installation](#installation)
* [Dependencies](#dependencies)
* [Variables](#variables)
* [Functions](#functions)
   * [get_latest](#get-latest)
   * [get_locations](#get-locations-timelines)
   * [get_by_location_code](#getlocationbycode)
   * [get_by_location_id](#getlocationbyid)
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

## Variables

There are three variables which can be changed:

* **covid_data.timelines**: set to `true` if the timelines should be displayed by default [**default**: `false`]
* **covid_data.api_url**: change if you want to use an other URL [**default**: `'https://coronavirus-tracker-api.herokuapp.com/v2/'`]
* **covid_data.useragent**: changes the useragent string for requests [**default**: `'lua-covid-data/$version libcurl/$version (https://codeberg.org/imo/lua-covid-data)`]

## Functions

### `get_latest()`

Get latest total data.

**Returns:**

(**table** | **false**) data | `false` in case of error
(**string**) error message or unparsed data

### `get_locations([timelines])`

Get latest data per location.

**Parameter:**

* *timelines*: (**boolean**) set to `true` if you want timelines in the data

**Returns:**

(**table** | **false**) data | `false` in case of error
(**string**) error message or unparsed data

### `get_by_location_code(country_code[,timelines])`

Get latest data for a specific location specified by a country code.

**Parameter:**

* *country_code*: (**string**) an [alpha-2 country_code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
* *timelines*: (**boolean**) set to `true` if you want timelines in the data

**Returns:**

(**table** | **false**) data | `false` in case of error
(**string**) error message or unparsed data

**Raises:**

Error if `country_code` is missing or not a `string`

### `get_by_location_id(id[,timelines])`

Get latest data for a specific location specified by `id`.

**Parameter:**

* *id*: (**number**) location id
* *timelines*: (**boolean**) set to `true` if you want timelines in the data

**Returns:**

(**table** | **false**) data | `false` in case of error
(**string**) error message or unparsed data

**Raises:**

Error if `id` is missing or not a `number`

## Tests

[gambiarra](https://codeberg.org/imo/gambiarra) is needed to run the tests.

```
lua spec/covid-data_spec.lua
```