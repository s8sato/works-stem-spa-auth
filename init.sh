#!/bin/bash

# HOW TO USE
# bash init.sh \
# 'app_name' \
# 'new!database!password******' \
# 'SparkPost-API-KEY&==' \
# 'sending.email.address@my.domain.com'

readonly API_PROTOCOL="http"
readonly API_HOST="localhost"
readonly API_PORT="3030"

# if true, app serves no authentication by email, password, or cookie.
personal_use=false

if [ $# -ne 4 ]; then
  {
    echo "$# arguments found."
    echo "Specify exactly 4 arguments."
  } 1>&2
  exit 1
fi

dest=".env"
: >$dest
{
  echo "APP_NAME=$1"
  echo "DB_PASSWORD=$2"
} >>$dest

dest="api/.env"
: >$dest
{
  echo "APP_NAME=$1"
  echo "DATABASE_URL=postgres://postgres:$2@db:5432/postgres"
  echo "SPARKPOST_API_KEY=$3"
  echo "SENDING_EMAIL_ADDRESS=$4"
  echo "API_PROTOCOL=$API_PROTOCOL"
} >>$dest

dest="web/_init/src/Config.elm"
: >$dest
{
  echo "module Config exposing (..)"
  echo "appName = \"$1\""
  echo "epBase = \"${API_PROTOCOL}://${API_HOST}:${API_PORT}/api\""
} >>$dest
