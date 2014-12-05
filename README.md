# semver.io

semver.io is a plaintext and JSON webservice
that tracks all available versions of
[node.js](/node/versions),
[npm](/npm/versions),
and [nginx](/nginx/versions).
It uses that version info to resolve
[semver range queries](https://npmjs.org/doc/misc/semver.html#Ranges).
It's used by Heroku's
[node buildpack](https://github.com/heroku/heroku-buildpack-nodejs/blob/5754e60de7b8472d5070c9b713a898d353845c68/bin/compile#L18-22)
and is open-sourced [on GitHub](https://github.com/heroku/semver.io).

## Other sources

Semver.io uses a simple and short module system to pull version data from a variety of sources.
Pull requests are welcome!
You can start with one of the current implementations as a template:

- [node module](https://github.com/heroku/semver.io/blob/master/lib/sources/node.js)
- [npm module](https://github.com/heroku/semver.io/blob/master/lib/sources/npm.js)
- [nginx module](https://github.com/heroku/semver.io/blob/master/lib/sources/nginx.js)

## Usage

### Command-line

```sh
curl https://semver.io/node/stable
# {{node:current_stable_version}}

curl https://semver.io/node/unstable
# {{node:current_unstable_version}}

curl https://semver.io/node/resolve/0.8.x
# 0.8.26

curl https://semver.io/nginx/stable
# {{nginx:current_stable_version}}

```

### In the browser

There are CORS-friendly HTTP endpoints for each source
with the whole kit and caboodle:

- [semver.io/node.json](https://semver.io/node.json)
- [semver.io/npm.json](https://semver.io/npm.json)
- [semver.io/nginx.json](https://semver.io/nginx.json)

The response is something like:

```json
{
  "stable": "0.10.22",
  "unstable": "0.11.8",
  "versions": [
    "0.8.6",
    "...",
    "0.11.9"
  ]
}
```

## Ranges

semver.io supports any range that [node-semver](https://github.com/isaacs/node-semver) can parse.
For example:

- [/node/resolve/0.10.x](https://semver.io/node/resolve/0.10.x)
- [/node/resolve/0.11.x](https://semver.io/node/resolve/>=0.11.5)
- [/node/resolve/~0.10.15](https://semver.io/node/resolve/~0.10.15)
- [/node/resolve/>0.4](https://semver.io/node/resolve/>0.4)
- [/node/resolve/>=0.8.5 <=0.8.14](https://semver.io/node/resolve/>=0.8.5 <=0.8.14)

These named routes are also provided for convenience:

- [/node/stable](https://semver.io/node/stable)
- [/node/versions](https://semver.io/node/versions)
- [/nginx/unstable](https://semver.io/nginx/unstable)

## Links

- [what-is-the-latest-version-of-node.com](http://what-is-the-latest-version-of-node.com)
- [semver.org](http://semver.org)
- [github.com/heroku/heroku-buildpack-nodejs](https://github.com/heroku/heroku-buildpack-nodejs#readme)
- [github.com/heroku/semver.io](https://github.com/heroku/semver.io#readme)
- [github.com/isaacs/node-semver](https://github.com/isaacs/node-semver#readme)
- [npmjs.org/doc/misc/semver.html#Ranges](https://npmjs.org/doc/misc/semver.html#Ranges)
- [npmjs.org/package/node-version-resolver](https://npmjs.org/package/node-version-resolver)
