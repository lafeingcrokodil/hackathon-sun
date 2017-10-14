{ expect } = require 'chai'

errors = require '../errors'
model = require './model'

describe 'Weather', ->

  describe '#find()', ->

    it 'returns weather data for valid location', ->
      model.find { location: 'IST' }
      .then (data) ->
        expect(data).to.be.an('object')
        expect(data).to.have.all.keys(['isClear', 'temperature'])
        # TODO: check that isClear is either true or false
        # TODO: check that temperature is an integer representing the temperature in degrees Kelvin

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
