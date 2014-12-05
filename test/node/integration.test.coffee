assert = require "assert"
semver = require "semver"
supertest = require "supertest"

App = require "../../lib/app"
Resolver = require "../../lib/resolver"
NodeSource = require "../../lib/sources/node"

app = new App({
  node: new Resolver(new NodeSource()),
});

failingApp = new App({
  node: new Resolver(new NodeSource())
});

describe "Node Routes", ->

  describe "Initialization", ->

    it "updates the app", (done) ->
      this.timeout(20000)
      app.resolvers.node.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "prime's the failing app's cache", (done) ->
      this.timeout(20000)
      failingApp.resolvers.node.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "redirects the failing app to a false endpoint", (done) ->
      this.timeout(20000)
      failingApp.resolvers.node.source.url = 'http://nodejs.org/fail/';
      failingApp.resolvers.node.update (err, updated) ->
        assert(err)
        assert(!updated)
        done()


  describe "GET /node/stable", ->

    it "returns a stable node version", (done) ->
      supertest(app)
        .get("/node/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal(semver.parse(res.text).minor % 2, 0)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/node/stable")
        .expect(200)
        .expect('content-type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal(semver.parse(res.text).minor % 2, 0)
          done()

  describe "GET /node/unstable", ->

    it "returns an unstable node version", (done) ->
      supertest(app)
        .get("/node/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal(semver.parse(res.text).minor % 2, 1)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/node/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal(semver.parse(res.text).minor % 2, 1)
          done()

  describe "GET /node/resolve/0.8.x", ->

    it "returns a 0.8 node version", (done) ->
      supertest(app)
        .get("/node/resolve/0.8.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor, 8
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/node/resolve/0.8.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor, 8
          done()

  describe "GET /node/resolve/~0.10.15", ->

    it "returns a 0.10 node version", (done) ->
      supertest(app)
        .get("/node/resolve/0.10.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert(semver.valid(res.text), 'semver is valid')
          assert.equal(semver.parse(res.text).minor, 10, 'minor equals 10')
          assert(semver.parse(res.text).patch > 20, 'patch is greater than 20')
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/node/resolve/0.10.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor, 10
          assert (semver.parse(res.text).patch > 20)
          done()

  describe "GET /node/resolve/0.11.5", ->

    it "returns the exact version requested", (done) ->
      supertest(app)
        .get("/node/resolve/0.11.5")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "0.11.5"
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/node/resolve/0.11.5")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "0.11.5"
          done()

  describe "GET /node/resolve?range=0.8.x", ->

    it "allows range as a query param", (done) ->
      supertest(app)
        .get("/node/resolve?range=0.8.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).minor, 8
          done()

    it "works with a failing endpoint", (done) ->
      supertest(app)
        .get("/node/resolve?range=0.8.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).minor, 8
          done()

  describe "GET /node.json", ->

    it "returns JSON with stable, unstable, versions, updated", (done) ->
      supertest(app)
        .get("/node.json")
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
        .get("/node.json")
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
