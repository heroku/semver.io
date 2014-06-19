process.env.NODE_ENV = 'test'

assert = require "assert"
semver = require "semver"
fs = require "fs"
Resolver = require "../lib/resolver"

describe "Resolver", ->

  r = null # (scope)

  beforeEach ->
    r = new Resolver
    r.parse(fs.readFileSync(__dirname + '/../cache/node.html').toString())

  afterEach ->
    r = null

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
      assert.equal r.satisfy(null), r.latest_stable
      assert.equal r.satisfy(undefined), r.latest_stable
      assert.equal r.satisfy(""), r.latest_stable
      assert.equal r.satisfy("boogers"), r.latest_stable

    it "only includes version >=0.8.6", ->
      assert.equal r.all[0], '0.8.6'
      assert r.all.every (version) -> semver.gte(version, '0.8.6')

  describe "satisfy()", ->

    it "honors explicit version strings", ->
      assert.equal r.satisfy("0.10.1"), "0.10.1"
      assert.equal r.satisfy("0.11.1"), "0.11.1"
      assert.equal r.satisfy("0.8.15"), "0.8.15"

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

    it "returns latest stable for versions that are too old", ->
      assert.equal r.satisfy("0.4.1"), r.latest_stable

  describe "override", ->

    it "becomes latest_stable", (done) ->
      assert.notEqual r.latest_stable, '0.10.15'
      process.env.STABLE_NODE_VERSION = '0.10.15'
      r = new Resolver
      r.parse(fs.readFileSync(__dirname + '/../cache/node.html').toString())
      assert r.latest_stable, '0.10.15'
      done()

    it "satisfies stable-seeking ranges", (done) ->
      assert.notEqual r.satisfy(">0.8"), '0.10.3'
      process.env.STABLE_NODE_VERSION = '0.10.3'
      r = new Resolver
      r.parse(fs.readFileSync(__dirname + '/../cache/node.html').toString())
      assert.equal r.satisfy(">0.8"), '0.10.3'
      done()

    it "still resolves unstable ranges", (done) ->
      assert.equal semver.parse(r.satisfy('0.11.x')).minor, 11
      process.env.STABLE_NODE_VERSION = '0.8.20'
      r = new Resolver
      r.parse(fs.readFileSync(__dirname + '/../cache/node.html').toString())
      assert.equal semver.parse(r.satisfy('0.11.x')).minor, 11
      done()

    it "still resolves versions at a higher patchlevel than the override", (done) ->
      process.env.STABLE_NODE_VERSION = '0.10.18'
      r = new Resolver
      r.parse(fs.readFileSync(__dirname + '/../cache/node.html').toString())
      assert.equal r.satisfy('0.10.19'), '0.10.19'
      done()
      