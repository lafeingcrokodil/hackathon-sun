cache = require '../../lib/cache'

weatherCacheTTL = process.env.WEATHER_CACHE_TTL or 3600
weatherCache = new cache weatherCacheTTL

module.exports.find = (location) ->
  # We look up the weather by latitude and longitude, but cache it by location code.
  weatherCache location.code, lookup(location)

lookup = ({ latitude, longitude }) -> ->
  # TODO: query API for weather data
