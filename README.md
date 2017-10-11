Construi
========

[![Build Status](https://travis-ci.org/lstephen/construi.svg?branch=master)](https://travis-ci.org/lstephen/construi)

Use docker to define your build environment.

## Installing

Install construi using pip:

```bash
  > pip install construi
```

## Usage

```bash
  > construi [<target>]
```

Running construi with no arguments will run the default target.

## Configuration

Construi looks for the file `construi.yml` in the working directory.
`construi.yml` defines the targets and docker setup for each target.

For example:

```
image: ruby:2.2.3

default: rspec

targets:
  rspec:
    run:
      - bundle install --path=vendor/bundle
      - bundle exec rspec
```

The above example defines a target `rspec` that will be run within the `ruby:2.2.3` image.

Construi accepts any configuration allowed by docker compose.
It will combine configuration defined at the target level with that configured at the root
level.
It will then mount the working directory and run the configured commands.

For example:

```
image: ruby:2.2.3

default: test

environment:
  - APP_BASE_DIR=$PWD

targets:
  rspec:
    run:
      - bundle install --path=vendor/bundle
      - bundle exec rspec

  rspec-193:
    image: ruby:1.9.3
    run:
      - bundle install --path=vendor/bundle
      - bundle exec rspec

  integration:
    environment:
      - DB_HOST=mysql
      - DB_USERNAME=mysql_user
      - DB_PASSWORD
    run:
      - bundle install --path=vendor/bundle
      - bundle exec rspe spec/integration
    links:
      mysql:
        image: mysql
```

`APP_BASE_DIR` will be set in all targets, while the `DB_*` environment variables are only
visible in the `integration` target.

### Shell

A target can specify a shell command to have the commands run in a shell.
This is useful when shell commands and environment substitutions are needed.

```
image: python:2.7

targets:
  using-shell:
    environment:
      - TEXT=some text
    shell: /bin/bash -c
    run:
      - echo $TEXT
```

### CONSTRUI_ARGS

Any parameters given on the construi command line after the target are
available to be used by targets.
They are passed in as the environment variable `CONSTRUI_ARGS`.

```
image: ruby:2.2.3

targets:
  rails:
    environment:
      - CONSTRUI_ARGS
    shell: /bin/bash -c
    run: rails $CONSTRUI_ARGS
```

This allows running targets such as

```bash
> construi rails g model User
```

### Task dependencies

Construi allows specifying task dependencies using `before`. For example the following target
could be added to run all tests in the example above:

```
  test:
    before:
      - rspec
      - rspec-193
      - integration
```

## Travis CI

Construi can be used as a build tool for your
[Travis CI](https://travis-ci.org/) builds.
Minimal .travis.yml:

```
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
