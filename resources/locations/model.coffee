cache = require '../../lib/cache'
debug = require('debug')('hackathon-sun:locations')
rp = require 'request-promise'

errors = require '../errors'

locationCache = new cache 'locations'

module.exports.find = (code) ->
  locationCache code, lookup

lookup = (code) ->
  debug "api call: #{JSON.stringify({ code })}"

  # query API for lat/long and city name data
  options = {
    uri: 'https://api.sandbox.amadeus.com/v1.2/location/' + code
    qs: {
      apikey: process.env.AMADEUS_API_KEY
    }
    json: true
  }

  rp(options).then (res) ->
    if res.city
      code: res.city.code
      longitude: res.city.location.longitude
      latitude: res.city.location.latitude
      city: res.city.name
      country: res.city.country
    else if res.airports?[0]
      code: res.airports[0].city_code
      longitude: res.airports[0].location.longitude
      latitude: res.airports[0].location.latitude
      city: res.airports[0].city_name
      country: res.airports[0].country
    else
      throw new errors.NotFoundError 'no nearby city or airport found'
