#!/usr/bin/env bash

dnf remove -y steam || true

systemctl disable tailscaled.service
systemctl disable bootloader-update.service
systemctl disable brew-setup.service
systemctl disable uupd.timer
systemctl disable rechunker-group-fix.service
systemctl disable input-remapper.service
systemctl --global disable bazaar.service

# Configure Anaconda

# Install Anaconda
SPECS=(
    "libblockdev-btrfs"
    "libblockdev-lvm"
    "libblockdev-dm"
    "anaconda-live"
    "anaconda-webui"
    "firefox"
    "rsync"
)
dnf install -y "${SPECS[@]}"

mkdir -p /var/lib/rpm-state

# Anaconda Profile Detection
tee /etc/anaconda/profile.d/vedaos.conf <<'EOF'
# Anaconda configuration file for VedaOS

[Profile]
# Define the profile.
profile_id = vedaos

[Profile Detection]
# Match os-release values
os_id = vedaos

[Network]
default_on_boot = FIRST_WIRED_WITH_LINK

[Bootloader]
efi_dir = fedora
menu_auto_hide = True

[Storage]
default_scheme = BTRFS
btrfs_compression = zstd:1
default_partitioning =
    /     (min 1 GiB, max 70 GiB)
    /home (min 500 MiB, free 50 GiB)
    /var  (btrfs)

[User Interface]
hidden_spokes =
    NetworkSpoke
    PasswordSpoke

hidden_webui_pages =
    root-password
    network

[Localization]
use_geolocation = False
EOF

cat >/usr/share/glib-2.0/schemas/zz2-org.gnome.shell.gschema.override <<EOF
[org.gnome.shell]
welcome-dialog-last-shown-version='4294967295'
favorite-apps=['anaconda.desktop', 'org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop']
EOF

# Disable suspend/sleep during live environment and initial setup
# This prevents the system from suspending during installation or first-boot user creation
tee /usr/share/glib-2.0/schemas/zz3-bluefin-installer-power.gschema.override <<EOF
[org.gnome.settings-daemon.plugins.power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
sleep-inactive-ac-timeout=0
sleep-inactive-battery-timeout=0

[org.gnome.desktop.session]
idle-delay=uint32 0
EOF

glib-compile-schemas /usr/share/glib-2.0/schemas

# Configure
. /etc/os-release
echo "VedaOS release $VERSION_ID" >/etc/system-release

sed -i 's/ANACONDA_PRODUCTVERSION=.*/ANACONDA_PRODUCTVERSION=""/' /usr/{,s}bin/liveinst || true
sed -i 's|Activities|the dock|' /usr/share/anaconda/gnome/fedora-welcome || true

# Interactive Kickstart
tee -a /usr/share/anaconda/interactive-defaults.ks <<EOF
ostreecontainer --url=ghcr.io/lumaeris/vedaos:latest --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
EOF

# Signed Images
tee /usr/share/anaconda/post-scripts/install-configure-upgrade.ks <<EOF
%post --erroronfail
sed -i 's/container-image-reference=.*/container-image-reference=ostree-image-signed:docker:\/\/ghcr.io\/lumaeris\/vedaos:latest/' /ostree/deploy/default/deploy/*.origin
%end
EOF

# Install Flatpaks
tee /usr/share/anaconda/post-scripts/install-flatpaks.ks <<'EOF'
%post --erroronfail --nochroot
deployment="$(ostree rev-parse --repo=/mnt/sysimage/ostree/repo ostree/0/1/0)"
target="/mnt/sysimage/ostree/deploy/default/deploy/$deployment.0/var/lib/"
mkdir -p "$target"
rsync -aAXUHKP /var/lib/flatpak "$target"
%end
EOF
