#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# find latest version of cosign
LATEST_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")

# download & install cosign
dnf5 install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-${LATEST_VERSION}-1.x86_64.rpm
