{ expect } = require 'chai'

errors = require '../errors'
model = require './model'

describe 'Locations', ->

  describe '#find()', ->

    it 'returns location data for valid location', ->
      model.find { location: 'IST' }
      .then (data) ->
        expect(data).to.be.an('object')
        expect(data).to.have.all.keys(['lat', 'lon'])
        # TODO: check that lat and lon are floats within valid ranges

    it 'throws error if no parameters are specified', ->
      expect ->
        model.find()
      .to.throw(errors.BadRequestError, 'Bad Request: missing location')

    it 'throws error if no location is specified', ->
      expect ->
        model.find {}
      .to.throw(errors.BadRequestError, 'Bad Request: missing location')

    it 'throws error if invalid location is specified', ->
      expect ->
        model.find { location: 'nonsense' }
      .to.throw(errors.UnknownLocationError, 'Unknown Location: nonsense')
