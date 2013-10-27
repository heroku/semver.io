require('newrelic')
require('./lib/app').listen(process.env.PORT or 5000)