var logfmt = require('logfmt');
var _ = require('lodash');
var express = require('express');
var fs = require('fs');

var Resolver = require('./resolver');
var render = require('./render');

function createApp(opts) {
  var app = express();
  var options = _.extend({}, opts);
  var resolver = new Resolver();

  resolver.parse(fs.readFileSync(__dirname + '/../cache/node.html').toString());

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

  return app;

  function renderInstructions(req, res, next) {
    render(resolver.stable, resolver.unstable, function(html) {
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
    res.send(resolver.stable);
  }

  function sendSatisfyParams(req, res, next) {
    res.send(resolver.satisfy(req.params.range));
  }

  function sendSatisfyQuery(req, res, next) {
    res.send(resolver.satisfy(req.query.range));
  }

  function sendUnstable(req, res, next) {
    res.send(resolver.unstable);
  }

  function sendAllVersions(req, res, next) {
    res.send(resolver.all.join('\n'));
  }

  function sendJSON(req, res, next) {
    res.json({
      stable: resolver.stable,
      unstable: resolver.unstable,
      versions: resolver.all
    });
  }
}

module.exports = createApp;

