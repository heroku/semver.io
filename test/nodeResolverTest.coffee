assert = require "assert"
semver = require "semver"
supertest = require "supertest"

module.exports = (app) ->
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

  describe "GET /node.json", ->

    it "returns a JSON with node versions info", (done) ->
      supertest(app)
        .get("/node.json")
        .expect(200)
        .expect('Content-Type', /application\/json/)
        .end (err, res) ->
          return done(err) if err

          keys = (k for k of res.body)
          assert 'stable' in keys
          assert 'unstable' in keys
          assert 'all' in keys
          done()

    it "adds CORS headers (fix #10)", (done) ->
      supertest(app)
        .get("/node.json")
        .expect(200)
        .expect('Access-Control-Allow-Origin', '*')
        .end done

