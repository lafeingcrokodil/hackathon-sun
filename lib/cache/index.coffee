module.exports = (ttl) ->
  cache = {}

  (args..., fn) ->
    key = JSON.stringify args
    Promise.try ->
      { value, expiryTime } = cache[key] or {}
      if value? and (not expiryTime or Date.now() < expiryTime)
        return value
      fn args...
    .then (newValue) ->
      cache[key] = { value: newValue, expiryTime: if ttl then Date.now() + ttl }
      return newValue
