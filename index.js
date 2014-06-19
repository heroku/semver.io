if (process.env.NODE_ENV === 'production') require('newrelic');

var app = require('./lib/app');

app().listen(process.env.PORT || 5000);
