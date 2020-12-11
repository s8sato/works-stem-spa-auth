FROM node:15-alpine AS base
ARG app_name
LABEL ref="${app_name}_web:base"
RUN npm install create-elm-app -g

FROM base AS dev
ARG app_name
LABEL ref="${app_name}_web:dev"
WORKDIR /usr/local/src
COPY . .
ARG uid
ARG gid
USER ${uid}:${gid}
CMD if [ -f "___create-elm-app___" ]; then \
      create-elm-app cea; \
      cp -r _init/* cea; \
      rm ___create-elm-app___; \
      sed -i 's/USER ${uid}:${gid}/#/' Dockerfile; \
    else \
      cd cea; \
      elm-app start; \
    fi

# FOR PRODUCTION:

# FROM base AS build
# ARG app_name
# LABEL ref="${app_name}_web:build"
# WORKDIR /usr/local/src
# COPY . .
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
