bodyParser = require 'body-parser'
express    = require 'express'
marked     = require './marked'
routes     = require './routes'
logfmt     = require 'logfmt'
async      = require 'async'
fs         = require 'fs'

NodeResolver   = require './node/resolver'
NginxResolver  = require './nginx/resolver'
FfmpegResolver = require './ffmpeg/resolver'

module.exports = app = express()

app.use logfmt.requestLogger() unless process.env.NODE_ENV is "test"
app.use bodyParser(extented: false)

# app is not 'started' until its resolver is ready.
app.start = (cb) ->
  return cb() if app.nodeResolver and app.nginxResolver and app.ffmpegResolver
  async.parallel({
    node: (done) ->
      nodeResolver = new NodeResolver ->
        app.use '/node:format?', routes(nodeResolver)
        done(null, nodeResolver)
    nginx: (done) ->
      nginxResolver = new NginxResolver ->
        app.use '/nginx:format?', routes(nginxResolver)
        done(null, nginxResolver)
    ffmpeg: (done) ->
      ffmpegResolver = new FfmpegResolver ->
        app.use '/ffmpeg:format?', routes(ffmpegResolver)
        done(null, ffmpegResolver)
  }, (err, results) ->
    return cb(err) if err

    app.nodeResolver   = results.node
    app.nginxResolver  = results.nginx
    app.ffmpegResolver = results.ffmpeg

    do cb
  )

app.get '/', (req, res, next) ->
  layout = fs.readFileSync("./public/layout.html").toString()
  readme = fs.readFileSync("./README.md").toString()
  # marked must be used in an async fashion here to enable
  # pygments code syntax highlighting.

  marked readme, (err, content) ->
    content =
      content
        .replace "{{node:current_stable_version}}", app.nodeResolver.latest_stable.toString()
        .replace "{{node:current_unstable_version}}", app.nodeResolver.latest_unstable.toString()
        .replace "{{nginx:current_stable_version}}", app.nginxResolver.latest_stable.toString()
        .replace "{{nginx:current_unstable_version}}", app.nginxResolver.latest_unstable.toString()
        .replace "{{ffmpeg:current_stable_version}}", app.ffmpegResolver.latest_stable.toString()

    throw err if err

    res.send layout.replace("{{content}}", content)

app.get '/ssl', (req, res, next) ->
  res.type 'text'
  res.send """
    "Demonstration of domain control for DigiCert order #00462258"
    "Please send the approval email to: ops@heroku.com"
  """
