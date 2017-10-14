cache = require '../../lib/cache'
debug = require('debug')('hackathon-sun:locations')
rp = require 'request-promise'

locationCache = new cache

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
    details = {
      longitude: res.city.location.longitude
      latitude: res.city.location.latitude
      city: res.city.name
      country: res.city.country
    }
