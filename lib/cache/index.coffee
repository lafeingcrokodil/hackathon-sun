debug = require('debug')('hackathon-sun:cache')
Promise = require 'bluebird'

module.exports = (name, ttl) ->
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
      cache[key] = { promise, expiryTime: if ttl then Date.now() + ttl }
      return promise
