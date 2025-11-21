#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

# Remove Fedora kernel & remove leftover files
dnf5 -y remove kernel* && rm -r -f /usr/lib/modules/*

# exclude pulling kernel from fedora repos
dnf5 -y config-manager setopt "*fedora*".exclude="kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel kernel-headers"

# enable kernel blu and ublue akmods copr repos
dnf5 -y copr enable sentry/kernel-blu
dnf5 -y copr enable ublue-os/akmods

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

# install kernel and akmods
dnf5 -y install --allowerasing kernel kernel-modules-extra kernel-devel akmods
dnf5 -y install --setopt=install_weak_deps=False v4l2loopback

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

KERNEL_VERSION="$(ls /lib/modules)"
akmods --force --kernels "${KERNEL_VERSION}" --kmod "v4l2loopback"

# enable cachyos kernel addons copr repo
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

# install scx-scheds
dnf5 -y install scx-scheds

dnf5 -y copr disable sentry/kernel-blu
dnf5 -y copr disable ublue-os/akmods
dnf5 -y copr disable bieszczaders/kernel-cachyos-addons
