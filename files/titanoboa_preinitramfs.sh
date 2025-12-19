#!/usr/bin/env bash
set -exo pipefail

sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"VedaOS\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"VedaOS 43\"|
s|^ID=.*|ID=\"vedaos\"|
s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=\"vedaos\"|
EOF
