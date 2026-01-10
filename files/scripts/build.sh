#!/usr/bin/env bash

set -xoue pipefail

# install fedora logos and dnf5-plugins that is needed for copr management and other actions
dnf5 -y install fedora-logos dnf5-plugins

# enable required repos and disable them (would be enabled when necessary)
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr enable ublue-os/bazzite
dnf5 -y copr enable ublue-os/bazzite-multilib
dnf5 -y config-manager setopt '*bazzite*'.priority=90
dnf5 -y copr disable ublue-os/bazzite
dnf5 -y copr disable ublue-os/bazzite-multilib
dnf5 config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 config-manager setopt tailscale-stable.enabled=0

# copying system files over to the system
cp -avf "/ctx/files"/. /

# remove leftovers from fedora-bootc
dnf5 -y remove console-login-helper-messages chrony sssd* qemu-user-static* toolbox

# delete chsh since we don't need it, create roothome dir, add fedora-multimedia
rm -f /usr/bin/chsh
rm -f /usr/bin/lchsh
mkdir -p /var/roothome
dnf5 config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf5 config-manager setopt fedora-multimedia.priority=90
dnf5 config-manager setopt fedora-cisco-openh264.enabled=0

# install packages from fedora-multimedia and versionlock them
MULTIMEDIARPMS=(
    "intel-gmmlib"
    "intel-mediasdk"
    "intel-vpl-gpu-rt"
    "libheif"
    "libva"
    "libva-intel-media-driver"
    "mesa-dri-drivers"
    "mesa-filesystem"
    "mesa-libEGL"
    "mesa-libGL"
    "mesa-libgbm"
    "mesa-va-drivers"
    "mesa-vulkan-drivers"
)
dnf5 -y --setopt=skip_if_unavailable=False install "${MULTIMEDIARPMS[@]}" ocl-icd
dnf5 versionlock add "${MULTIMEDIARPMS[@]}"

# install so called "batteries" coined by ublue
dnf5 -y --enablerepo=copr:copr.fedorainfracloud.org:ublue-os:packages install \
    fedora-repos-archive \
    zstd \
    alsa-firmware \
    apr \
    apr-util \
    distrobox \
    fdk-aac \
    ffmpeg \
    ffmpeg-libs \
    ffmpegthumbnailer \
    flatpak-spawn \
    fuse \
    fzf \
    google-noto-sans-balinese-fonts \
    google-noto-sans-cjk-fonts \
    google-noto-sans-javanese-fonts \
    google-noto-sans-sundanese-fonts \
    grub2-tools-extra \
    heif-pixbuf-loader \
    htop \
    intel-vaapi-driver \
    just \
    libavcodec \
    libcamera \
    libcamera-gstreamer \
    libcamera-ipa \
    libheif \
    libcamera-tools \
    libfdk-aac \
    libimobiledevice-utils \
    libratbag-ratbagd \
    libva-utils \
    lshw \
    net-tools \
    nvme-cli \
    nvtop \
    openrgb-udev-rules \
    openssl \
    oversteer-udev \
    pam-u2f \
    pam_yubico \
    pamu2fcfg \
    pipewire-libs-extra \
    pipewire-plugin-libcamera \
    powerstat \
    smartmontools \
    solaar-udev \
    squashfs-tools \
    symlinks \
    tcpdump \
    tmux \
    traceroute \
    usbmuxd \
    vim \
    wireguard-tools \
    wl-clipboard \
    xhost \
    xorg-x11-xauth \
    yubikey-manager

# use CoreOS' generator for emergency/rescue boot, some workarounds
sed -Ei 's/secure_path = (.*)/secure_path = \1:\/home\/linuxbrew\/.linuxbrew\/bin/' /etc/sudoers
curl --retry 3 -sSLo /usr/lib/systemd/system-generators/coreos-sulogin-force-generator https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x /usr/lib/systemd/system-generators/coreos-sulogin-force-generator
mv '/usr/share/doc/just/README.中文.md' '/usr/share/doc/just/README.zh-cn.md'
ln -s '/usr/share/fonts/google-noto-sans-cjk-fonts' '/usr/share/fonts/noto-cjk'

# swap kernel and install nvidia drivers and kmod
/ctx/scripts/swap-kernel.sh
/ctx/scripts/install-nvidia.sh

# install gnome and a few useful things
dnf5 -y install -x gnome-tour --enablerepo=tailscale-stable --enablerepo=copr:copr.fedorainfracloud.org:ublue-os:packages \
    input-remapper \
    flatpak \
    tailscale \
    NetworkManager-adsl \
    gdm \
    gnome-bluetooth \
    gnome-color-manager \
    gnome-control-center \
    gnome-remote-desktop \
    gnome-session-wayland-session \
    gnome-settings-daemon \
    gnome-shell \
    gnome-user-docs \
    gvfs-fuse \
    gvfs-goa \
    gvfs-gphoto2 \
    gvfs-mtp \
    gvfs-smb \
    libsane-hpaio \
    nautilus \
    orca \
    ptyxis \
    sane-backends-drivers-scanners \
    xdg-desktop-portal-gnome \
    xdg-user-dirs-gtk \
    yelp-tools \
    plymouth \
    plymouth-system-theme \
    systemd-container \
    libcamera-v4l2 \
    NetworkManager-wifi \
    atheros-firmware \
    brcmfmac-firmware \
    iwlegacy-firmware \
    iwlwifi-dvm-firmware \
    iwlwifi-mvm-firmware \
    mt7xxx-firmware \
    nxpwireless-firmware \
    realtek-firmware \
    tiwilink-firmware \
    alsa-firmware \
    alsa-sof-firmware \
    alsa-tools-firmware \
    intel-audio-firmware \
    gnome-disk-utility \
    uupd \
    unzip \
    adw-gtk3-theme \
    glibc-all-langpacks \
    wget \
    jetbrains-mono-fonts-all \
    fuse-libs \
    squashfuse-libs \
    glycin-thumbnailer \
    fira-code-fonts \
    hyfetch \
    fastfetch \
    jmtpfs \
    NetworkManager-config-connectivity-fedora \
    NetworkManager-openvpn \
    NetworkManager-wwan \
    cups \
    fprintd \
    fprintd-pam \
    hplip \
    hyperv-daemons \
    ibus \
    libratbag-ratbagd \
    open-vm-tools \
    open-vm-tools-desktop \
    pcsc-lite \
    qemu-guest-agent \
    systemd-oomd-defaults \
    whois \
    wireguard-tools \
    zram-generator-defaults \
    thermald \
    gum

# install some backgrounds
dnf5 -y install --enablerepo=copr:copr.fedorainfracloud.org:ublue-os:bazzite f43-backgrounds-gnome gnome-backgrounds steamdeck-backgrounds

# install gnome extensions. this script is already compiling gschemas so I don't need to do it again
for extension in 19 517 615 3193 4222 4269 5105 7535 8084
do
    /ctx/scripts/install-gnome-ext.sh $extension
done

# install some dev tools
dnf5 -y install foundry git flatpak-builder

# install steam
dnf5 -y install --setopt=install_weak_deps=False steam

# give bazzite copr repos a priority, install gamescope
dnf5 -y install --enablerepo=copr:copr.fedorainfracloud.org:ublue-os:bazzite --enablerepo=copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib gamescope-libs gamescope-shaders
