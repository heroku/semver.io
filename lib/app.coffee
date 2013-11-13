express = require 'express'
marked = require 'marked'
logfmt  = require 'logfmt'
fs  = require 'fs'
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
  # res.redirect 'https://github.com/heroku/semver#readme'
  res.send(marked(fs.readFileSync("./README.md").toString()))

app.get '/node', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_stable

app.get '/node/resolve/:range', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.satisfy(req.params.range)

app.get '/node/stable', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_stable

app.get '/node/unstable', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_unstable

app.get '/node/versions', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.all.join("\n")

app.get '/:range', (req, res, next) ->
  res.redirect 'https://github.com/heroku/semver#readme'