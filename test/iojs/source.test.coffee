process.env.NODE_ENV = 'test'

assert = require "assert"
semver = require "semver"
fs = require "fs"

Source = require "../../lib/sources/iojs"
html = fs.readFileSync(__dirname + '/../fixtures/iojs.html').toString();

describe "IoJs Source", ->

  describe "default properties", ->

    before ->
      this.s = new Source()

    it "defaults to empty all array", ->
      assert.equal this.s.all.length, 0

    it "default to empty stable array", ->
      assert.equal this.s.stable.length, 0

    it "defaults to the 'https://nodejs.org/download/release/' url", ->
      assert.equal this.s.url, 'https://nodejs.org/download/release/'

    it "has never been updated", ->
      assert.ok !this.s.updated

  describe "_parse()", ->

    before ->
      this.s = new Source()
      this.s._parse(html)

    it "has an array of all versions", ->
      assert.equal typeof(this.s.all), "object"
      assert.equal this.s.all.length, 2
      assert.equal this.s.all[0], '1.0.0'

    it "has an array of stable versions", ->
      assert.equal typeof(this.s.stable), "object"
      assert.equal this.s.stable.length, 2
      assert.equal this.s.stable[0], '1.0.0'

    it "has been updated", ->
      assert.ok this.s.updated
