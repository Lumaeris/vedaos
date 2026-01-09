#!/usr/bin/env bash

set -xoue pipefail

# install fedora logos and dnf5-plugins that is needed for copr management and other actions
dnf5 -y install fedora-logos dnf5-plugins

# copying system files over to the system
cp -avf "/ctx/files"/. /

sed -Ei 's/secure_path = (.*)/secure_path = \1:\/home\/linuxbrew\/.linuxbrew\/bin/' /etc/sudoers
