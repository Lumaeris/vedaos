#!/usr/bin/env bash
# TODO: add missing kmods if needed

# Tell this script to exit if there are any errors.
set -oue pipefail

# Remove Fedora kernel & remove leftover files
dnf5 -y remove kernel* && rm -r -f /usr/lib/modules/*

# exclude pulling kernel from fedora repos
dnf5 -y config-manager setopt "*fedora*".exclude="kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra kernel-devel kernel-headers"

# enable kernel blu copr repo
dnf5 -y copr enable sentry/kernel-blu

# create a shims to bypass kernel install triggering dracut/rpm-ostree
# seems to be minimal impact, but allows progress on build
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x  05-rpmostree.install 50-dracut.install
popd

# install kernel
dnf5 -y install --allowerasing kernel kernel-modules-extra kernel-devel akmods

pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

dnf5 -y copr disable sentry/kernel-blu
