#!/bin/sh

set -e

bundle config set frozen false
bundle config set path '/usr/local/bundle'
bundle install

bundle exec rails db:create db:migrate

rm -f tmp/pids/server.pid

exec bundle exec "$@"
