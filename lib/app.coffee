express = require 'express'
logfmt  = require 'logfmt'
Resolver = require './resolver'

module.exports = app = express()

app.configure =>
  app.use logfmt.requestLogger() unless process.env.NODE_ENV is "test"
  app.use express.bodyParser()
  app.use app.router

# app is not 'started' until its resolver is ready.
app.start = (cb) =>
  return cb() if app.resolver
  app.resolver = new Resolver(cb)

app.get '/', (req, res, next) ->
  res.redirect 'https://github.com/heroku/semver#readme'

app.get '/node', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_stable

app.get '/node/:range', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.satisfy(req.params.range)

app.get '/:range', (req, res, next) ->
  res.redirect 'https://github.com/heroku/semver#readme'