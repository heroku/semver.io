# semver.io

semver.io is a plaintext and JSON webservice that tracks [all available versions of node.js](http://nodejs.org/dist) and uses that version info to resolve [semver range queries](https://npmjs.org/doc/misc/semver.html#Ranges). It's used by heroku's
[node buildpack](https://github.com/heroku/heroku-buildpack-nodejs/blob/5754e60de7b8472d5070c9b713a898d353845c68/bin/compile#L18-22) and is open-sourced [on github](https://github.com/heroku/semver).

## On the command line

```sh
curl http://semver.io/node/stable
# 0.10.22

curl http://semver.io/node/unstable
# 0.11.9

curl http://semver.io/node/resolve/0.8.x
# 0.8.26
```

## In the browser

There a CORS-friendly HTTP endpoint at
[semver.io/node.json](http://semver.io/node.json) that gives you the whole kit
and caboodle:

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

semver.io supports any range that [isaacs/node-semver](https://github.com/isaacs/node-semver) can parse. Here are some examples:

- [/node/resolve/0.10.x](http://semver.io/node/resolve/0.10.x)
- [/node/resolve/0.11.x](http://semver.io/node/resolve/>=0.11.5)
- [/node/resolve/~0.10.15](http://semver.io/node/resolve/~0.10.15)
- [/node/resolve/>0.4](http://semver.io/node/resolve/>0.4)
- [/node/resolve/>=0.8.5 <=0.8.14](http://semver.io/node/resolve/>=0.8.5 <=0.8.14)

These named routes are also provided for convenience:

- [/node/stable](http://semver.io/node/stable)
- [/node/unstable](http://semver.io/node/unstable)
- [/node/versions](http://semver.io/node/versions)

## How does it work?

Under the hood, semver.io is powered by [node-version-resolver](https://npmjs.org/package/node-version-resolver), a node module that does all the work of talking to nodejs.org and parsing version data.

While currently only implemented for node, semver.io is designed to support any software that follows the semver [rules](http://semver.org/).

## What about npm versions?

npm versions are not tracked because the node binary has shipped with npm
included since node `0.6.3`. The [buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
ignores `engines.npm`, deferring to node for npm version resolution.

## Links

- [what-is-the-latest-version-of-node.com](http://what-is-the-latest-version-of-node.com)
- [semver.org](http://semver.org)
- [github.com/heroku/heroku-buildpack-nodejs](https://github.com/heroku/heroku-buildpack-nodejs#readme)
- [github.com/heroku/semver.io](https://github.com/heroku/semver.io#readme)
- [github.com/isaacs/node-semver](https://github.com/isaacs/node-semver#readme)
- [npmjs.org/doc/misc/semver.html#Ranges](https://npmjs.org/doc/misc/semver.html#Ranges)
- [npmjs.org/package/node-version-resolver](https://npmjs.org/package/node-version-resolver)
