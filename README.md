# semver.io

semver.io is a plain-text webservice that resolves [semver ranges](https://npmjs.org/doc/misc/semver.html#Ranges).
It is currently only implemented for Node.js, but is designed to
support any software that follows the semver [rules](http://semver.org/).

semver.io is used by the
[Heroku Node.js buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
to resolve `engines.node` in package.json files.

## Examples

Node.js versions are resolved from [nodejs.org/dist](http://nodejs.org/dist).
Give it a range and you'll get back a node version that satisfies.

- [node](https://semver.io/node)
- [node/0.10.x](https://semver.io/node/0.10.x)
- [node/~0.10.15](https://semver.io/node/~0.10.15)
- [node/0.11.x](https://semver.io/node/0.11.x)
- [node/>0.4](https://semver.io/node/>0.4)
- [node/>=0.11.5](https://semver.io/node/>=0.11.5)
- [node/*](https://semver.io/node/*)
- [node/junk-string](https://semver.io/node/junk-string)

## Caching

semver.io is designed to work even if nodejs.org is down. If the GET request to
[nodejs.org/dist/](http://nodejs.org/dist/) takes too long to resolve, this repo's
`cache/node.html` file will be loaded instead. To update the cached file, run:

```
npm run updateCache
```

## Overriding the Default Stable Version

Occasionaly new versions of node are released that world just isn't ready for.
This could be a predictiable change like a bump in minor version from `0.8.25` to `0.10.0`,
or an [unexpectedly unstable release like `0.10.19`](https://github.com/joyent/node/issues/6263).
To override the stable default version, use a config var:

```
heroku sudo config:set DEFAULT_VERSION_OVERRIDE=0.10.18 -a semver
```

When the dust settles, remove the override:

```
heroku sudo config:unset DEFAULT_VERSION_OVERRIDE -a semver
```

## What about npm versions?

npm versions are not tracked because the node binary has shipped with npm
included since node` 0.6.3`. The [buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
ignores `engines.npm`, deferring to node for npm version resolution.

## Tests

```
npm test

Resolver
  initialization
    ✓ has an array of all versions
    ✓ has an array of stable versions
    ✓ has a latest_stable version
    ✓ has a latest_unstable version
    ✓ defaults to latest stable version when given crazy input
  satisfy()
    ✓ honors explicit version strings
    ✓ matches common patterns to stable version
    ✓ uses latest unstable version when request version is beyond stable version
  override
    ✓ becomes latest_stable
    ✓ satisfies stable-seeking ranges
    ✓ still resolves unstable ranges
```