#!/bin/bash

set -e

echo "Generating Site..."

bundle exec jekyll build --source site --destination target/site

echo "Generating Reports..."

echo "Yard..."
bundle exec yard --output-dir target/site/yard

echo "Coverage..."
COVERAGE=true bundle exec rake spec

echo "Rubocop..."
bundle exec rubocop --format html -o target/site/rubocop.html || true

echo "Reports done."

if [[ -n "$SITE_DEPLOY" ]]
then
  [[ -n "$GIT_AUTHOR_NAME" ]] && git config user.name $GIT_AUTHOR_NAME
  [[ -n "$GIT_AUTHOR_EMAIL" ]] && git config user.email $GIT_AUTHOR_EMAIL

  printf "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

  echo "Deploying site to gh-pages..."
  ghp-import -p target/site
  echo "Deployment done."
fi

echo "Site done."

