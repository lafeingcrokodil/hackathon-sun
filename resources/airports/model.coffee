debug = require('debug')('hackathon-sun:airports')
rp = require 'request-promise'

# TODO: find some way to cache results?

# Returns location (IATA) codes (an array of strings) for nearby airports.
module.exports.find = (latitude, longitude) ->
  debug "api call: #{JSON.stringify({ latitude, longitude })}"

  # query API for nearby airports
  options = {
    uri: 'https://api.sandbox.amadeus.com/v1.2/airports/nearest-relevant'
    qs: {
      apikey: process.env.AMADEUS_API_KEY
      latitude: latitude
      longitude: longitude
    }
    json: true
  }

  rp(options).then (res) ->
    locations = []
    for item in res
      locations.push item.airport
    return locations
