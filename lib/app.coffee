bodyParser = require 'body-parser'
express    = require 'express'
marked     = require './marked'
routes     = require './routes'
logfmt     = require 'logfmt'
async      = require 'async'
fs         = require 'fs'

NodeResolver  = require './node/resolver'
NginxResolver = require './nginx/resolver'

module.exports = app = express()

app.use logfmt.requestLogger() unless process.env.NODE_ENV is "test"
app.use bodyParser(extented: false)

# app is not 'started' until its resolver is ready.
app.start = (cb) ->
  return cb() if app.nodeResolver and app.nginxResolver
  async.parallel({
    node: (done) ->
      nodeResolver = new NodeResolver ->
        app.use '/node', routes(nodeResolver)
        done(null, nodeResolver)
    nginx: (done) ->
      nginxResolver = new NginxResolver ->
        app.use '/nginx', routes(nginxResolver)
        done(null, nginxResolver)
  }, (err, results) ->
    return cb(err) if err

    app.nodeResolver  = results.node
    app.nginxResolver = results.nginx

    do cb
  )

app.get '/', (req, res, next) ->
  layout = fs.readFileSync("./public/layout.html").toString()
  readme = fs.readFileSync("./README.md").toString()
  # marked must be used in an async fashion here to enable
  # pygments code syntax highlighting.

  marked readme, (err, content) ->
    content = content.replace "{{current_stable_version}}", app.nodeResolver.latest_stable.toString()
    content = content.replace "{{current_unstable_version}}", app.nodeResolver.latest_unstable.toString()

    throw err if err

    res.send layout.replace("{{content}}", content)

app.get '/ssl', (req, res, next) ->
  res.type 'text'
  res.send """
    "Demonstration of domain control for DigiCert order #00462258"
    "Please send the approval email to: ops@heroku.com"
  """
