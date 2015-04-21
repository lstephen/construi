#!/bin/bash

set -e

echo "name: $GIT_AUTHOR_NAME"
echo "email: $GIT_AUTHOR_EMAIL"

[[ -n "$GIT_AUTHOR_NAME" ]] && git config user.name $GIT_AUTHOR_NAME
[[ -n "$GIT_AUTHOR_EMAIL" ]] && git config user.email $GIT_AUTHOR_EMAIL

printf "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

mkdir -p ~/.gem
printf -- "---\\n:rubygems_api_key: ${RUBYGEMS_API_KEY}" >> ~/.gem/credentials
chmod 0600 ~/.gem/credentials

git branch -u $GIT_BRANCH

bundle install --path vendor/bundle
bundle exec gem release --tag

