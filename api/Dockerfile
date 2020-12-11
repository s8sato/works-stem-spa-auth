FROM rust:1.48 AS base
ARG app_name
LABEL ref="${app_name}_api:base"
RUN cargo install diesel_cli --no-default-features --features postgres
RUN cargo install cargo-watch

FROM base AS dev
ARG app_name
LABEL ref="${app_name}_api:dev"
WORKDIR /usr/local/src
ENV CARGO_TARGET_DIR=/tmp/target
# build dependencies
COPY Cargo.toml Cargo.lock ./
RUN echo 'fn main() {}' >dummy.rs
RUN sed -i 's#src/main.rs#dummy.rs#' Cargo.toml
RUN cargo build
RUN sed -i 's#dummy.rs#src/main.rs#' Cargo.toml
RUN rm dummy.rs
# build dependencies
COPY . .
RUN cargo build
# migrate if file "___migration___" exists
CMD if [ -f "___migration___" ]; then \
      diesel migration run; \
      rm ___migration___; \
    fi && \
    cargo watch -x run

# FOR PRODUCTION:

# FROM base AS build
# ARG app_name
# LABEL ref="${app_name}_api:build"
# WORKDIR /usr/local/src
# ENV CARGO_TARGET_DIR=/tmp/target
# COPY . .
# RUN cargo build --release
# # TODO migration

# FROM gcr.io/distroless/cc
# COPY --from=build /tmp/target/release/api /usr/local/bin/
# CMD ["api"]
# # FIXME api: error while loading shared libraries: libpq.so.5: cannot open shared object file: No such file or directory
