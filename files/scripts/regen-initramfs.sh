#!/usr/bin/env bash
# based on https://github.com/secureblue/secureblue/blob/live/files/scripts/regenerateinitramfs.sh

# Tell this script to exit if there are any errors.
set -oue pipefail

# Set dracut log levels using temporary configuration file.
# This avoids logging messages to the system journal, which can significantly
# impact performance in the default configuration.
temp_conf_file=$(mktemp '/etc/dracut.conf.d/zzz-loglevels-XXXXXXXXXX.conf')
cat >"${temp_conf_file}" <<'EOF'
stdloglvl=4
sysloglvl=0
kmsgloglvl=0
fileloglvl=0
EOF

# Temporarily patch /etc/os-release to avoid the initramfs depending on the
# version number (which changes daily).
tmp_release_file=$(mktemp --tmpdir 'os-release-XXXXXXXXXX')
cp /etc/os-release "${tmp_release_file}"
sed -Ei -e '/^(OSTREE_)?VERSION=/d' /etc/os-release

qualified_kernel=$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)

/usr/bin/dracut \
    --kver "${qualified_kernel}" \
    --force \
    --add 'ostree' \
    --no-hostonly \
    --reproducible \
    "/usr/lib/modules/${qualified_kernel}/initramfs.img"

# Restore temporarily modified files
cp "${tmp_release_file}" /etc/os-release

rm "${tmp_release_file}" "${temp_conf_file}"

chmod 0600 "/usr/lib/modules/${qualified_kernel}/initramfs.img"

# assign a layer for it
setfattr -n user.component -v "initramfs" "/usr/lib/modules/${qualified_kernel}/initramfs.img"
