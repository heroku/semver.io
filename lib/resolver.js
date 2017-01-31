var _ = require('lodash');
var semver = require('semver');
var log = require('./logger');

module.exports = Resolver;

function Resolver(source) {
  this._poll = this._poll.bind(this);
  this.frequency = 0;

  this.source = source;
}

Resolver.prototype.update = function(done) {
  log({ message: 'resolving', source: this.source.name });
  this.source.update(onUpdate.bind(this));

  function onUpdate(err, success) {
    log({ message: 'updated', source: this.source.name, success: success });
    done(err, success);
  }
};

Resolver.prototype.start = function(frequency) {
  this.frequency = frequency;
  this._poll();
};

Resolver.prototype.stop = function() {
  this.frequency = 0;
};

Resolver.prototype._poll = function() {
  if (this.frequency === 0) return;

  this.update(function onUpdate(err, success) {
    setTimeout(this._poll, this.frequency).unref();
  }.bind(this));
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
  return this.source.stable;
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
