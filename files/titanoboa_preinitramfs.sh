#!/usr/bin/env bash
set -exo pipefail

# Swap kernel with vanilla and rebuild initramfs.
cachy_kernel_pkgs=(
    kernel-cachyos
    kernel-cachyos-core
    kernel-cachyos-modules
    kernel-cachyos-devel-matched
)
stock_kernel_pkgs=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
)
rpm --erase -v --nodeps "${cachy_kernel_pkgs[@]}"
rm -rf /usr/lib/modules/*
dnf -yq install "${stock_kernel_pkgs[@]}"

imageref="$(podman images --format '{{ index .Names 0 }}\n' 'vedaos*' | head -1)"
imageref="${imageref##*://}"
imageref="${imageref%%:*}"

dnf clean all -yq
