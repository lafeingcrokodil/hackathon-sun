{ expect } = require 'chai'

errors = require '../errors'
model = require './model'

describe 'Airports', ->

  describe '#find()', ->

    it 'returns nearby airports for valid latitude and longitude', ->
      model.find 41.01384, 28.94966
      .then (airports) ->
        expect(airports).to.be.an('array')
        expect(airports).to.not.be.empty
        for airport in airports
          expect(airport).to.be.a('string')
          expect(airport).to.match(/^[A-Z]{3}$/)

    it 'throws error if no airports are found', ->
      expect ->
        model.find 1000, 1000
      .to.throw(errors.UnknownLocationError, 'Unknown Location: 1000, 1000')
