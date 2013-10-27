agent = require 'superagent'
semver  = require 'semver'
fs = require 'fs'

module.exports = class Resolver

  @timeout: 1000

  constructor: (cb) ->

    @downloadVersions (err, text) =>
      return console.error("err", err) if err

      # Extract and sort version numbers from HTML text
      @all = text.
        match(/[0-9]+\.[0-9]+\.[0-9]+/g).
        sort (a,b) -> semver.compare(a, b)

      # Stable releases have even-numbered minor versions
      @stables = text.
        match(/[0-9]+\.[0-9]*[02468]\.[0-9]+/g).
        sort (a,b) -> semver.compare(a, b)

      # remove any stable versions greater than the override
      if process.env.STABLE_NODE_VERSION
        @stables = @stables.filter (version) ->
          semver.lte version, process.env.STABLE_NODE_VERSION

      @latest_unstable = @all[@all.length - 1]

      @latest_stable = @stables[@stables.length - 1]

      cb(@) if cb

  downloadVersions: (cb) ->
    agent.get("http://nodejs.org/dist/").timeout(Resolver.timeout).end (err, res) ->
      # Use the cached file if request timed out.
      return cb null, fs.readFileSync('cache/node.html').toString() if err
      cb null, res.text

  satisfy: (range) ->
    # If input is funky, default to latest stable
    return @latest_stable unless semver.validRange(range)

    semver.maxSatisfying(@stables, range) or
      semver.maxSatisfying(@all, range) or
      @latest_stable