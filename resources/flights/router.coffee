express = require 'express'
router = express.Router()

model = require './model'

# GET flights listing.
router.get '/', (req, res, next) ->
  model.find { origin: req.query?.origin }
  .then (data) ->
    res.send { data }
  .catch next

module.exports = router
