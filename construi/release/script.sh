#!/bin/bash

set -e

[[ -n $GIT_AUTHOR_NAME ]] && git config user.name $GIT_AUTHOR_NAME
[[ -n $GIT_AUTHOR_EMAIL ]] && git config user.email $GIT_AUTHOR_EMAIL

printf "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

git config push.default simple
git checkout master
git pull --rebase
git merge --commit ${GIT_COMMIT}
git push origin
git checkout develop
git pull --rebase
bundle install --path vendor/bundle
bundle exec gem bump --version minor
git push origin

