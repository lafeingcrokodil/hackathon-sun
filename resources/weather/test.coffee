{ expect } = require 'chai'

errors = require '../errors'
model = require './model'

describe 'Weather', ->

  describe '#find()', ->

    it 'returns weather data for valid location', ->
      model.find { code: 'IST', latitude: 41.01384, longitude: 28.94966 }
      .then (data) ->
        expect(data).to.be.an('object')
        expect(data).to.have.all.keys(['isClear', 'temperature'])
        # TODO: check that isClear is either true or false
        # TODO: check that temperature is an integer representing the temperature in degrees Kelvin

    it 'throws error if no location is specified', ->
      expect ->
        model.find()
      .to.throw(errors.BadRequestError, 'Bad Request: missing location')

    it 'throws error if location code is missing', ->
      expect ->
        model.find { latitude: 41.01384, longitude: 28.94966 }
      .to.throw(errors.BadRequestError, 'Bad Request: missing location code')

    it 'throws error if latitude is missing', ->
      expect ->
        model.find { code: 'IST', longitude: 28.94966 }
      .to.throw(errors.BadRequestError, 'Bad Request: missing latitude')

    it 'throws error if longitude is missing', ->
      expect ->
        model.find { code: 'IST' latitude: 41.01384 }
      .to.throw(errors.BadRequestError, 'Bad Request: missing longitude')

    it 'throws error if no weather data can be found', ->
      expect ->
        model.find { code: 'nonsense', latitude: 1000, longitude: 1000 }
      .to.throw(errors.InternalServerError, 'Unknown Location: 1000, 1000')
