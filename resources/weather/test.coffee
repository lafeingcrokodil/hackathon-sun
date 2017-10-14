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
