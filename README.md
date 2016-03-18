Construi
========

Use docker to define your build environment.

## Installing

Install construi using pip:

```
  > pip install construi
```

## Usage

```
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

Construi allows specifying task dependencies using `before`. For example the following target
could be added to run all tests in the example above:

```
  test:
    before:
      - rspec
      - rspec-193
      - integration
```

