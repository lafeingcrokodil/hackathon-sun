debug = require('debug')('hackathon-sun:cache')
Promise = require 'bluebird'

module.exports = (name, ttl) -> # time to live in milliseconds
  cache = {}

  (args..., fn) ->
    key = JSON.stringify args
    { promise, expiryTime } = cache[key] or {}
    if promise? and (not expiryTime or Date.now() < expiryTime)
      debug "#{name} hit: #{key}"
      return promise
    else
      debug "#{name} miss: #{key}"
      promise = fn args...
      cache[key] = { promise, expiryTime: if ttl then Date.now() + 1000 * ttl }
      return promise
