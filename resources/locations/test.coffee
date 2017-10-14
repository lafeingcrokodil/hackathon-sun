{ expect } = require 'chai'

errors = require '../errors'
model = require './model'

describe 'Locations', ->

  describe '#find()', ->

    it 'returns location data for valid location', ->
      model.find 'IST'
      .then (data) ->
        expect(data).to.be.an('object')
        expect(data).to.have.all.keys(['lat', 'lon', 'city', 'country'])
        # TODO: check that lat and lon are floats within valid ranges
        # TODO: check that city and country are valid strings

    it 'throws error if no location is specified', ->
      expect ->
        model.find()
      .to.throw(errors.BadRequestError, 'Bad Request: missing location')

    it 'throws error if invalid location is specified', ->
      expect ->
        model.find 'nonsense'
      .to.throw(errors.UnknownLocationError, 'Unknown Location: nonsense')
