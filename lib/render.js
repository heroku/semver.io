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

module.exports = function render(stable, unstable, done) {
  marked(readme, function(err, content) {
    if (err) throw err;
    content = content.replace('{{current_stable_version}}', stable);
    content = content.replace('{{current_unstable_version}}', unstable);
    done(layout.replace('{{content}}', content));
  });
}