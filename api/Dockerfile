FROM rust:1.48 AS dev
ARG app_name
LABEL ref="${app_name}_api:dev"
WORKDIR /usr/local/src
# build dependencies
COPY Cargo.toml .
RUN echo "fn main() {}" > dummy.rs
RUN sed -i 's#src/main.rs#dummy.rs#' Cargo.toml
RUN cargo build
RUN sed -i 's#dummy.rs#src/main.rs#' Cargo.toml
RUN rm dummy.rs
# utilities
RUN cargo install diesel_cli --no-default-features --features postgres
RUN cargo install cargo-watch
COPY . .
CMD diesel migration run && cargo watch -x run

# FOR PRODUCTION:

# FROM rust:1.48 AS build
# ARG app_name
# LABEL ref="${app_name}_api:build"
# WORKDIR /usr/local/src
# COPY . .
# RUN cargo build --release
# # TODO migration

# FROM gcr.io/distroless/cc
# COPY --from=build /usr/local/src/target/release/api /usr/local/bin/api
# CMD ["api"]
# # FIXME api: error while loading shared libraries: libpq.so.5: cannot open shared object file: No such file or directory
