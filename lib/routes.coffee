express = require 'express'
cors    = require 'cors'

module.exports = (resolver) ->
  router = new express.Router mergeParams: true

  versions =
    stable: resolver.latest_stable
    unstable: resolver.latest_unstable
    all: resolver.all

  router.get '/', (req, res, next) ->
    if req.params.format is '.json'
      return res.json versions

    res.format
      text: -> res.send resolver.latest_stable
      html: -> res.type('text').send resolver.latest_stable
      json: -> res.json versions

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
