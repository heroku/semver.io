supertest = require "supertest"
app = require "../lib/app"

# app is not 'started' until its resolver is ready.
before (done) ->
  app.start done

describe "GET /", ->

  it "renders the readme", (done) ->
    supertest(app)
      .get("/")
      .expect(200, done)

  require('./nodeResolverTest')(app)
  require('./nginxResolverTest')(app)
