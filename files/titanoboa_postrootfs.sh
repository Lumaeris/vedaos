#!/usr/bin/env bash

dnf remove -y gnome-software gnome-tour fedora-flathub-remote gnome-software-rpm-ostree totem-video-thumbnailer google-noto-sans-cjk-vf-fonts default-fonts-cjk-sans fedora-third-party || true
rm -f /usr/lib/systemd/system/flatpak-add-fedora-repos.service || true

CSFG=/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
curl -sSLo ${CSFG} https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x ${CSFG}

# Configure Anaconda

# Install Anaconda WebUI
SPECS=(
    "libblockdev-btrfs"
    "libblockdev-lvm"
    "libblockdev-dm"
    "anaconda-live"
    "anaconda-webui"
)
dnf install -y "${SPECS[@]}"

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
EOF

cat >/usr/share/glib-2.0/schemas/zz2-org.gnome.shell.gschema.override <<EOF
[org.gnome.shell]
welcome-dialog-last-shown-version='4294967295'
favorite-apps=['liveinst.desktop', 'org.mozilla.firefox.desktop', 'org.gnome.Nautilus.desktop']
enabled-extensions=['']

[org.gnome.desktop.wm.preferences]
button-layout='appmenu:minimize,maximize,close'

[org.gnome.desktop.interface]
color-scheme='prefer-dark'
accent-color='purple'

[org.gnome.mutter]
center-new-windows=true

[org.gnome.desktop.background]
picture-uri="file:///usr/share/backgrounds/gnome/symbolic-d.png"
picture-uri-dark="file:///usr/share/backgrounds/gnome/symbolic-d.png"
EOF

glib-compile-schemas /usr/share/glib-2.0/schemas

# Configure
. /etc/os-release
echo "VedaOS release $VERSION_ID" >/etc/system-release

sed -i 's/ANACONDA_PRODUCTVERSION=.*/ANACONDA_PRODUCTVERSION=""/' /usr/{,s}bin/liveinst || true

# Interactive Kickstart
tee -a /usr/share/anaconda/interactive-defaults.ks <<EOF
ostreecontainer --url=ghcr.io/lumaeris/vedaos:latest --transport=containers-storage --no-signature-verification
%include /usr/share/anaconda/post-scripts/install-configure-upgrade.ks
%include /usr/share/anaconda/post-scripts/install-flatpaks.ks
EOF

# Signed Images
tee /usr/share/anaconda/post-scripts/install-configure-upgrade.ks <<EOF
%post --erroronfail
bootc switch --mutate-in-place --enforce-container-sigpolicy --transport registry ghcr.io/lumaeris/vedaos:latest
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

rm -rf /usr/share/doc
rm -rf /usr/share/man
