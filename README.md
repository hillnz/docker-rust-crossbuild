# rust-crossbuild

A Rust image that includes cross-compilation toolchains, designed to work in conjunction with docker buildx. 

It's faster than buildx with the vanilla Rust image because it configures cargo for cross-compilation, so builds run natively without qemu.

## Usage

Prepare a Dockerfile, such as:
```
ARG BUILDPLATFORM
FROM --platform=$BUILDPLATFORM jonoh/rust-crossbuild AS builder
ARG TARGETPLATFORM
WORKDIR /usr/src/myapp
COPY . .
RUN cargo install --path .

FROM debian:buster-slim
RUN apt-get update && apt-get install -y extra-runtime-dependencies && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/cargo/bin/myapp /usr/local/bin/myapp
CMD ["myapp"]
```

It's important to include the `BUILDPLATFORM` and `TARGETPLATFORM` args, and the `--platform=$BUILDPLATFORM` in the `FROM`. These will ensure that the builder image is native to the system, while the output is native to the target system. The rest of the Dockerfile is up to you, the above is just an example.

Then use docker buildx for a cross-platform build. For example:
```
docker buildx build --platform linux/amd64,linux/arm64 -t myapp --push .
```

## Platforms

Build platforms
- linux/amd64
- linux/arm64

Target platforms
- linux/amd64
- linux/arm64
- linux/arm/v7

