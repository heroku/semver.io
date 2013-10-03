express = require 'express'
Resolver = require './resolver'

module.exports = ->

  @app = express()
  @app.configure =>
    @app.use express.bodyParser()
    @app.use @app.router

  @app.resolver = new Resolver()

  @app.get '/', (req, res, next) ->
    res.redirect 'https://github.com/heroku/semver#readme'

  @app.get '/node', (req, res, next) ->
    res.send @app.resolver.latest_stable

  @app.get '/node/:range', (req, res, next) ->
    res.send @app.resolver.satisfy(req.params.range)

  @app.get '/:range', (req, res, next) ->
    res.redirect 'https://github.com/heroku/semver#readme'

  @app.listen(process.env.PORT or 5000)

  @app