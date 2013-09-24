# Node Semver Service

Give me a semver range and I'll give you a node version that satisfies.

This service is consumed by the [Heroku Node.js buildpack](https://github.com/heroku/heroku-buildpack-nodejs).

# Examples

- https://node-semver-service.heroku.com/0.10.x
- https://node-semver-service.heroku.com/~0.10.x
- https://node-semver-service.heroku.com/0.11.x
- https://node-semver-service.heroku.com/>0.4
- https://node-semver-service.heroku.com/>=0.11.5
- https://node-semver-service.heroku.com/*
- https://node-semver-service.heroku.com/junk

# Tests

```
npm test

Resolver
  ✓ has an array of all versions
  ✓ has an array of stable versions
  ✓ has a latest_stable version
  ✓ has a latest_unstable version
  ✓ honors explicit version strings
  ✓ matches common patterns to stable version
  ✓ uses latest unstable version when request version is beyond stable version (51ms)
  ✓ defaults to latest stable version when given crazy input
```


