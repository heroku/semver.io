request        = require 'request'
semver         = require 'semver'
url            = require 'url'
phpUnserialize = require 'php-unserialize'

class PhpVersionResolver
  PHP_RELEASES_PATH: 'http://php.net/releases/index.php?serialize=1&version=5&max=9999'

  constructor: (callback) ->
    request @PHP_RELEASES_PATH, (err, resp, body) =>
      return callback(err) if err

      versions = Object.keys(phpUnserialize.unserialize(body))

      @all = versions.sort (a, b) -> semver.compare(a, b)

      @latest_stable = @all.last

      do callback

  satisfy: (range) ->
    return @latest_stable unless semver.validRange(range)

    semver.maxSatisfying(@all, range) or
      @latest_stable

  all: -> @all
  latest_stable: -> @latest_stable

module.exports = PhpVersionResolver
