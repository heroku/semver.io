var marked = require('marked');
var pygmentize = require('pygmentize-bundled');
var rfs = require('fs').readFileSync;

marked.setOptions({
  gfm: true,
  highlight: function(code, lang, done) {
    pygmentize({ lang: lang, format: 'html'}, code, onHighlight);

    function onHighlight(err, result) {
      if (err) return done(err);
      done(null, result.toString());
    }
  }
});

var layout = rfs('./public/layout.html').toString();
var readme = rfs('./README.md').toString();

module.exports = function render(resolvers, done) {
  marked(readme, injectIntoLayout);

  function injectIntoLayout(err, content) {
    if (err) throw err;
    done(undefined, layout.replace('{{content}}', content));
  }
}
