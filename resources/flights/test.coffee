request = require 'supertest'
{ expect } = require 'chai'

app = require '../../app'

describe 'GET /flights', ->
  before ->
    @app = request.agent(app)

  it 'returns empty array for now', ->
    @app.get '/flights'
    .then ({ body }) ->
      expect(body).to.deep.equal({ data: [] })
