request = require 'supertest'
{ expect } = require 'chai'

app = require '../../app'

describe 'GET /flights', ->
  before ->
    @app = request.agent(app)

  it 'returns array of flights for valid origin', ->
    @app.get '/flights?origin=FRA'
    .then ({ body }) ->
      expect(body.data).to.be.an('array')
      expect(body.data).to.not.be.empty
      for flight in body.data
        expect(flight).to.be.an('object')
        expect(flight).to.have.all.keys(['destination', 'temperature', 'price'])
        # TODO: check that destination, temperature and price contain valid data

  it 'returns BadRequestError if no origin is specified', ->
    @app.get '/flights'
    .then ({ body }) ->
      expect(body).to.deep.equal
        error:
          name: 'BadRequestError'
          message: 'Bad Request: missing origin'
