#!/usr/bin/env bash

set -e


targets=(
    # docker rust gcc
    "linux/arm64" "aarch64-unknown-linux-gnu" "aarch64-linux-gnu"
    "linux/arm/v7" "arm-unknown-linux-gnueabihf" "arm-linux-gnueabihf"
    "linux/amd64" "x86_64-unknown-linux-gnu" "x86-64-linux-gnu"
)


install_deps() {
    apt-get update
    for i in $(seq 0 3 $(( ${#targets[@]} - 1 )) ); do
        image_target="${targets[$i]}"
        rust_target="${targets[$i+1]}"
        gcc_target="${targets[$i+2]}"
        
        if [ "$image_target" = "$TARGETPLATFORM" ]; then
            # Native, no special tooling required
            continue
        fi

        rustup target add "$rust_target"
        apt-get install -y "gcc-$gcc_target"
    done
    rm -rf /var/lib/apt/lists/*
}


configure_cargo() {
    if [ "$BUILDPLATFORM" = "$TARGETPLATFORM" ]; then
        # Native
        return
    fi

    # Find target
    for i in $(seq 0 3 $(( ${#targets[@]} - 1 )) ); do
        image_target="${targets[$i]}"
        rust_target="${targets[$i+1]}"
        gcc_target="${targets[$i+2]}"
        
        if [ "$image_target" = "$TARGETPLATFORM" ]; then
            break
        fi
    done

    mkdir /.cargo
    cat > /.cargo/config.toml <<EOF
[build]
target = "${rust_target}"

[target.${rust_target}]
linker = ${gcc_target}-gcc"
EOF
}


case "$1" in
    install)
        install_deps
        ;;
    configure)
        configure_cargo
        ;;
    *)
        echo "Usage: $0 {install|configure}"
        exit 1
        ;;
esac
