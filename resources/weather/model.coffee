cache = require '../../lib/cache'
debug = require('debug')('hackathon-sun:locations')
moment = require 'moment'
rp = require 'request-promise'

weatherCacheTTL = process.env.WEATHER_CACHE_TTL or 3600
weatherCache = new cache 'weather', weatherCacheTTL

# see https://openweathermap.org/weather-conditions
SUNNY_IDS = [800, 801] # clear, few clouds

module.exports.find = (location, startDate, endDate) ->
  # We look up the weather by latitude, longitude, start date and end date,
  # but cache it by city, country and start date.
  weatherCache location.city, location.country, startDate, lookup(location, endDate)

lookup = ({ latitude, longitude }, endDate) -> (city, country, startDate) ->
  debug "api call: #{JSON.stringify({ latitude, longitude })}"

  # query API for weather data
  options = {
    uri: 'https://api.openweathermap.org/data/2.5/forecast/daily'
    qs: {
      apikey: process.env.OPENWEATHERMAP_APP_ID
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
    for day in res.list
      if day.dt >= startTime and day.dt < endTime and day.weather.id not in SUNNY_IDS
        isSunny = false
    weather = {
      temperature: res.main.temp
      isSunny: isSunny
    }
