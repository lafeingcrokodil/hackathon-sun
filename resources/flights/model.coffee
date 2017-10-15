debug = require('debug')('hackathon-sun:flights')
moment = require 'moment'
request = require 'request-promise'
Promise = require 'bluebird'

errors = require '../errors'

airportModel = require '../airports/model'
locationModel = require '../locations/model'
weatherModel = require '../weather/model'

TRIP_DURATION = 2

module.exports.find = ({ latitude, longitude }) ->
  departureDate = getDepartureDate().format('YYYY-MM-DD')
  cheapestTrip = null
  airportModel.find latitude, longitude
  .then (locationCodes) ->
    # check for cheap trips originating from each nearby airport
    Promise.map locationCodes, (locationCode) ->
      lookupTrips locationCode, departureDate
    .then flatten # turn array of arrays into a single array
    .then (trips) ->
      # determine cheapest trip with sunny weather
      trips.sort (a, b) -> a.price - b.price # check cheapest trips first
      Promise.map trips, (trip) ->
        return if cheapestTrip and trip.price >= cheapestTrip.price
        locationModel.find trip.destination
        .then (location) ->
          weatherModel.find location, trip.departure_date, trip.return_date
        .then (weather) ->
          if weather.isSunny
            trip.weather = weather
            cheapestTrip = trip
        .catch errors.logger
      , { concurrency: 10 } # check up to 10 trips at once
    .then ->
      console.log cheapestTrip
      do process.exit
      lookupDetails cheapestTrip
      .then (flights) ->
        cheapestFlight = null
        for flight in flights
          if not cheapestFlight or flight.fare.total_price < cheapestFlight.fare.total_price
            flight.trip = trip
            cheapestFlight = flight
        return cheapestFlight
  .then (flight) ->
    console.log flight
    do process.exit

lookupTrips = (origin, departureDate) ->
  debug "api call: #{JSON.stringify({ origin, departureDate, duration: TRIP_DURATION })}"
  request
    uri: 'https://api.sandbox.amadeus.com/v1.2/flights/inspiration-search'
    qs:
      apikey: process.env.AMADEUS_API_KEY
      origin: origin
      departure_date: departureDate
      duration: TRIP_DURATION
    json: true
  .then ({ results }) ->
    # The results are sorted by price in ascending order.
    # TODO: only consider the x cheapest destinations?
    for result in results
      result.origin = origin
    return results
  .catch (err) ->
    errors.logger err
    return []

lookupDetails = ({ origin, destination, departure_date, return_date }) ->
  params =
    origin: origin
    destination: destination.code
    departure_date: departure_date
    return_date: return_date
    # TODO: set mobile to true depending on user's device
  debug "api call: #{JSON.stringify(params)}"
  params.apikey = process.env.AMADEUS_API_KEY
  request
    uri: 'https://api.sandbox.amadeus.com/v1.2/flights/affiliate-search'
    qs: params
    json: true
  .then ({ results }) ->
    console.log results
    do process.exit

getDepartureDate = ->
  FRIDAY = 5
  if moment().isoWeekday() <= FRIDAY
    return moment().isoWeekday(FRIDAY)
  else
    return moment().add(1, 'weeks').isoWeekday(FRIDAY)

flatten = (arrays) ->
  flattenedArray = []
  for array in arrays
    for elem in array
      flattenedArray.push elem
  return flattenedArray
