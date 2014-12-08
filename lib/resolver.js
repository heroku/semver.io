var _ = require('lodash');
var semver = require('semver');

module.exports = Resolver;

function Resolver(source, minStable, maxStable) {
  this.inStableRange = this.inStableRange.bind(this);
  this.source = source;
  this.minStable = minStable;
  this.maxStable = maxStable;
}

Resolver.prototype.update = function(done) {
  return this.source.update(done);
};

Resolver.prototype.getLatest = function() {
  return _.last(this.source.all);
};

Resolver.prototype.getLatestStable = function() {
  return _.last(this.getStableVersions());
};

Resolver.prototype.getAllVersions = function() {
  return this.source.all;
};

Resolver.prototype.getStableVersions = function() {
  return this.source.stable.filter(this.inStableRange);
};

Resolver.prototype.getUpdatedTime = function() {
  return this.source.updated;
};

Resolver.prototype.satisfy = function(range) {
  if (!semver.validRange(range)) return this.getLatestStable();

  return  semver.maxSatisfying(this.getStableVersions(), range) ||
          semver.maxSatisfying(this.getAllVersions(), range) ||
          this.getLatestStable();
};

Resolver.prototype.inStableRange = function(version) {
  if (this.maxStable && semver.gt(version, this.maxStable)) return false;
  if (this.minStable && semver.lt(version, this.minStable)) return false;
  return true;
}
