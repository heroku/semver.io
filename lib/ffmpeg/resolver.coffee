request = require 'request'
semver  = require 'semver'
url     = require 'url'

extractVersion = (text) ->
  match = String(text).match /\bffmpeg-(\d+\.\d+\.\d+).tar.gz$\b/
  if match then match[1] else null

class FfmpegVersionResolver
  FFMPEG_RELEASES_PATH: 'http://ffmpeg.org/releases'

  constructor: (callback) ->
    request @FFMPEG_RELEASES_PATH, (err, resp, body) =>
      return callback(err) if err

      versions = []
      body.replace /href\s*=\s*(["'])([^\1]+?)\1/gm, (match, delimiter, link) =>
        version = extractVersion link
        versions.push(version) if semver.valid version

      @all = versions.sort (a, b) -> semver.compare(a, b)

      @latest_stable = @all.last

      do callback

  satisfy: (range) ->
    return @latest_stable unless semver.validRange(range)

    semver.maxSatisfying(@all, range) or
      @latest_stable

  all: -> @all
  latest_stable: -> @latest_stable

module.exports = FfmpegVersionResolver
