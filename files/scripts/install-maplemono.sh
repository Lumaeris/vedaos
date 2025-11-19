#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
set -oue pipefail

pushd . > /dev/null
dir="$(mktemp -d)"
cd "${dir}"
curl --retry 3 -Lo ./MapleMono.zip https://github.com/subframe7536/maple-font/releases/latest/download/MapleMono-NF-CN-unhinted.zip
mkdir -p /usr/share/fonts/maple-mono-nf-cn
unzip MapleMono.zip
cp MapleMono-* LICENSE.txt /usr/share/fonts/maple-mono-nf-cn
popd > /dev/null
rm -rf "${dir}"
