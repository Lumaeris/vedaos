#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

sed -Ei 's/secure_path = (.*)/secure_path = \1:\/home\/linuxbrew\/.linuxbrew\/bin/' /etc/sudoers
