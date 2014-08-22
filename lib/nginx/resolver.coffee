request = require 'request'
semver  = require 'semver'
url     = require 'url'

extractVersion = (text) ->
  match = String(text).match /\bnginx-(\d+\.\d+\.\d+)\b/
  if match then match[1] else null

class NginxVersionResolver
  NGINX_DOWNLOADS_PATH: 'http://nginx.org/download'

  constructor: (callback) ->
    request @NGINX_DOWNLOADS_PATH, (err, resp, body) =>
      return callback(err) if err

      versions = []
      body.replace /href\s*=\s*(["'])([^\1]+?)\1/gm, (match, delimiter, link) =>
        version = extractVersion link
        versions.push(version) if semver.valid(version) and version not in versions

      @all     = versions.sort (a, b) -> semver.compare(a, b)
      @stables = @all.filter (v) -> semver.parse(v).minor % 2 is 0

      @latest_unstable = @all.last
      @latest_stable   = @stables.last

      do callback

  satisfy: (range) ->
    return @latest_stable unless semver.validRange(range)

    semver.maxSatisfying(@stables, range) or
      semver.maxSatisfying(@all, range) or
      @latest_stable

  all: -> @all
  latest_stable: -> @latest_stable
  latest_unstable: -> @latest_unstable

module.exports = NginxVersionResolver
