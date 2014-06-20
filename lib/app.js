var logfmt = require('logfmt');
var _ = require('lodash');
var express = require('express');

var Resolver = require('./resolver');
var render = require('./render');

var MINUTES = 1000 * 60;

module.exports = function App() {
  var app = express();
  var resolver = new Resolver();
  var timeout;

  if (process.env.NODE_ENV !== 'test') app.use(logfmt.requestLogger());
  app.use(express.bodyParser());
  app.use(app.router);

  app
    .get('/', renderInstructions)
    .get('/ssl', typeText, sendSSL)
    .get('/node', typeText, sendStable)
    .get('/node/resolve/:range', typeText, sendSatisfyParams)
    .get('/node/resolve', typeText, sendSatisfyQuery)
    .get('/node/stable', typeText, sendStable)
    .get('/node/unstable', typeText, sendUnstable)
    .get('/node/versions', typeText, sendAllVersions)
    .get('/node.json', sendJSON);

  app.timeout = process.env.RESOLVER_TIMEOUT || 5000;;
  app.updates = 0;
  app.interval = 5 * MINUTES;

  app.update = function(done) {
    clearTimeout(timeout);
    resolver.update(app.timeout, done);
    app.updates++;
    timeout = setTimeout(this.update.bind(this), this.interval);
  }

  return app;

  function renderInstructions(req, res, next) {
    render(resolver.latest_stable, resolver.latest_unstable, function(html) {
      res.send(html);
    });
  }

  function typeText(req, res, next) {
    res.type('text');
    next();
  }

  function sendSSL(req, res, next) {
    res.send([
      '"Demonstration of domain control for DigiCert order #00462258"',
      '"Please send the approval email to: ops@heroku.com"'
    ].join('\n'));
  }

  function sendStable(req, res, next) {
    res.send(resolver.latest_stable);
  }

  function sendSatisfyParams(req, res, next) {
    res.send(resolver.satisfy(req.params.range));
  }

  function sendSatisfyQuery(req, res, next) {
    res.send(resolver.satisfy(req.query.range));
  }

  function sendUnstable(req, res, next) {
    res.send(resolver.latest_unstable);
  }

  function sendAllVersions(req, res, next) {
    res.send(resolver.all.join('\n'));
  }

  function sendJSON(req, res, next) {
    res.json({
      stable: resolver.latest_stable,
      unstable: resolver.latest_unstable,
      versions: resolver.all,
      updated: resolver.updated
    });
  }
}


