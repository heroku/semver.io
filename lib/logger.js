var logfmt = require('logfmt');

if (process.env.NODE_ENV === 'test') {
  module.exports = function noop() {}
}
else {
  module.exports = function log(obj) {
    logfmt.log(obj);
  }
}
