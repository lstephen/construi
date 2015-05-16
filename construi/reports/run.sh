#!/bin/bash


echo "Generating Reports..."

echo "Yard..."
bundle exec yard --output-dir target/site/yard

echo "Coverage..."
COVERAGE=true bundle exec rake spec

echo "Rubocop..."
bundle exec rubocop --format html -o target/site/rubocop.html || true

echo "Reports done."

