if (process.env.NODE_ENV === 'production') require('newrelic');
var log = require('./lib/logger');
var App = require('./lib/app');

var PORT = process.env.PORT || 5000;

var app = new App();

app.listen(PORT, function onListen() {
  log({ message: 'listening', port: PORT });
});
