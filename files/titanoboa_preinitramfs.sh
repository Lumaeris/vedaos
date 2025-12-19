#!/usr/bin/env bash
set -exo pipefail

# Swap kernel with vanilla and rebuild initramfs.
kernel_pkgs=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
)
rpm --erase -v --nodeps "${kernel_pkgs[@]}"
dnf -yq install "${kernel_pkgs[@]}"

imageref="$(podman images --format '{{ index .Names 0 }}\n' 'vedaos*' | head -1)"
imageref="${imageref##*://}"
imageref="${imageref%%:*}"

# Include nvidia-gpu-firmware package.
dnf install -yq nvidia-gpu-firmware || :
dnf clean all -yq
