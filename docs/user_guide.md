---
layout: default
---

# User Guide

This guide aims to provide a reference for what Construi is capable of.

Construi is configured by a `construi.yml` file placed in the top level folder of your project.
One or more targets are defined, providing one or more commands and a Docker environment to
execute them in.

You can obtain a list of targets configured with:
```bash
$ construi -T
```

You can run a target with:
```bash
$ construi <target_name>
```

For example, if you've defined a target named "compile", you would run:
```bash
$ construi compile
```

Targets are configured under a top level `targets` key.
See examples of this throughout the guide.

Construi is heavily based on [Docker Compose](https://docs.docker.com/compose/) and makes
use of it internally.
As such, some knowledge of Docker Compose is advantageous.
This means you can think of each Construi target as being a docker compose configuration plus
commands to run.
As such, anything that is supported by and possible in Docker Compose should be possible in Construi

## Commands

Commands are configured as a list under the key `run`.
As a shortcut, if there is one command it is not necessary for the commands
to be a yaml list, but instead can just be the single command.
If there is no custom configuration for a target, the `run` key is not necessary
and the command to run can simply be provided as the value for the target.

The below targets are all identical:

```yaml
image: debian:jessie

targets:
  a_list:
    run:
    - echo "Hello World"

  no_list:
    run: echo "Hello World"

  no_run: echo "Hello World"
```

## Image or Build

Each target, as a minimum, requires a Docker image or build to run commans in.
If an image or build is configured at the top level of `construi.yml` it is used for all targets,
unless overridden.

In the below example the `in_debian` target has no image configured, so will use the image
that is configured at the top level.
The `in_ubuntu` image will use the image explicitly configured for that target.

```yaml
image: debian:jessie

targets:
  in_debian:
    run: echo "Hello World"

  in_ubuntu:
    image: ubuntu:xenial
    run: echo "Hello World"
```

To use a Dockerfile you can configure a `build` key, either on the target itself or at the
top level.
The `build` key uses the same setup as if it were specified in a Docker Compose file.

```yaml
build:
  dockerfile: Dockerfile
  context: .construi

targets:
  hello-world: echo "Hello World"
```

The above example will use the `Dockerfile` at `.construi/Dockerfile` to build an image.
It will then run commands in that built image.

## Top Level Configuration

Not only image or build can be configured at the top level.
In fact, any keys specified at the top level will be merged with the target specific
configuration.

For example

```yaml
image: debian:jessie

environment:
  - BOTH_TARGETS=foo

targets:
  first: echo "I'm first"

  second:
    environment:
      - JUST_THIS_TARGET=bar
    echo "I'm second"
```

In this example the environment variable `BOTH_TARGETS` is available to
both of the targets configured.
`JUST_THIS_TARGET` will only be available in the `second` target.


## Shell

A target can specify a shell command to have the commands run in a shell.
This is useful when shell commands and environment substitutions are needed.

```
image: debian:jessie

targets:
  using-shell:
    environment:
      - TEXT=some text
    shell: /bin/bash -c
    run:
      - echo $TEXT
```

## CONSTRUI_ARGS

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

## Task dependencies

Construi allows specifying task dependencies using `before`. For example the following target
could be added to run all tests in the example above:

```
  test:
    before:
      - rspec
      - rspec-193
      - integration
```

