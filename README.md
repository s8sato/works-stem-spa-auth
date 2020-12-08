# works-stem-auth_spa

[demo]: https://user-images.githubusercontent.com/49983831/95659183-2c1d1e00-0b5a-11eb-951e-f23cde2e57c4.gif
[docker]: https://docs.docker.com/get-docker/
[how to email]: https://github.com/satu-n/study-actix-web-simple-auth-server#using-sparkpost-to-send-registration-email

## What's this

* Baby of SPA with user authentication &#x1F476;
* 1 command to get ready for dev
* Hot reload both client/server side
* Prefix `stem` derives from `stem cell`, which has potential to be any organ

### Demo

![demo][demo]

### Feature

* Elm & Rust: extremely fast, accurate, safe development and production
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
```
APP_NAME='my_auth_spa' &&
git clone https://github.com/satu-n/works-stem-auth_spa.git $APP_NAME &&
cd $APP_NAME &&
bash init.sh $APP_NAME \
'new!database!password******' \
'SparkPost-API-KEY&==' \
'sending.email.address@my.domain.com' &&
unset APP_NAME &&
docker-compose up
```
Configure '`quoted params`'.
[My actix-web learning log][how to email] may help you.

## Tips

To tag each labeled build stage for each image, run the command as follows:
```
REF='project_service:tag' \
docker images -f label=ref=$REF -q \
| xargs -I {} docker tag {} $REF
```