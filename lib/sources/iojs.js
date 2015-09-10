var semver = require('semver');
var _ = require('lodash');
var agent = require('superagent');

var SEMVER = /[0-9]+\.[0-9]+\.[0-9]+/g;
var TIMEOUT = 20000;
var NOOP = function() {};

module.exports = IoJsSource;

function IoJsSource(options) {
  _.extend(this, {
    name: 'iojs',
    url: 'https://nodejs.org/download/release/',
    all: [],
    stable: [],
    updated: undefined
  }, options);
}

IoJsSource.prototype.update = function(done) {
  done = done || NOOP;

  agent
    .get(this.url)
    .timeout(TIMEOUT)
    .end(parseResponse.bind(this));

  function parseResponse(err, res) {
    if (err) return done(err, false);
    if (!res.text) return done(new Error('No response'), false);
    if (res.status !== 200) return done(new Error('Bad response'), false);

    this._parse(res.text)
    done(undefined, true);
  }
};

IoJsSource.prototype._parse = function(body) {
  var versions = _.unique(body.match(SEMVER));

  this.all = versions.sort(semver.compare);
  this.stable = versions.filter(isStable);
  this.updated = new Date();

  function isStable(version) {
    return semver.satisfies(version, '>=0.0.0');
  }
};
