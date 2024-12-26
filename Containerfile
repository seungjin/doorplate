FROM debian:stable AS BUILDER
ARG WASMTIME_VER=28.0.0
WORKDIR /work

RUN apt update --yes && apt install --yes curl xz-utils
RUN curl -sL -o wasmtime.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v$WASMTIME_VER/wasmtime-v$WASMTIME_VER-x86_64-linux.tar.xz \
    && tar -xvf wasmtime.tar.xz \
    && cp wasmtime-v$WASMTIME_VER-x86_64-linux/wasmtime . \
    && rm -fr wasmtime.tar.xz \
    && rm -fr wasmtime-v$WASMTIME_VER-x86_64-linux 

FROM debian:stable-slim
ARG APP_NAME=doorplate
WORKDIR /app

COPY --from=BUILDER /work/wasmtime /usr/bin/wasmtime
COPY target/wasm32-wasip2/release/$APP_NAME.wasm /app/

CMD ["wasmtime", "serve", "-S", "cli", "./$APP_NAME.wasm"]

