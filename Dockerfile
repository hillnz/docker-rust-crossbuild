FROM rust:1.61.0

ARG TARGETPLATFORM

RUN sed -i 's/http/https/g' /etc/apt/sources.list

COPY ./cargo-cross.sh ./

RUN ./cargo-cross.sh install

ONBUILD ARG BUILDPLATFORM
ONBUILD ARG TARGETPLATFORM
ONBUILD RUN ./cargo-cross.sh configure
