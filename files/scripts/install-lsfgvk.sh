#!/usr/bin/env bash
# this script is somewhat based on https://github.com/askpng/solarpowered/blob/main/files/scripts/base/bazzite.sh

set -ouex pipefail

LSFG_TAG=$(curl --fail --retry 5 --retry-delay 5 --retry-all-errors -s https://api.github.com/repos/PancakeTAS/lsfg-vk/releases/latest | grep tag_name | cut -d : -f2 | tr -d 'v", ' | head -1)

echo 'Installing lsfg-vk.'
dnf5 install -y \
    https://github.com/PancakeTAS/lsfg-vk/releases/download/v$LSFG_TAG/lsfg-vk-$LSFG_TAG.x86_64.rpm
