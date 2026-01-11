#!/usr/bin/env bash
# https://github.com/somepaulo/MoreWaita/blob/main/install.sh

# Tell this script to exit if there are any errors.
set -oue pipefail

dir="$(mktemp -d)"
pushd "${dir}" > /dev/null
git clone https://github.com/somepaulo/MoreWaita --depth=1
mkdir -p /usr/share/icons/MoreWaita
shopt -s extglob
cp -au MoreWaita/!(*.build|*.sh|*.py|*.md|.git|.github|.gitignore|_dev) /usr/share/icons/MoreWaita
shopt -u extglob
find /usr/share/icons/MoreWaita -name '*.build' -type f -delete
popd > /dev/null
rm -rf "${dir}"
