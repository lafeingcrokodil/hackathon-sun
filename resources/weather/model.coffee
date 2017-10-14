Promise = require 'bluebird'
cache = {}

module.exports.find = ( {location} ) ->
  return Promise.resolve cache[location]
  # TODO account for locations without cached weather data

module.exports.load = ( {locations} ) ->
  # TODO fill cache global variable


lookup = ( { location } ) ->
  #TODO query api for weather data
