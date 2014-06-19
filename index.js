if (process.env.NODE_ENV === 'production') require('newrelic');

var App = require('./lib/app');
var app = new App();

app.init(function onInit() {
  app.listen(process.env.PORT || 5000);
});
