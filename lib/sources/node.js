var semver = require('semver');
var _ = require('lodash');
var agent = require('superagent');

var SEMVER = /[0-9]+\.[0-9]+\.[0-9]+/g;
var TIMEOUT = 20000;
var NOOP = function() {};

var DEFAULTS = {
  url: 'http://nodejs.org/dist/',
  all: [],
  stable: [],
  updated: undefined
};

module.exports = NodeSource;

function NodeSource(options) {
  _.extend(this, DEFAULTS, options);
}

NodeSource.prototype.update = function(done) {
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

NodeSource.prototype._parse = function(body) {
  var versions = _.unique(body.match(SEMVER));

  this.all = versions.sort(semver.compare);
  this.stable = versions.filter(isEven);
  this.updated = new Date();

  function isEven(version) {
    return semver(version).minor % 2 === 0;
  }
};
