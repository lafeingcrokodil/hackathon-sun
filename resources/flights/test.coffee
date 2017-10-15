request = require 'supertest'
{ expect } = require 'chai'

app = require '../../app'

xdescribe 'GET /flights', ->
  @timeout 0 # disable timeout

  before ->
    @app = request.agent(app)

  it 'returns array of flights for valid origin', ->
    @app.get '/flights?latitude=50.11552&longitude=8.68417'
    .then ({ body }) ->
      expect(body.data).to.be.an('array')
      expect(body.data).to.not.be.empty
      for flight in body.data
        expect(flight).to.be.an('object')
        expect(flight).to.have.all.keys(['destination', 'temperature', 'price'])
        # TODO: check that destination, temperature and price contain valid data

  it 'returns BadRequestError if no latitude is specified', ->
    @app.get '/flights'
    .then ({ body }) ->
      expect(body).to.deep.equal
        error:
          name: 'BadRequestError'
          message: 'Bad Request: missing latitude'
