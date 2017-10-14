express = require 'express'
Promise = require 'bluebird'

router = express.Router()

errors = require '../errors'
model = require './model'

# GET flights listing.
router.get '/', (req, res, next) ->
  Promise.try ->
    origin = req.query?.origin or
      throw new errors.BadRequestError 'missing origin'
    model.find { origin }
  .then (data) ->
    res.send { data }
  .catch (err) ->
    errors.handler err, req, res

module.exports = router
