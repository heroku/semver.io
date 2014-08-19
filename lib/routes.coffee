express = require 'express'
cors    = require 'cors'

module.exports = (resolver) ->
  router = new express.Router

  router.get '/', (req, res, next) ->
    res.type 'text'
    res.send resolver.latest_stable

  router.get '/resolve/:range', (req, res, next) ->
    res.type 'text'
    res.send resolver.satisfy(req.params.range)

  router.get '/resolve', (req, res, next) ->
    res.type 'text'
    res.send resolver.satisfy(req.query.range)

  router.get '/stable', (req, res, next) ->
    res.type 'text'
    res.send resolver.latest_stable

  router.get '/unstable', (req, res, next) ->
    res.type 'text'
    res.send resolver.latest_unstable

  router.get '/versions', (req, res, next) ->
    res.type 'text'
    res.send resolver.all.join("\n")

  router.get '/index.json', cors(), (req, res, next) ->
    res.json
      stable: resolver.latest_stable
      unstable: resolver.latest_unstable
      versions: resolver.all

