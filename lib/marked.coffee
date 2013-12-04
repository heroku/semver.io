module.exports = marked = require 'marked'
pygmentize = require 'pygmentize-bundled'

marked.setOptions
  gfm: true
  highlight: (code, lang, callback) ->
    pygmentize
      lang: lang
      format: "html"
    , code, (err, result) ->
      return callback(err)  if err
      callback null, result.toString()

#   tables: true
#   breaks: false
#   pedantic: false
#   sanitize: true
#   smartLists: true
#   smartypants: false
#   langPrefix: "lang-"