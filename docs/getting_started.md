---
layout: default
---

# Getting Started

This page describes how to get up and running with Construi.
By following this page you will be able to install Construi and run a simple target.

## Installing

Construi requires that you have the following installed:

* [Docker](https://www.docker.com/)
* [Python](https://www.python.org/)

Construi is then installed using pip:

```bash
$ pip install construi
```

## Configuring

Construi is configured for your project via a `construi.yml` file in the project root.
The simplest `construi.yml` file specifies an image and a single target with a single command to be run.

```yaml
image: debian:jessie

targets:
  hello-world:
    run: echo "Hello World"
```

## Running

To run a target we pass it to construi on the command line.
In the same folder as the above `construi.yml` file:

```bash
$ construi hello-world
```

This will result in construi fetching the `debian:jessie` docker image
and executing `echo "Hello World"` inside it.
You will see the execution progress and the result echoed in the output.

