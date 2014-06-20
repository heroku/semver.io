assert = require "assert"
semver = require "semver"
supertest = require "supertest"
App = require "../lib/app"
app = new App()
failingApp = new App()

describe "App", ->

  before (done) ->
    app.update(done)

  before (done) ->
    failingApp.update ->
      failingApp.timeout = 1
      done()

  describe "#update()", ->

    it "works with a normal timeout", (done) ->
      app.update (err, updated) ->
        assert.ok(updated)
        done()

    it "fails with a short timeout", (done) ->
      failingApp.update (err, updated) ->
        assert.ok(!updated)
        done()

  describe "GET /", ->

    it "renders the readme", (done) ->
      supertest(app)
        .get("/")
        .expect(200, done)

  describe "GET /node/stable", ->

    it "returns a stable node version", (done) ->
      supertest(app)
        .get("/node/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor%2, 0
          done()

    it "works with a failing endpoint", (done) ->
      supertest(app)
        .get("/node/stable")
        .expect(200)
        .expect('content-type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor%2, 0
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
          assert.equal semver.parse(res.text).minor%2, 1
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/node/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor%2, 1
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
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor, 10
          assert (semver.parse(res.text).patch > 20)
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
          assert.equal typeof(res.body.versions), "object"
          assert.equal typeof(res.body.updated), "string"
          assert.ok res.body.versions.length
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
          assert.equal typeof(res.body.versions), "object"
          assert.equal typeof(res.body.updated), "string"
          assert.ok res.body.versions.length
          done()

  describe "Auto-updating", ->

    it "should start as soon as update is called", (done) ->
      quickApp = new App()
      quickApp.interval = 50
      checkUpdates = () ->
        assert.ok quickApp.updates >= 3 and quickApp.updates <= 5
        done()
      quickApp.update()
      setTimeout(checkUpdates, 200)
