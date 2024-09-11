#!/usr/bin/env bash
set -euo pipefail

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
VORPAL_PATH="/var/lib/vorpal"
SANDBOX_HASH="$(cat "${PWD}/script/sandbox.sha256sum")"
SANDBOX_PACKAGE_PATH="${VORPAL_PATH}/store/vorpal-sandbox-${SANDBOX_HASH}.package"
SOURCE_HASH="$("${PWD}/script/hash_path.sh" "${PWD}")"

if [[ "${SOURCE_HASH}" != "${SANDBOX_HASH}" ]]; then
    echo "Hash mismatch: ${SOURCE_HASH} != ${SANDBOX_HASH}"
    exit 1
fi

echo "Building sandbox: ${SANDBOX_PACKAGE_PATH}"

if [[ -d "${SANDBOX_PACKAGE_PATH}" ]]; then
    echo "Sandbox exists: ${SANDBOX_PACKAGE_PATH}"
    exit 1
fi

directories=(
    "${VORPAL_PATH}"
    "${VORPAL_PATH}/sandbox"
    "${VORPAL_PATH}/store"
)

packages_darwin=(
    "bash"
    "coreutils"
    "zstd"
)
packages_linux=(
    "binutils"
    "gcc"
    "linux-headers"
    "glibc"
    "bash"
    "coreutils"
    "zstd"
    # "libstdc++"
)

for dir in "${directories[@]}"; do
    if [[ ! -d "${dir}" ]]; then
        sudo mkdir -p "${dir}"
        sudo chown -R "$(id -u):$(id -g)" "${dir}"
    fi
done

mkdir -p "${SANDBOX_PACKAGE_PATH}"

if [[ "${OS}" == "darwin" ]]; then
    for package in "${packages_darwin[@]}"; do
        "${PWD}/script/darwin/${package}.sh" "${SANDBOX_PACKAGE_PATH}"
    done
fi

if [[ "${OS}" == "linux" ]]; then
    for package in "${packages_linux[@]}"; do
        "${PWD}/script/linux/${package}.sh" "${SANDBOX_PACKAGE_PATH}"
    done
fi

# Patch for includes
mkdir -p "${SANDBOX_PACKAGE_PATH}/usr/include"
rsync -av --ignore-existing "${SANDBOX_PACKAGE_PATH}/include/" "${SANDBOX_PACKAGE_PATH}/usr/include"
rm -rf "${SANDBOX_PACKAGE_PATH}/include"

# Patch for linux only
if [[ "${OS}" == "linux" ]]; then
    # Patch for glibc
    ln -s "${SANDBOX_PACKAGE_PATH}/bin/gcc" "${SANDBOX_PACKAGE_PATH}/bin/cc"

    # Patch for nameservers
    echo "nameserver 1.1.1.1" > "${SANDBOX_PACKAGE_PATH}/etc/resolv.conf"

    # Copy /etc/ssl/certs to sandbox
    mkdir -p "${SANDBOX_PACKAGE_PATH}/etc/ssl/certs"
    rsync -av /etc/ssl/certs/ "${SANDBOX_PACKAGE_PATH}/etc/ssl/certs"
fi
