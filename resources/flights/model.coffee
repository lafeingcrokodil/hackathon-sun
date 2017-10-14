Promise = require 'bluebird'
csvParser = require '../parser/csvParser.js'

routes = null

module.exports.find = ({ origin }) ->
  return Promise.resolve []

module.exports.load = () ->
  csvParser.getRoutes()
    .then ( response ) ->
        routes = res.origins;


lookup = ( { origin, destination } ) ->
  #TODO query api for cheapest flights data
