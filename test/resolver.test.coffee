assert = require "assert"
semver = require "semver"
supertest = require "supertest"

Resolver = require "../lib/resolver"
Source = require "./fixtures/source"

describe "Resolver", ->

  describe "satisfy()", ->

    before ->
      this.r = new Resolver(new Source())

    it "honors explicit version strings", ->
      assert.equal this.r.satisfy("0.10.1"), "0.10.1"
      assert.equal this.r.satisfy("0.11.1"), "0.11.1"
      assert.equal this.r.satisfy("0.8.15"), "0.8.15"

    it "matches common patterns to stable version", ->
      assert.equal this.r.satisfy("4.1.x"), this.r.getLatestStable()
      assert.equal this.r.satisfy("~4.1.0"), this.r.getLatestStable()
      assert.equal this.r.satisfy(">0.4"), this.r.getLatestStable()
      assert.equal this.r.satisfy(">=0.6.9"), this.r.getLatestStable()
      assert.equal this.r.satisfy("*"), this.r.getLatestStable()

    it "uses latest unstable version when request version is beyond stable version", ->
      assert.equal this.r.satisfy("^4.2.0-alpha"), this.r.getLatest()
      assert.equal this.r.satisfy("~4.2.0-alpha"), this.r.getLatest()
      assert.equal this.r.satisfy(">4.2.0-alpha"), this.r.getLatest()
      assert.equal this.r.satisfy(">=4.2.0-alpha"), this.r.getLatest()

    it "defaults to latest stable version when given crazy input", ->
      assert.equal this.r.satisfy(null), this.r.getLatestStable()
      assert.equal this.r.satisfy(undefined), this.r.getLatestStable()
      assert.equal this.r.satisfy(""), this.r.getLatestStable()
      assert.equal this.r.satisfy("boogers"), this.r.getLatestStable()

    describe "with environment override", ->

      it "obeys maximum stable limit", ->
        r = new Resolver(new Source(), null, '0.10.15')
        assert.equal r.getLatestStable(), '0.10.15'

      it "obeys minimum stable limit", ->
        r = new Resolver(new Source(), '0.2.6')
        assert.equal r.getStableVersions()[0], '0.2.6'

      it "satisfies stable-seeking ranges", ->
        r = new Resolver(new Source(), null, '0.10.3')
        assert.equal r.satisfy('>0.8'), '0.10.3'

      it "still resolves unstable ranges", ->
        r = new Resolver(new Source(), null, '0.8.20')
        assert.equal semver.parse(r.satisfy('0.11.x')).minor, 11

      it "still resolves versions at a higher patchlevel than the override", ->
        r = new Resolver(new Source(), null, '0.10.18')
        assert.equal r.satisfy('0.10.19'), '0.10.19'

  describe "start(200)", ->

    it "polls about 5 times in 1000ms", (done) ->
      s = new Source()
      r = new Resolver(s, null, null)
      r.start(200)
      check = ->
        assert s.updateCount >= 4 and s.updateCount <= 6
        done()
      setTimeout check, 1000

  describe "stop()", ->

    before (done) ->
      this.s = new Source()
      this.r = new Resolver(this.s, null, null)
      this.r.start(200)
      done()

    it "stops polling", (done) ->
      s = this.s
      r = this.r
      stop = ->
        r.stop()
      check = ->
        assert s.updateCount > 1 and s.updateCount < 4
        done()
      setTimeout stop, 700
      setTimeout check, 1200
