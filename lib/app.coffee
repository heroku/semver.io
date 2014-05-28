express = require 'express'
marked = require './marked'
logfmt  = require 'logfmt'
fs  = require 'fs'
cors = require 'cors'
Resolver = require 'node-version-resolver'

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
  layout = fs.readFileSync("./public/layout.html").toString()
  readme = fs.readFileSync("./README.md").toString()
  # marked must be used in an async fashion here to enable
  # pygments code syntax highlighting.

  marked readme, (err, content) ->
    content = content.replace("{{current_stable_version}}", app.resolver.latest_stable.toString())
    content = content.replace("{{current_unstable_version}}", app.resolver.latest_unstable.toString())
    throw err if err
    res.send layout.replace("{{content}}", content)

app.get '/ssl', (req, res, next) ->
  res.type 'text'
  res.send """
    "Demonstration of domain control for DigiCert order #00462258"
    "Please send the approval email to: ops@heroku.com"
  """

app.get '/node', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_stable

app.get '/node/resolve/:range', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.satisfy(req.params.range)

app.get '/node/resolve', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.satisfy(req.query.range)

app.get '/node/stable', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_stable

app.get '/node/unstable', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.latest_unstable

app.get '/node/versions', (req, res, next) ->
  res.type 'text'
  res.send app.resolver.all.join("\n")

app.get '/node.json', cors(), (req, res, next) ->
  res.json
    stable: app.resolver.latest_stable
    unstable: app.resolver.latest_unstable
    versions: app.resolver.all
