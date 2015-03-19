#!/bin/bash

set -e

git config user.name lstephen
git config user.email levi.stephen@gmail.com
mkdir -p ~/.ssh
cp ${GIT_SSH_KEY} ~/.ssh/id_rsa
chmod 0600 ~/.ssh/id_rsa
printf "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
git config push.default simple
mkdir -p ~/.gem
printf -- \"---\\n:rubygems_api_key: ${RUBYGEMS_API_KEY}\" >> ~/.gem/credentials
chmod 0600 ~/.gem/credentials
bundle install --path vendor/bundle
bundle exec gem release --tag

