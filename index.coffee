require('newrelic')
app = require('./lib/app')

app.start ->
  app.listen(process.env.PORT or 5000)