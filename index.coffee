require('newrelic')

# Instead of being defined here, the app is included as a module.
# This makes it easier to test.
app = require('./lib/app')

app.start ->
  app.listen(process.env.PORT or 5000)