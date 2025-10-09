#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

mv /usr/share/ublue-os/bazaar /etc
sed -i 's|/usr/share/ublue-os/|/run/host/etc/|g' /etc/bazaar/config.yaml
sed -i '/io\.github\.kolunmi\.Bazaar/d' /etc/bazaar/blocklist.txt
