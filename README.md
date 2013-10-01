# Node.js Semver Service

This is a plain-text webservice that tracks all available versions of node on
[nodejs.org/dist](http://nodejs.org/dist). Give it a [semver range](https://npmjs.org/doc/misc/semver.html#Ranges)
and you'll get back a node version that satisfies. This service is used by the
[Heroku Node.js buildpack](https://github.com/heroku/heroku-buildpack-nodejs)
to resolve the `engines.node` value in package.json files.

## Examples

- [0.10.x](https://node-semver-service.heroku.com/0.10.x)
- [~0.10.15](https://node-semver-service.heroku.com/~0.10.15)
- [0.11.x](https://node-semver-service.heroku.com/0.11.x)
- [>0.4](https://node-semver-service.heroku.com/>0.4)
- [>=0.11.5](https://node-semver-service.heroku.com/>=0.11.5)
- [*](https://node-semver-service.heroku.com/*)
- [junk-string](https://node-semver-service.heroku.com/junk-string)
- [_blank_](https://node-semver-service.heroku.com/)

## Caching

This service is designed to work even if nodejs.org is down. If the GET request to
[nodejs.org/dist/](http://nodejs.org/dist/) takes too long to resolve, this repo's
`cache.html` file will be loaded instead. To update the cached file, run:

```
npm run updateCache
```

## Overriding the Default Stable Version

Occasionaly new versions of node are released that world just isn't ready for.
This could be a predictiable change like a bump in minor version from `0.8.25` to `0.10.0`,
or an [unexpectedly unstable release like `0.10.19`](https://github.com/joyent/node/issues/6263).
To override the stable default version, use a config var:

```
heroku sudo config:set DEFAULT_VERSION_OVERRIDE=0.10.18 -a node-semver-service
```

When the dust settles, remove the override:

```
heroku sudo config:unset DEFAULT_VERSION_OVERRIDE -a node-semver-service
```

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