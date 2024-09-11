#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update

sudo apt-get install \
    --no-install-recommends \
    --yes \
    autoconf \
    automake \
    bison \
    build-essential \
    coreutils \
    flex \
    gawk \
    gperf \
    m4 \
    perl \
    texinfo \
    zstd
