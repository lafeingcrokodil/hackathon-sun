module.exports.handler = (err, req, res) ->
  error =
    name: err.name
    message: err.message
  if req.app.get('env') is 'development'
    error.stack = err.stack
  res.send { error }

class BadRequestError extends Error
  name: 'BadRequestError'
  status: 400
  constructor: (message) ->
    @message = "Bad Request: #{message}"

module.exports.BadRequestError = BadRequestError

class UnknownLocationError extends Error
  name: 'UnknownLocationError'
  constructor: (location) ->
    @message = "Unknown Location: #{location}"

module.exports.UnknownLocationError = UnknownLocationError
