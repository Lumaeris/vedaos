#!/usr/bin/env bash
# combined installnvidiakmod.sh and installnvidiapackages.sh from secureblue, some packages are also added from ublue script
# Copyright 2025 Universal Blue
# Copyright 2025 The Secureblue Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

# Tell this script to exit if there are any errors.
set -oue pipefail

# create /var/tmp dir for akmod build
mkdir -p /var/tmp
chmod 1777 /var/tmp

# Always try to disable cisco repo (or add similar check)
dnf5 config-manager setopt fedora-cisco-openh264.enabled=0

# Install MULTILIB packages from negativo17-multimedia prior to disabling repo
dnf5 install -y mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libGL.i686 mesa-libgbm.i686 mesa-va-drivers.i686 mesa-vulkan-drivers.i686

# Disable Multimedia
dnf5 config-manager setopt fedora-multimedia.enabled=0

KERNEL_VERSION="$(rpm -q "kernel-cachyos" --queryformat '%{VERSION}-cachyos1.fc43.%{ARCH}')"

# download and enable fedora-nvidia repo
curl -Lo /etc/yum.repos.d/negativo17-fedora-nvidia.repo https://negativo17.org/repos/fedora-nvidia.repo
sed -i '/^enabled=1/a\priority=90' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

dnf5 install -y "akmod-nvidia"

echo "Setting kernel.conf to kernel-open"
sed -i --sandbox "s/^MODULE_VARIANT=.*/MODULE_VARIANT=kernel-open/" /etc/nvidia/kernel.conf

echo "Installing kmod..."
akmods --force --kernels "${KERNEL_VERSION}" --kmod "nvidia"

# Depends on word splitting
# shellcheck disable=SC2086
modinfo /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz > /dev/null || \
    (cat "/var/cache/akmods/nvidia/*.failed.log" && exit 1)

# View license information
# Depends on word splitting
# shellcheck disable=SC2086
modinfo -l /usr/lib/modules/${KERNEL_VERSION}/extra/nvidia/nvidia{,-drm,-modeset,-peermem,-uvm}.ko.xz

#curl -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
#    -o /etc/yum.repos.d/nvidia-container-toolkit.repo
#sed -i 's/^gpgcheck=0/gpgcheck=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo
#sed -i 's/^enabled=0.*/enabled=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo

# nvidia-container-toolkit was removed for now. according to ublue, it wasn't built with required crypto digests for RPM 6+ introduced in f43
dnf5 -y install nvidia-driver-cuda libnvidia-fbc libva-nvidia-driver nvidia-driver nvidia-modprobe nvidia-persistenced nvidia-settings

kmod_version=$(rpm -qa | grep akmod-nvidia | awk -F':' '{print $(NF)}' | awk -F'-' '{print $(NF-1)}')
negativo_version=$(rpm -qa | grep nvidia-modprobe | awk -F':' '{print $(NF)}' | awk -F'-' '{print $(NF-1)}')

echo "kmod_version: ${kmod_version}"
echo "negativo_version: ${negativo_version}"
if [[ "$kmod_version" != "$negativo_version" ]]; then
    echo "Version mismatch!"
    exit 1
fi

curl -L https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp \
    -o nvidia-container.pp
semodule -i nvidia-container.pp

rm -f nvidia-container.pp
rm -f /etc/yum.repos.d/negativo17-fedora-nvidia.repo
#rm -f /etc/yum.repos.d/nvidia-container-toolkit.repo

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Enable Multimedia back
dnf5 config-manager setopt fedora-multimedia.enabled=1
