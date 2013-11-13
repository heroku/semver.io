require 'array-sugar'
agent = require 'superagent'
semver  = require 'semver'
fs = require 'fs'
_ = require 'lodash'

module.exports = class Resolver

  # Keep the timeout really short so tests will use the cached
  # file instead of hitting the network.
  @timeout: (if process.env.NODE_ENV is 'test' then 1 else 1000)

  constructor: (cb) ->

    @downloadVersions (err, text) =>
      return console.error("err", err) if err

      # Extract and sort version numbers from HTML text
      @all = _.uniq(text.
        match(/[0-9]+\.[0-9]+\.[0-9]+/g).
        sort (a,b) -> semver.compare(a, b)
      )

      # Stable releases have even-numbered minor versions
      @stables = _.uniq(text.
        match(/[0-9]+\.[0-9]*[02468]\.[0-9]+/g).
        sort (a,b) -> semver.compare(a, b)
      )

      # take any versions greater than the override out of the stables array
      if process.env.STABLE_NODE_VERSION
        @stables = @stables.filter (version) ->
          semver.lte version, process.env.STABLE_NODE_VERSION

      @latest_unstable = @all.last

      @latest_stable = @stables.last

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