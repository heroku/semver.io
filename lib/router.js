var express = require('express');

var FIVE_MINUTES = 5 * 60 * 1000;

module.exports = function createRouter(resolver) {
  var router = new express.Router({ mergeParams: true });

  // Start polling the resolver's target to keep a cached copy in memory
  poll();

  router
    .get('/', sendJSON, typeText, sendStable)
    .get('/resolve/:range', typeText, sendSatisfyParams)
    .get('/resolve', typeText, sendSatisfyQuery)
    .get('/stable', typeText, sendStable)
    .get('/unstable', typeText, sendUnstable)
    .get('/versions', typeText, sendAllVersions)

  return router;

  function poll() {
    resolver.update(setTimeout.bind(this, poll, FIVE_MINUTES));
  }

  function typeText(req, res, next) {
    res.type('text');
    next();
  }

  function sendStable(req, res, next) {
    res.send(resolver.getLatestStable());
  }

  function sendSatisfyParams(req, res, next) {
    res.send(resolver.satisfy(req.params.range));
  }

  function sendSatisfyQuery(req, res, next) {
    res.send(resolver.satisfy(req.query.range));
  }

  function sendUnstable(req, res, next) {
    res.send(resolver.getLatest());
  }

  function sendAllVersions(req, res, next) {
    res.send(resolver.getAllVersions().join('\n'));
  }

  function sendJSON(req, res, next) {
    if (req.params.format !== '.json') return next();
    res.json({
      stable: resolver.getLatestStable(),
      unstable: resolver.getLatest(),
      all: resolver.getAllVersions(),
      stableVersions: resolver.getStableVersions(),
      updated: resolver.getUpdatedTime()
    });
  }
};
