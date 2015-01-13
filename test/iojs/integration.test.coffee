assert = require "assert"
semver = require "semver"
supertest = require "supertest"

App = require "../../lib/app"
Resolver = require "../../lib/resolver"
IoJsSource = require "../../lib/sources/iojs"

app = new App({
  iojs: new Resolver(new IoJsSource()),
});

failingApp = new App({
  iojs: new Resolver(new IoJsSource())
});

describe "IoJs Routes", ->

  describe "Initialization", ->

    it "updates the app", (done) ->
      this.timeout(20000)
      app.resolvers.iojs.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "prime's the failing app's cache", (done) ->
      this.timeout(20000)
      failingApp.resolvers.iojs.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "redirects the failing app to a false endpoint", (done) ->
      this.timeout(20000)
      failingApp.resolvers.iojs.source.url = 'http://iojs.org/fail/';
      failingApp.resolvers.iojs.update (err, updated) ->
        assert(err)
        assert(!updated)
        done()


  describe "GET /iojs/stable", ->

    it "returns a stable iojs version", (done) ->
      supertest(app)
        .get("/iojs/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal(semver.parse(res.text).minor % 2, 0)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/iojs/stable")
        .expect(200)
        .expect('content-type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal(semver.parse(res.text).minor % 2, 0)
          done()

  describe "GET /iojs/unstable", ->

    it "returns an unstable iojs version", (done) ->
      supertest(app)
        .get("/iojs/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/iojs/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

  describe "GET /iojs.json", ->

    it "returns JSON with stable, unstable, versions, updated", (done) ->
      supertest(app)
        .get("/iojs.json")
        .expect(200)
        .expect('Content-Type', /application\/json/)
        .end (err, res) ->
          return done(err) if err
          assert.equal typeof(res.body.stable), "string"
          assert.equal typeof(res.body.unstable), "string"
          assert.equal typeof(res.body.all), "object"
          assert.equal typeof(res.body.updated), "string"
          assert.ok res.body.all.length
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/iojs.json")
        .expect(200)
        .expect('Content-Type', /application\/json/)
        .end (err, res) ->
          return done(err) if err
          assert.equal typeof(res.body.stable), "string"
          assert.equal typeof(res.body.unstable), "string"
          assert.equal typeof(res.body.all), "object"
          assert.equal typeof(res.body.updated), "string"
          assert.ok res.body.all.length
          done()
