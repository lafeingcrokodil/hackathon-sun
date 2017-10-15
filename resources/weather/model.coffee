cache = require '../../lib/cache'
debug = require('debug')('hackathon-sun:locations')
moment = require 'moment'
rp = require 'request-promise'

weatherCacheTTL = process.env.WEATHER_CACHE_TTL or 60 * 60 * 1000 # one hour by default
weatherCache = new cache 'weather', weatherCacheTTL

# see https://openweathermap.org/weather-conditions
SUNNY_IDS = [800, 801] # clear, few clouds

KELVIN_OFFSET = 273.15
MIN_TEMP = 20 + KELVIN_OFFSET # 20 °C in degrees Kelvin

module.exports.find = (location, startDate, endDate) ->
  # We look up the weather by latitude, longitude, start date and end date,
  # but cache it by city, country and start date.
  weatherCache location.city, location.country, startDate, lookup(location, endDate)

module.exports.toCelsius = (temperature) -> # in degrees Kelvin
  return temperature - KELVIN_OFFSET

lookup = ({ latitude, longitude }, endDate) -> (city, country, startDate) ->
  debug "api call: #{JSON.stringify({ latitude, longitude })}"

  # query API for weather data
  options = {
    uri: 'https://api.openweathermap.org/data/2.5/forecast/daily'
    qs: {
      apikey: process.env.OPENWEATHERMAP_API_KEY
      lat: latitude
      lon: longitude
      cnt: 10 # get weather for next 10 days
    }
    json: true
  }

  rp(options).then (res) ->
    startTime = moment(startDate).unix() # beginning of first day
    endTime = moment(endDate).add(1, 'day').unix() # end of last day
    isSunny = true
    temperatures = []
    for day in res.list when day.dt >= startTime and day.dt < endTime
      temperatures.push day.temp.max
      weatherId = day.weather[0].id # we just consider the first weather object in the array
      if weatherId not in SUNNY_IDS or day.temp.max < MIN_TEMP
        isSunny = false
    weather = {
      temperature: getAverage temperatures
      isSunny: isSunny
    }

getAverage = (values) ->
  return null unless values.length
  sum = 0
  sum += value for value in values
  return sum / values.length
