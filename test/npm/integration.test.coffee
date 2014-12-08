assert = require "assert"
semver = require "semver"
supertest = require "supertest"

App = require "../../lib/app"
Resolver = require "../../lib/resolver"
NpmSource = require "../../lib/sources/npm"

app = new App({
  npm: new Resolver(new NpmSource()),
});

failingApp = new App({
  npm: new Resolver(new NpmSource())
});

describe "Npm Routes", ->

  describe "Initialization", ->

    it "updates the app", (done) ->
      this.timeout(20000)
      app.resolvers.npm.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "prime's the failing app's cache", (done) ->
      this.timeout(20000)
      failingApp.resolvers.npm.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "redirects the failing app to a false endpoint", (done) ->
      this.timeout(20000)
      failingApp.resolvers.npm.source.registry = 'https://fail.npmjs.com/';
      failingApp.resolvers.npm.update (err, updated) ->
        assert(err)
        assert(!updated)
        done()


  describe "GET /npm/stable", ->

    it "returns a stable npm version", (done) ->
      supertest(app)
        .get("/npm/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/npm/stable")
        .expect(200)
        .expect('content-type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

  describe "GET /npm/unstable", ->

    it "returns an unstable npm version", (done) ->
      supertest(app)
        .get("/npm/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/npm/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

  describe "GET /npm/resolve/1.4.x", ->

    it "returns a 1.4 npm version", (done) ->
      supertest(app)
        .get("/npm/resolve/1.4.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 1
          assert.equal semver(res.text).minor, 4
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/npm/resolve/1.4.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 1
          assert.equal semver(res.text).minor, 4
          done()

  describe "GET /npm/resolve/~2.0.1", ->

    it "returns a 2.0 npm version", (done) ->
      supertest(app)
        .get("/npm/resolve/~2.0.1")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 2
          assert.equal semver(res.text).minor, 0
          assert semver(res.text).patch > 1
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/npm/resolve/~2.0.1")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 2
          assert.equal semver(res.text).minor, 0
          assert semver(res.text).patch > 1
          done()

  describe "GET /npm/resolve/2.1.4", ->

    it "returns the exact version requested", (done) ->
      supertest(app)
        .get("/npm/resolve/2.1.4")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "2.1.4"
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/npm/resolve/2.1.4")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "2.1.4"
          done()

  describe "GET /npm/resolve?range=1.4.x", ->

    it "allows range as a query param", (done) ->
      supertest(app)
        .get("/npm/resolve?range=1.4.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).major, 1
          assert.equal semver.parse(res.text).minor, 4
          done()

    it "works with a failing endpoint", (done) ->
      supertest(app)
        .get("/npm/resolve?range=1.4.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).major, 1
          assert.equal semver.parse(res.text).minor, 4
          done()

  describe "GET /npm.json", ->

    it "returns JSON with stable, unstable, versions, updated", (done) ->
      supertest(app)
        .get("/npm.json")
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
        .get("/npm.json")
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
