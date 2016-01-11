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
  version=$(grep __version__ construi/__version__.py | cut -d "'" -f2)
  git_tag="v$version"

  run "git tag $git_tag && git push origin $git_tag"
}

setup_ssh
publish
tag

