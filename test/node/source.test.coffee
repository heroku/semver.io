process.env.NODE_ENV = 'test'

assert = require "assert"
semver = require "semver"
fs = require "fs"

Source = require "../../lib/sources/node"
html = fs.readFileSync(__dirname + '/../fixtures/node.html').toString();

describe "Node Source", ->

  describe "default properties", ->

    before ->
      this.s = new Source()

    it "defaults to empty all array", ->
      assert.equal this.s.all.length, 0

    it "default to empty stable array", ->
      assert.equal this.s.stable.length, 0

    it "defaults to the 'http://nodejs.org/dist/' url", ->
      assert.equal this.s.url, 'http://nodejs.org/dist/'

    it "has never been updated", ->
      assert.ok !this.s.updated

  describe "_parse()", ->

    before ->
      this.s = new Source()
      this.s._parse(html)

    it "has an array of all versions", ->
      assert.equal typeof(this.s.all), "object"
      assert.equal this.s.all.length, 215
      assert.equal this.s.all[214], '0.11.13'

    it "has an array of stable versions", ->
      assert.equal typeof(this.s.stable), "object"
      assert.equal this.s.stable.length, 106
      assert.equal this.s.stable[105], '0.10.29'

    it "has been updated", ->
      assert.ok this.s.updated
