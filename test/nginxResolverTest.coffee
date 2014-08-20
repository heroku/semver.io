assert = require "assert"
semver = require "semver"
supertest = require "supertest"

module.exports = (app) ->
  describe "GET /nginx/stable", ->

    it "returns a stable nginx version", (done) ->
      supertest(app)
        .get("/nginx/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor%2, 0
          done()

  describe "GET /nginx/unstable", ->

    it "returns an unstable nginx version", (done) ->
      supertest(app)
        .get("/nginx/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor%2, 1
          done()

  describe "GET /nginx/resolve/1.6.x", ->

    it "returns a 1.6 nginx version", (done) ->
      supertest(app)
        .get("/nginx/resolve/1.6.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor, 6
          done()

  describe "GET /nginx/resolve/~1.7.1", ->

    it "returns a 1.7 nginx version", (done) ->
      supertest(app)
        .get("/nginx/resolve/1.7.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver.parse(res.text).minor, 7
          assert (semver.parse(res.text).patch > 1)
          done()

  describe "GET /nginx/resolve/1.7.4", ->

    it "returns the exact version requested", (done) ->
      supertest(app)
        .get("/nginx/resolve/1.7.4")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "1.7.4"
          done()

  describe "GET /nginx/resolve?range=0.8.x", ->

    it "allows range as a query param", (done) ->
      supertest(app)
        .get("/nginx/resolve?range=0.8.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).minor, 8
          done()

  describe "GET /nginx.json", ->

    it "returns a JSON with nginx versions info", (done) ->
      supertest(app)
        .get("/nginx.json")
        .expect(200)
        .expect('Content-Type', /application\/json/)
        .end (err, res) ->
          return done(err) if err

          keys = (k for k of res.body)
          assert 'stable' in keys
          assert 'unstable' in keys
          assert 'all' in keys
          done()
