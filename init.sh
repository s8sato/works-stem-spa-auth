#!/bin/bash

# HOW TO USE
# bash init.sh \
# 'app_name' \
# 'new!database!password******' \
# 'SparkPost-API-KEY&==' \
# 'sending.email.address@my.domain.com'

readonly API_PROTOCOL="http"
readonly API_HOST="localhost"
readonly API_PORT="3000"

# if true, app serves no authentication by email, password, or cookie.
personal_use=false

if [ $# -ne 4 ]; then
  echo "$# arguments found." 1>&2
  echo "Specify exactly 4 arguments." 1>&2
  exit 1
fi

dest=".env"
: >$dest
echo "UID=$(id -u $USER)" >>$dest
echo "GID=$(id -g $USER)" >>$dest
echo "APP_NAME=$1" >>$dest
echo "DB_PASSWORD=$2" >>$dest

dest="api/.env"
: >$dest
echo "APP_NAME=$1" >>$dest
echo "DATABASE_URL=postgres://postgres:$2@db:5432/postgres" >>$dest
echo "SPARKPOST_API_KEY=$3" >>$dest
echo "SENDING_EMAIL_ADDRESS=$4" >>$dest
echo "API_PROTOCOL=$API_PROTOCOL" >>$dest
echo "API_HOST=$API_HOST" >>$dest
echo "API_PORT=$API_PORT" >>$dest

dest="web/src/Config.elm"
: >$dest
echo "module Config exposing (..)" >>$dest
echo "appName = \"$1\"" >>$dest
echo "epBase = \"${API_PROTOCOL}://${API_HOST}:${API_PORT}/api\"" >>$dest
