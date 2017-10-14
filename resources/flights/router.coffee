express = require 'express'
Promise = require 'bluebird'

router = express.Router()

errors = require '../errors'
model = require './model'

# GET flights listing.
router.get '/', (req, res, next) ->
  Promise.try ->
    latitude = req.query?.latitude or
      throw new errors.BadRequestError 'missing latitude'
    longitude = req.query?.longitude or
      throw new errors.BadRequestError 'missing longitude'
    model.find { latitude, longitude }
  .then (data) ->
    res.send { data }
  .catch (err) ->
    errors.handler err, req, res

module.exports = router
