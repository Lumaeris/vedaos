#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

dnf -y --setopt=install_weak_deps=False install gtksourceview4 python3-devel python3-pydantic python3-psutil python3-setuptools python3-pip
pip install evdev-binary

pushd . > /dev/null
dir="$(mktemp -d)"
cd "${dir}"
git clone --depth=1 https://github.com/sezanzeb/input-remapper.git
cd input-remapper
python3 setup.py install
popd > /dev/null
rm -rf "${dir}"
