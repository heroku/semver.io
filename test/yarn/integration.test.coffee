assert = require "assert"
semver = require "semver"
supertest = require "supertest"

App = require "../../lib/app"
Resolver = require "../../lib/resolver"
YarnSource = require "../../lib/sources/yarn"

app = new App({
  yarn: new Resolver(new YarnSource()),
});

failingApp = new App({
  yarn: new Resolver(new YarnSource())
});

describe "Yarn Routes", ->

  describe "Initialization", ->

    it "updates the app", (done) ->
      this.timeout(20000)
      app.resolvers.yarn.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "prime's the failing app's cache", (done) ->
      this.timeout(20000)
      failingApp.resolvers.yarn.update (err, updated) ->
        assert(!err)
        assert(updated)
        done()

    it "redirects the failing app to a false endpoint", (done) ->
      this.timeout(20000)
      failingApp.resolvers.yarn.source.registry = 'https://fail.npmjs.com/';
      failingApp.resolvers.yarn.update (err, updated) ->
        assert(err)
        assert(!updated)
        done()


  describe "GET /yarn/stable", ->

    it "returns a stable yarn version", (done) ->
      supertest(app)
        .get("/yarn/stable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/yarn/stable")
        .expect(200)
        .expect('content-type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

  describe "GET /yarn/unstable", ->

    it "returns an unstable yarn version", (done) ->
      supertest(app)
        .get("/yarn/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/yarn/unstable")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          done()

  describe "GET /yarn/resolve/0.17.x", ->

    it "returns a 0.17 yarn version", (done) ->
      supertest(app)
        .get("/yarn/resolve/0.17.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 0
          assert.equal semver(res.text).minor, 17
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/yarn/resolve/0.17.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 0
          assert.equal semver(res.text).minor, 17
          done()

  describe "GET /yarn/resolve/~0.16.1", ->

    it "returns a 0.16 yarn version", (done) ->
      supertest(app)
        .get("/yarn/resolve/~0.16.1")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 0
          assert.equal semver(res.text).minor, 16
          assert semver(res.text).patch > 0
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/yarn/resolve/~0.16.1")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert semver.valid(res.text)
          assert.equal semver(res.text).major, 0
          assert.equal semver(res.text).minor, 16
          assert semver(res.text).patch > 0
          done()

  describe "GET /yarn/resolve/0.17.10", ->

    it "returns the exact version requested", (done) ->
      supertest(app)
        .get("/yarn/resolve/0.17.10")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "0.17.10"
          done()

    it "works with a failing endpoint", (done) ->
      supertest(failingApp)
        .get("/yarn/resolve/0.17.10")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal res.text, "0.17.10"
          done()

  describe "GET /yarn/resolve?range=0.16.x", ->

    it "allows range as a query param", (done) ->
      supertest(app)
        .get("/yarn/resolve?range=0.16.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).major, 0
          assert.equal semver.parse(res.text).minor, 16
          done()

    it "works with a failing endpoint", (done) ->
      supertest(app)
        .get("/yarn/resolve?range=0.16.x")
        .expect(200)
        .expect('Content-Type', /text\/plain/)
        .end (err, res) ->
          return done(err) if err
          assert.equal semver.parse(res.text).major, 0
          assert.equal semver.parse(res.text).minor, 16
          done()
