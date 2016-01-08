#!/usr/bin/env bash

set -e

version=$(git log --oneline --first-parent master | wc -l | xargs)

branch=$(git branch | grep '*')

if [[ ! $branch =~ master$ ]]
then
  branch_count=$[$(git log --oneline --first-parent | wc -l | xargs) - $version]
  version="$version.dev$branch_count"
fi

output=${1-/dev/stdout}

echo "__version__ = '$version'" > $output
