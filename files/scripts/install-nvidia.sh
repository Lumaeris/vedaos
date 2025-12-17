#!/usr/bin/env bash
# combined installnvidiakmod.sh and installnvidiapackages.sh from secureblue, some packages are also added from ublue script

# Tell this script to exit if there are any errors.
set -oue pipefail

# create /var/tmp dir for akmod build
mkdir -p /var/tmp
chmod 1777 /var/tmp

# Install MULTILIB packages from negativo17-multimedia prior to disabling repo
dnf5 install -y mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libGL.i686 mesa-libgbm.i686 mesa-va-drivers.i686 mesa-vulkan-drivers.i686

# Disable Multimedia
dnf5 config-manager setopt fedora-multimedia.enabled=0

KERNEL_VERSION="$(ls /lib/modules)"

# download and enable fedora-nvidia repo
curl --retry 3 -Lo /etc/yum.repos.d/negativo17-fedora-nvidia.repo https://negativo17.org/repos/fedora-nvidia.repo
sed -i '/^enabled=1/a\priority=90' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

#dnf5 install -y akmod-nvidia gcc-c++

# pin to 580 version since 590 is in beta apparently. remove it when fixed upstream
# thanks secureblue for bringing this up
PINNED_OPEN_VERSION="580.105.08"
dnf5 install -y akmods
cp /usr/sbin/akmodsbuild /usr/sbin/akmodsbuild.backup
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild
dnf5 install -y "nvidia-kmod-common-${PINNED_OPEN_VERSION}" "akmod-nvidia-${PINNED_OPEN_VERSION}" "nvidia-modprobe-${PINNED_OPEN_VERSION}"
mv /usr/sbin/akmodsbuild.backup /usr/sbin/akmodsbuild
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

curl --retry 3 -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo -o /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's/^gpgcheck=0/gpgcheck=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo
sed -i 's/^enabled=0.*/enabled=1/' /etc/yum.repos.d/nvidia-container-toolkit.repo

echo "Installing NVIDIA packages..."
#dnf5 -y install nvidia-container-toolkit nvidia-driver-cuda libnvidia-fbc libva-nvidia-driver nvidia-driver nvidia-modprobe nvidia-persistenced nvidia-settings
dnf5 -y install nvidia-container-toolkit "nvidia-driver-cuda-${PINNED_OPEN_VERSION}" "libnvidia-fbc-${PINNED_OPEN_VERSION}" libva-nvidia-driver "nvidia-driver-${PINNED_OPEN_VERSION}" "nvidia-modprobe-${PINNED_OPEN_VERSION}" "nvidia-persistenced-${PINNED_OPEN_VERSION}" "nvidia-settings-${PINNED_OPEN_VERSION}"

curl --retry 3 -L https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp -o nvidia-container.pp
semodule -i nvidia-container.pp

rm -f nvidia-container.pp
rm -f /etc/yum.repos.d/negativo17-fedora-nvidia.repo
rm -f /etc/yum.repos.d/nvidia-container-toolkit.repo

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Enable Multimedia back
dnf5 config-manager setopt fedora-multimedia.enabled=1
