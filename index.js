if (process.env.NODE_ENV === 'production') require('newrelic');

var App = require('./lib/app');
var app = new App();

app.update(function() {
  app.listen(process.env.PORT || 5000);
});
