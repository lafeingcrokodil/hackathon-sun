cache = require '../../lib/cache'
rp = require 'request-promise'

locationCache = new cache

module.exports.find = (code) ->
  locationCache code, lookup

lookup = (code) ->
  # TODO: query API for lat/long and city name data
  options = {
    uri: 'https://api.sandbox.amadeus.com/v1.2/location/' + code
    qs: {
      apikey: process.env.AMADEUS_API_KEY
    }
    json: true
  }

  rp(options).then (res) ->
    details = {
      lon: res.city.location.long
      lat: res.city.location.lat
      city: res.city.city_name
      country: res.city.country
    }
