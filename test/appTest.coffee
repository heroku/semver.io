assert = require "assert"
semver = require "semver"
supertest = require "supertest"
app = require "../lib/app"

# app is not 'started' until its resolver is ready.
before (done) ->
  app.start ->
    done()

describe "GET /", ->

  it "redirects to github", (done) ->
    supertest(app)
      .get("/")
      .expect(302)
      .expect('location', 'https://github.com/heroku/semver#readme', done)

describe "GET /node", ->

  it "returns a node version", (done) ->
    supertest(app)
      .get("/node")
      .expect(200)
      .expect('Content-Type', /text\/plain/)
      .end (err, res) ->
        return done(err) if err
        assert semver.valid(res.text)
        done()

describe "GET /node/null", ->

  it "returns a node version", (done) ->
    supertest(app)
      .get("/node")
      .expect(200)
      .expect('Content-Type', /text\/plain/)
      .end (err, res) ->
        return done(err) if err
        assert semver.valid(res.text)
        done()

describe "GET /node/0.8.x", ->

  it "returns a 0.8 node version", (done) ->
    supertest(app)
      .get("/node/0.8.x")
      .expect(200)
      .expect('Content-Type', /text\/plain/)
      .end (err, res) ->
        return done(err) if err
        assert semver.valid(res.text)
        assert.equal semver.parse(res.text).minor, 8
        done()

describe "GET /node/~0.10.15", ->

  it "returns a 0.10 node version", (done) ->
    supertest(app)
      .get("/node/0.10.x")
      .expect(200)
      .expect('Content-Type', /text\/plain/)
      .end (err, res) ->
        return done(err) if err
        assert semver.valid(res.text)
        assert.equal semver.parse(res.text).minor, 10
        assert (semver.parse(res.text).patch > 20)
        done()

describe "GET /node/0.11.5", ->

  it "returns the exact version requested", (done) ->
    supertest(app)
      .get("/node/0.11.5")
      .expect(200)
      .expect('Content-Type', /text\/plain/)
      .end (err, res) ->
        return done(err) if err
        assert.equal res.text, "0.11.5"
        done()

describe "GET /foo", ->

  it "redirects to github", (done) ->
    supertest(app)
      .get("/")
      .expect(302)
      .expect('location', 'https://github.com/heroku/semver#readme', done)