assert = require "assert"
semver = require "semver"
Resolver = require "../lib/resolver"

describe "Resolver", ->

  r = null # (scope)

  beforeEach (done) ->
    r = new Resolver ->
      done()

  afterEach (done) ->
    r = null
    done()

  describe "initialization", ->

    it "has an array of all versions", ->
      assert.equal typeof(r.all), "object"

    it "has an array of stable versions", ->
      assert.equal typeof(r.stables), "object"

    it "has a latest_stable version", ->
      assert.equal typeof(r.latest_stable), "string"

    it "has a latest_unstable version", ->
      assert.equal typeof(r.latest_unstable), "string"

    it "defaults to latest stable version when given crazy input", ->
      assert.equal r.latest_stable, r.satisfy(null)
      assert.equal r.latest_stable, r.satisfy(undefined)
      assert.equal r.latest_stable, r.satisfy("")
      assert.equal r.latest_stable, r.satisfy("boogers")
      # assert.equal r.latest_stable, r.satisfy("0.0")
      # assert.equal r.latest_stable, r.satisfy("2.0")

  describe "satisfy()", ->

    it "honors explicit version strings", ->
      assert.equal r.satisfy("0.10.1"), "0.10.1"
      assert.equal r.satisfy("0.11.1"), "0.11.1"
      assert.equal r.satisfy("0.4.5"), "0.4.5"

    it "matches common patterns to stable version", ->
      assert.equal r.satisfy("0.10.x"), r.latest_stable
      assert.equal r.satisfy("~0.10.0"), r.latest_stable
      assert.equal r.satisfy(">0.4"), r.latest_stable
      assert.equal r.satisfy(">=0.6.9"), r.latest_stable
      assert.equal r.satisfy("*"), r.latest_stable

    it "uses latest unstable version when request version is beyond stable version", ->
      assert.equal r.satisfy("0.11.x"), r.latest_unstable
      assert.equal r.satisfy("~0.11.0"), r.latest_unstable
      assert.equal r.satisfy(">0.11.0"), r.latest_unstable
      assert.equal r.satisfy(">=0.10.100"), r.latest_unstable

  describe "override", ->

    it "becomes latest_stable", (done) ->
      assert.notEqual r.latest_stable, '0.10.15'
      process.env.STABLE_NODE_VERSION = '0.10.15'
      r = new Resolver ->
        assert r.latest_stable, '0.10.15'
        done()

    it "satisfies stable-seeking ranges", (done) ->
      assert.notEqual r.satisfy(">0.8"), '0.10.3'
      process.env.STABLE_NODE_VERSION = '0.10.3'
      r = new Resolver ->
        assert.equal r.satisfy(">0.8"), '0.10.3'
        done()

    it "still resolves unstable ranges", (done) ->
      assert.equal semver.parse(r.satisfy('0.11.x')).minor, 11
      process.env.STABLE_NODE_VERSION = '0.8.20'
      r = new Resolver ->
        assert.equal semver.parse(r.satisfy('0.11.x')).minor, 11
        done()

    it "honors specific versions that are newer than the override version", (done) ->
      process.env.STABLE_NODE_VERSION = '0.10.18'
      r = new Resolver ->
        assert.equal r.satisfy('0.10.19'), '0.10.19'
        done()