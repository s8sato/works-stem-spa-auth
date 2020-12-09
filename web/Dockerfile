FROM node:15-alpine AS base
ARG app_name
LABEL ref="${app_name}_web:base"
RUN npm install create-elm-app -g

FROM base AS dev
ARG app_name
LABEL ref="${app_name}_web:dev"
WORKDIR /usr/local/src
COPY . .
# The following project creation line is erased on the first run
CMD create-elm-app cea && sed -i 's# create-elm-app cea && # #' Dockerfile && \
    cp -r init/* cea && sed -i 's# cp -r init/* cea && # #' Dockerfile && \
    rm -rf init && sed -i 's# rm -rf init && # #' Dockerfile && \
    mv cea/* . && sed -i 's# mv cea/* . && # #' Dockerfile && \
    rm -rf cea && sed -i 's# rm -rf cea && # #' Dockerfile && \
    elm-app start

# FOR PRODUCTION:

# FROM base AS build
# ARG app_name
# LABEL ref="${app_name}_web:build"
# WORKDIR /usr/local/src/cea
# RUN elm-app build

# FROM nginx:alpine
# COPY --from=build /usr/local/src/build/ /usr/share/nginx/html/
# # TODO is it works?


# IF prefer bare elm to create-elm-app:

# FROM alpine AS elm
# LABEL ref="elm:alpine"
# RUN wget -O - https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz \
#     | gunzip -c >/usr/local/bin/elm
# RUN chmod +x /usr/local/bin/elm

# FROM elm AS build
# ARG app_name
# LABEL ref="${app_name}_web:build"
# WORKDIR /usr/local/src
# COPY . .
# RUN elm make src/Main.elm --optimize

# FROM nginx:alpine
# COPY --from=build /usr/local/src/index.html /usr/local/src/css /usr/share/nginx/html/
