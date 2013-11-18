# semver.io

semver.io is a plain-text webservice that resolves [semver ranges](https://npmjs.org/doc/misc/semver.html#Ranges).

semver.io syncs Node.js versions from [nodejs.org/dist](http://nodejs.org/dist).

semver.io is used by the
[Heroku Node.js buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
to resolve `engines.node` in package.json files.

semver.io is open source and available on
GitHub at [heroku/semver](https://github.com/heroku/semver).

semver.io is currently only implemented for Node.js, but is designed to
support any software that follows the semver [rules](http://semver.org/).

## Examples

Get the latest version of node that satisfies a given semver range:

- [/node/resolve/0.10.x](http://semver.io/node/resolve/0.10.x)
- [/node/resolve/0.11.x](http://semver.io/node/resolve/>=0.11.5)
- [/node/resolve/~0.10.15](http://semver.io/node/resolve/~0.10.15)
- [/node/resolve/>0.4](http://semver.io/node/resolve/>0.4)
- [/node/resolve/>=0.8.5 <=0.8.14](http://semver.io/node/resolve/>=0.8.5 <=0.8.14)

These routes are also provided for convenience:

- [/node/stable](http://semver.io/node/stable)
- [/node/unstable](http://semver.io/node/unstable)
- [/node/versions](http://semver.io/node/versions)

## JSON Endpoint

There's also a CORS-friendly HTTP endpoint at
[semver.io/node.json](http://semver.io/node.json) that gives you the whole kit
and caboodle:

```js
{
  stable: "0.10.22",
  unstable: "0.11.8",
  versions: [
    "0.0.1",
    "0.0.2",
    "0.0.3",
    "..."
  ]
}
```

## Caching

semver.io is designed to work even if nodejs.org is down. If the GET request to
[nodejs.org/dist/](http://nodejs.org/dist/) takes too long to resolve, this repo's
`cache/node.html` file will be loaded instead. To update the repo's cached file, run:

```
npm run updateCache
```

## Overriding the Default Stable Version

Occasionaly new versions of node are released on nodejs.org that the world just isn't ready for.
This could be a predictiable change like a bump in minor version from `0.8.25` to `0.10.0`,
or an [unexpectedly unstable release like `0.10.19`](https://github.com/joyent/node/issues/6263).
To override the stable default version, use a config var:

```
heroku config:set STABLE_NODE_VERSION=0.10.18 -a semver
```

When the dust settles, remove the override:

```
heroku config:unset STABLE_NODE_VERSION -a semver
```

## What about npm versions?

npm versions are not tracked because the node binary has shipped with npm
included since node` 0.6.3`. The [buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
ignores `engines.npm`, deferring to node for npm version resolution.

## Tests

```
npm test

GET /
  ✓ renders the readme

GET /node/stable
  ✓ returns a stable node version

GET /node/unstable
  ✓ returns an unstable node version

GET /node/resolve/0.8.x
  ✓ returns a 0.8 node version

GET /node/resolve/~0.10.15
  ✓ returns a 0.10 node version

GET /node/resolve/0.11.5
  ✓ returns the exact version requested
```