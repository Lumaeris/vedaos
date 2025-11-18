#!/usr/bin/env bash
# https://github.com/somepaulo/MoreWaita/blob/main/install.sh

# Tell this script to exit if there are any errors.
set -oue pipefail

pushd . > /dev/null
dir="$(mktemp -d)"
cd "${dir}"
git clone https://github.com/somepaulo/MoreWaita --depth=1
mkdir -p /usr/share/icons/MoreWaita
shopt -s extglob
cp -au MoreWaita/!(*.build|*.sh|*.py|*.md|.git|.github|.gitignore|_dev) /usr/share/icons/MoreWaita
shopt -u extglob
find /usr/share/icons/MoreWaita -name '*.build' -type f -delete
popd > /dev/null
rm -rf "${dir}"
