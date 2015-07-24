---
layout: default
---

# Construi

Construi allows you to use [Docker](http://www.docker.com) containers as your build environment.
This allows a consistent and recreatable build environment on any machine running Construi
and Docker.

This is useful for ensuring consistency between development machines.
It is also useful in a CI environment where you may need to build projects from many different
languages and/or versions (e.g., Java 6, Java 8, Ruby).

## Installation

Construi requires [Ruby](http://www.ruby-lang.org) version 1.9 or higher.
It can be installed as a Gem.

```
  > gem install construi
```

## Running

Construi requires that a `construi.yml` file be present in the root directory of your project.
Targets can then be run by specifying them on the command line. For example:

```
  > construi build
  > construi build install
```

Construi will create a Docker container with the project directory as a volume.
It will then run the commands configured for the given targets.

## The Construi File

As a minimal `construi.yml` requires an image and a target to be configured.
For example a simple configuration for a Java 8 project built with Maven could be:

```
image: maven:3-jdk-8

targets:
  install: mvn install
```

Construi is built using itself, so it's
[`construi.yml`](https://github.com/lstephen/construi/blob/develop/construi.yml)
can be used as an example.

### Image

Specifies an image to be pulled that will be used as the build environment.
It can also be given on a per target basis.

```
image: maven:3-jdk-7

targets:
  install: mvn install

  test-java-8:
    image: maven:3-jdk-8
    run: mvn verify
```

### Build

Specifies a directory containing a `Dockerfile`.
Construi will build a Docker container based on that `Dockerfile` and use it as the build
environment.
Can be used as an alternative to providing an image.
Can also be given on a per target basis.

```
build: etc/build_environment

targets:
  build:
    - mvn install
    - /usr/local/bin/custom_installed_command.sh
```


### Privileged

An image can be marked as a privileged image.
This is equivalent to passing `--privileged` to the Docker command line.
Useful when requiring docker to be part of the build process.

```
build: lstephen/docker
privileged: true

targets:
  build: docker build latest/
```

### Environment

Declares environment variables that will be passed through or set in the build environment.
If no value is provided then the value from the host environment will be used.
In this example `NEXUS_SERVER_URL` will be set as provided, while `NEXUS_USERNAME` and
`NEXUS_PASSWORD` will be retrieved from the host.
Can be used on a per target basis.

```
image: maven:3-jdk-7

environment:
  - NEXUS_SERVER_URL=http://nexus.example.com
  - NEXUS_USERNAME
  - NEXUS_PASSWORD
targets:
  build: mvn install
```

### Files

Declares files to be copied into the build environment before the build is run.
Also allows setting of permissions.
Can be used on a per target basis.

```
image: maven:3-jdk-7

files:
  - etc/maven-settings.xml:/home/root/.m2/settings.xml

targets:
  deploy:
    files:
      - $GIT_SSH_KEY:/home/root/.ssh/id_rsa:0600
    run: scripts/construi/deploy.sh
```

### Links

Allows specifying containers that will be linked to the build container during the build
process.
This is useful, for example, in having a database running durings tests.
Linked containers allow setting of environment, files, and privileged as per the build
container.
Links can be specified on a global or per target level.

```
image: ruby:1.9

targets:
  integration-tests:
    environment:
      - MYSQL_HOST=mysql
    run:
      - bundle install --path=vendor/bundle
      - rake test:integration
    links:
      mysql:
        image: mysql:5.5
        environment:
          - MYSQL_ALLOW_EMPTY_PASSWORD=yes
```

### Targets

Any number of targets can be specified.
Each must specify at least one command.
If additional configuration is required for a target then the commands should be provided
under the `run` key.
If more than one command is required then a YAML list should be used.

```
image: maven:3-jdk-7

targets:
  build: mvn install

  test-java-8:
    image: maven:3-jdk-8
    run: mvn verify

  deploy:
    - mvn deploy
    - curl http://ci.example.com/deploy/trigger
```


