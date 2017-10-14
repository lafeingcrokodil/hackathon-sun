module.exports.find = ({ origin }) ->
  lookup origin
  .then (flights) ->
    # TODO: look up location data for destinations
    # TODO: check weather for destinations
    # TODO: filter and sort flights
    return flights

lookup = (origin) ->
  # TODO: query API for cheapest flights
