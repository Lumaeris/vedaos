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
# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 05-rpmostree.install 50-dracut.install
popd

dnf -yq install "${stock_kernel_pkgs[@]}"

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

imageref="$(podman images --format '{{ index .Names 0 }}\n' 'vedaos*' | head -1)"
imageref="${imageref##*://}"
imageref="${imageref%%:*}"

dnf clean all -yq
