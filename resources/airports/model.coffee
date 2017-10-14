rp = require 'request-promise'

# TODO: find some way to cache results?

# Returns location codes (an array of strings) for nearby airports.
module.exports.find = (latitude, longitude) ->
  # TODO: query API for nearby airports
