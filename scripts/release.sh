#!/usr/bin/env bash

set -e

function run {
  if [[ -z "$DRY_RUN" ]]
  then
    $@
  else
    echo "[dry-run] $@"
  fi
}

function setup_ssh {
  mkdir -p /root/.ssh

  if [[ -d "/ssh" ]]
  then
    cp /ssh/* /root/.ssh
    chmod -R 600 /root/.ssh
  fi

  printf "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
}

function publish {
  pip install twine

  twine_cmd="twine upload dist/*"

  run $twine_cmd -u "$TWINE_USERNAME" -p "$TWINE_PASSWORD"
}

function tag {
  version=$(cat VERSION)
  git_tag="v$version"

  run git tag "$git_tag"
  run git push origin "$git_tag"
}

setup_ssh

echo "Publising..."
publish

echo "Tagging..."
tag

echo "Done."

