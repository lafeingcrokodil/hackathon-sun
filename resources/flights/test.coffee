request = require 'supertest'
{ expect } = require 'chai'

app = require '../../app'

describe 'GET /flights', ->
  before ->
    @app = request.agent(app)

  it 'returns empty array for now', ->
    @app.get '/flights?origin=FRA'
    .then ({ body }) ->
      expect(body).to.deep.equal
        data: []

  it 'returns BadRequestError if no origin is specified', ->
    @app.get '/flights'
    .then ({ body }) ->
      expect(body).to.deep.equal
        error:
          name: 'BadRequestError'
          message: 'Bad Request: missing origin'
