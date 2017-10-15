cache = require '../../lib/cache'
debug = require('debug')('hackathon-sun:flights')
moment = require 'moment'
request = require 'request-promise'
Promise = require 'bluebird'

errors = require '../errors'

airportModel = require '../airports/model'
locationModel = require '../locations/model'
weatherModel = require '../weather/model'

flightCacheTTL = process.env.FLIGHT_CACHE_TTL or 60 * 60 * 1000 # one hour by default
flightCache = new cache 'flights', flightCacheTTL

BATCH_SIZE = 10
TRIP_DURATION = 2

module.exports.find = ({ latitude, longitude }) ->
  departureDate = getDepartureDate().format('YYYY-MM-DD')
  originDetails = null
  cheapestTrip = null
  airportModel.find latitude, longitude
  .then (locationCodes) ->
    unless locationCodes.length
      throw new errors.NotFoundError 'no nearby airports found'
    locationModel.find locationCodes[0]
  .then (location) ->
    originDetails = location
    # check for cheap trips departing from the origin city
    lookupTrips location.code, departureDate
  .then (trips) ->
    # determine cheapest trip with sunny weather
    trips.sort (a, b) -> a.price - b.price # sort by price (ascending order)
    # process potential trips in batches of 10, starting with the cheapest
    numBatches = trips.length / BATCH_SIZE
    Promise.each [0..numBatches], (i) ->
      return if cheapestTrip # we already found something; no need to keep looking
      startIndex = 10 * i
      endIndex = startIndex + BATCH_SIZE - 1
      Promise.map trips[startIndex..endIndex], (trip) ->
        locationModel.find trip.destination
        .then (location) ->
          trip.destinationDetails = location
          weatherModel.find location, trip.departure_date, trip.return_date
        .then (weather) ->
          if weather.isSunny
            trip.weather = weather
            getDetails trip
            .then ({ meta, results }) ->
              if results?.length > 0 and (not cheapestTrip or trip.price < cheapestTrip.price)
                trip.carriers = meta.carriers
                trip.flights = results
                cheapestTrip = trip
        .catch errors.logger
  .then ->
    unless cheapestTrip
      throw new errors.NotFoundError 'no sunny destination found'
    cheapestFlight = null
    for flight in cheapestTrip.flights
      if not cheapestFlight or flight.fare.total_price < cheapestFlight.fare.total_price
        cheapestFlight = flight

    price: cheapestFlight.fare.total_price
    currency: cheapestFlight.fare.currency
    temperature: weatherModel.toCelsius cheapestTrip.weather.temperature
    origin: originDetails.city
    destination: cheapestTrip.destinationDetails.city
    deepLink: cheapestFlight.deep_link
    outbound:
      airlineName: cheapestTrip.carriers[cheapestFlight.outbound.flights[0].marketing_airline].name
      flightNumber: "#{cheapestFlight.outbound.flights[0].marketing_airline} #{cheapestFlight.outbound.flights[0].flight_number}"
      date: cheapestTrip.departure_date
      departureTime: cheapestFlight.outbound.flights[0].departs_at.replace(/.*T/, '') # departure time of first flight
      arrivalTime: cheapestFlight.outbound.flights[-1..][0].arrives_at.replace(/.*T/, '') # arrival time of last flight
    inbound:
      airlineName: cheapestTrip.carriers[cheapestFlight.inbound.flights[0].marketing_airline].name
      flightNumber: "#{cheapestFlight.inbound.flights[0].marketing_airline} #{cheapestFlight.inbound.flights[0].flight_number}"
      date: cheapestTrip.return_date
      departureTime: cheapestFlight.inbound.flights[0].departs_at.replace(/.*T/, '') # departure time of first flight
      arrivalTime: cheapestFlight.inbound.flights[-1..][0].arrives_at.replace(/.*T/, '') # arrival time of last flight

getDetails = ({ origin, destination, departure_date, return_date }) ->
  flightCache origin, destination, departure_date, return_date, lookupDetails

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

lookupDetails = (origin, destination, departureDate, returnDate) ->
  params =
    origin: origin
    destination: destination
    departure_date: departureDate
    return_date: returnDate
    # TODO: set mobile to true depending on user's device
  debug "api call: #{JSON.stringify(params)}"
  params.apikey = process.env.AMADEUS_API_KEY
  request
    uri: 'https://api.sandbox.amadeus.com/v1.2/flights/affiliate-search'
    qs: params
    json: true

getDepartureDate = ->
  FRIDAY = 5
  if moment().isoWeekday() <= FRIDAY
    return moment().isoWeekday(FRIDAY)
  else
    return moment().add(1, 'weeks').isoWeekday(FRIDAY)
