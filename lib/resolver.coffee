agent = require 'superagent'
semver  = require 'semver'

module.exports = class Resolver

  constructor: (cb) ->

    agent.get "http://nodejs.org/dist/", (page) =>
      @all = page.text.
        match(/[0-9]+\.[0-9]+\.[0-9]+/g).
        sort (a,b) -> semver.compare(a, b)

      # Stable releases have even minor versions
      @stables = page.text.
        match(/[0-9]+\.[0-9]*[02468]\.[0-9]+/g).
        sort (a,b) -> semver.compare(a, b)

      @latest_unstable = @all[@all.length - 1]

      @latest_stable = process.env.DEFAULT_VERSION_OVERRIDE or
        @stables[@stables.length - 1]

      cb(@) if cb

  satisfy: (range) ->
    return @latest_stable unless semver.validRange(range)

    semver.maxSatisfying(@stables, range) or semver.maxSatisfying(@all, range) or @latest_stable

