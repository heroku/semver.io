assert = require "assert"
Resolver = require "../lib/resolver"

describe "Resolver", ->

  r = null

  before (done) ->
    r = new Resolver ->
      done()

  it "has an array of all versions", ->
    assert.equal typeof(r.all), "object"

  it "has an array of stable versions", ->
    assert.equal typeof(r.stables), "object"

  it "has a latest_stable version", ->
    assert.equal typeof(r.latest_stable), "string"

  it "has a latest_unstable version", ->
    assert.equal typeof(r.latest_unstable), "string"

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

  it "defaults to latest stable version when given crazy input", ->
    # assert.equal r.latest_stable, r.satisfy("0.0")
    # assert.equal r.latest_stable, r.satisfy("2.0")
    assert.equal r.latest_stable, r.satisfy("snake-eyes")