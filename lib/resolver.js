var semver = require('semver');
var _ = require('lodash');

var ALL = /[0-9]+\.[0-9]+\.[0-9]+/g;
var STABLE = /[0-9]+\.[0-9]*[02468]\.[0-9]+/g;

function Resolver() {
  this.stable = '';
  this.unstable = '';
  this.all = [];
  this.stables = [''];
}

Resolver.prototype.parse = function(body) {
  this.all = _.unique(body
    .match(ALL)
    .filter(minVersion)
    .sort(versionAsc)
  );

  this.stables = _.unique(body
    .match(STABLE)
    .filter(minVersion)
    .sort(versionAsc)
  );

  if (process.env.STABLE_NODE_VERSION) {
    this.stables = this.stables.filter(maxVersion);
  }

  this.unstable = _.last(this.all);
  this.stable = _.last(this.stables);

  function minVersion(version) {
    return semver.gte(version, '0.8.6');
  }

  function maxVersion(version) {
    return semver.lte(version, process.env.STABLE_NODE_VERSION);
  }

  function versionAsc(a, b) {
    return semver.compare(a, b);
  }
};

Resolver.prototype.satisfy = function(range) {
  if (!semver.validRange(range)) return this.stable;

  return  semver.maxSatisfying(this.stables, range) ||
          semver.maxSatisfying(this.all, range) ||
          this.stable;
};

module.exports = Resolver;
