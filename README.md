# works-stem-auth_spa

[demo]: https://user-images.githubusercontent.com/49983831/95659183-2c1d1e00-0b5a-11eb-951e-f23cde2e57c4.gif
[docker]: https://docs.docker.com/get-docker/
[how to email]: https://github.com/satu-n/study-actix-web-simple-auth-server#using-sparkpost-to-send-registration-email
[tips]: https://github.com/satu-n/tips

## What's this

* Baby of SPA with user authentication &#x1F476;
* 1 command to get ready for dev
* Hot reload (HMR) both client/server side
* Prefix `stem` derives from `stem cell`, which has potential to be any organ

### Demo

![demo][demo]

### Feature

* Elm & Rust: fast, accurate, safe development and production
* Docker container dev: portability & reproducibility
* Email invitation and identification
* Cookie authentication
* No navigation: single URL & no browser back/forward

## How to run

Prerequisites:

* [Docker & Docker Compose][docker]
* git
* bash

Enter the command as follows to access http://localhost:8080

```bash
APP_NAME='my_auth_spa' &&
git clone https://github.com/satu-n/works-stem-auth_spa.git $APP_NAME &&
cd $APP_NAME &&
bash init.sh $APP_NAME \
'new!database!password******' \
'SparkPost-API-KEY&==' \
'sending.email.address@my.domain.com' &&
unset APP_NAME &&
docker-compose up -d &&
rm -rf web/init &&
docker-compose logs -f
```

Configure '`quoted params`'.
[My actix-web learning log][how to email] may help you.

## Thank you for reading!

See also [my dev tips][tips] if you like
