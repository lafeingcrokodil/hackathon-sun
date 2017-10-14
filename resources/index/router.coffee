express = require 'express'
router = express.Router()

# GET home page.
router.get '/', (req, res, next) ->
  res.render 'index', { title: 'Sun Therapy' } # TODO: decide on name

module.exports = router
