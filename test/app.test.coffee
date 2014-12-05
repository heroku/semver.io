assert = require "assert"
semver = require "semver"
supertest = require "supertest"

App = require "../lib/app"

app = new App()
failingApp = new App()

describe "App", ->

  describe "GET /", ->

    it "renders the readme", (done) ->
      supertest(app)
        .get("/")
        .expect(200, done)
