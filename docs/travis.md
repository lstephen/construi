---
layout: default
---

# Travis CI Integration

Construi can be used as a build tool for your
[Travis CI](https://travis-ci.org/) builds.
An example minimal .travis.yml:

```yaml
sudo: required

language: generic

services:
- docker

before_install:
- pip install --user construi

script:
- construi build
```

Construi itself uses Travis CI to build and deploy, so you can always check
out its [.travis.yml](https://github.com/lstephen/construi/blob/master/.travis.yml)
as well.
