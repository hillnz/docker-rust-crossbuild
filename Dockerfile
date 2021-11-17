FROM rust:1.56.1

ARG TARGETPLATFORM

RUN sed -i 's/http/https/g' /etc/apt/sources.list

COPY ./cargo-cross.sh ./

RUN ./cargo-cross.sh install

ONBUILD RUN ./cargo-cross.sh configure
