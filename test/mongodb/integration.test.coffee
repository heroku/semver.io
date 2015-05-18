assert = require "assert"
semver = require "semver"
supertest = require "supertest"

App = require "../../lib/app"
Resolver = require "../../lib/resolver"
MongoDBSource = require "../../lib/sources/mongodb"

app = new App({
  mongodb: new Resolver(new MongoDBSource()),
});

failingApp = new App({
  mongodb: new Resolver(new MongoDBSource())
});

describe "MongoDB Routes", ->

  describe "Initialization", ->

    it "updates the app", (done) ->
      this.timeout(20000)
      app.resolvers.mongodb.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "prime's the failing app's cache", (done) ->
      this.timeout(20000)
      failingApp.resolvers.mongodb.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

  describe "GET /mongodb/stable", ->

    it "returns a stable mongodb version", (done) ->
      supertest(app)
        .get("/mongodb/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/mongodb/stable")
        .expect(200)
        .expect('content-type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

  describe "GET /mongodb.json", ->

    it "returns JSON with stable, versions, updated", (done) ->
      supertest(app)
        .get("/mongodb.json")
        .expect(200)
        .expect('Content-Type', /application\/json/)
        .end (err, res) ->
          return done(err) if err
          assert.equal typeof(res.body.stable), "string"
          assert.equal typeof(res.body.all), "object"
          assert.equal typeof(res.body.updated), "string"
          assert.ok res.body.all.length
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/mongodb.json")
        .expect(200)
        .expect('Content-Type', /application\/json/)
        .end (err, res) ->
          return done(err) if err
          assert.equal typeof(res.body.stable), "string"
          assert.equal typeof(res.body.all), "object"
          assert.equal typeof(res.body.updated), "string"
          assert.ok res.body.all.length
          done()
