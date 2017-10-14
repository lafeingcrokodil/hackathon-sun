cache = require '../../lib/cache'

locationCache = new cache

module.exports.find = (code) ->
  locationCache code, lookup

lookup = (code) ->
  # TODO: query API for lat/long and city name data
