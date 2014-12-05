var App = require('./lib/app');
if (process.env.NODE_ENV === 'production') {
  require('newrelic');
}

var port = process.env.PORT || 5000;
var app = new App();

app.listen(port);
console.log('Listening on', port);
