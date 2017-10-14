cache = require '../../lib/cache'
rp = require 'request-promise'

weatherCacheTTL = process.env.WEATHER_CACHE_TTL or 3600
weatherCache = new cache weatherCacheTTL

module.exports.find = (location) ->
  # We look up the weather by latitude and longitude, but cache it by location code.
  weatherCache location.code, lookup(location)

lookup = ({ latitude, longitude }) -> ->
  # query API for weather data
  options = {
    uri: 'https://api.openweathermap.org/data/2.5/weather'
    qs: {
      apikey: process.env.OPENWEATHERMAP_APP_ID
      lat: latitude
      lon: longitude
    }
    json: true
  }

  rp(options).then (res) ->
    # TODO is this even vaguely a reasonable way to say it is sunny?
    isItSunny = res.code == 801 || res.code == 800
    weather = {
      temperature: res.main.temp
      isSunny: isItSunny
    }
