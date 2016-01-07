#!/usr/bin/env bash

set -e

pip install twine
twine upload dist/* -u "$TWINE_USERNAME" -p "$TWINE_PASSWORD"
