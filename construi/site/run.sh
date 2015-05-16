#!/bin/bash

set -e

bundle exec jekyll build --source site --destination target/site

if [[ -n "$GIT_SSH_KEY" ]]
then
  [[ -n "$GIT_AUTHOR_NAME" ]] && git config user.name $GIT_AUTHOR_NAME
  [[ -n "$GIT_AUTHOR_EMAIL" ]] && git config user.email $GIT_AUTHOR_EMAIL

  printf "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

  echo "Exporting to gh-pages"
  ghp-import target/site
fi

