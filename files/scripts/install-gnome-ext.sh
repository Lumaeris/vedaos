#!/usr/bin/env bash
# this script is largely based on legacy method of bluebuild's gnome-extensions module
# https://github.com/blue-build/modules/blob/main/modules/gnome-extensions/gnome-extensions.sh
# curl, unzip and of course gnome shell needs to be installed before running this script
# this script expects one ID of gnome extension to be parsed in order to install it

set -oue pipefail

EXTENSION="$@"

GNOME_VER=$(gnome-shell --version | sed 's/[^0-9]*\([0-9]*\).*/\1/')
echo "Gnome version: ${GNOME_VER}"

echo "Testing connection with https://extensions.gnome.org/..."
if ! curl -fLsS --retry 5 -o /dev/null --head "https://extensions.gnome.org/"; then
  echo "ERROR: Connection unsuccessful."
  echo "       This usually happens when https://extensions.gnome.org/ website is down."
  echo "       Please try again later (or disable the module temporarily)"
  exit 1
else
  echo "Connection successful, proceeding."
fi

URL="https://extensions.gnome.org/extension-data/${EXTENSION}.shell-extension.zip"
TMP_DIR="/tmp/${EXTENSION}"
ARCHIVE=$(basename "${URL}")
ARCHIVE_DIR="${TMP_DIR}/${ARCHIVE}"
VERSION=$(echo "${EXTENSION}" | grep -oP 'v\d+')
echo "Installing ${EXTENSION} Gnome extension with version ${VERSION}"
# Download archive
echo "Downloading ZIP archive ${URL}"
curl -fLsS --retry 5 --create-dirs "${URL}" -o "${ARCHIVE_DIR}"
echo "Downloaded ZIP archive ${URL}"
# Extract archive
echo "Extracting ZIP archive"
unzip "${ARCHIVE_DIR}" -d "${TMP_DIR}" > /dev/null
# Remove archive
echo "Removing archive"
rm "${ARCHIVE_DIR}"
# Read necessary info from metadata.json
echo "Reading necessary info from metadata.json"
EXTENSION_NAME=$(jq -r '.["name"]' < "${TMP_DIR}/metadata.json")
UUID=$(jq -r '.["uuid"]' < "${TMP_DIR}/metadata.json")
EXT_GNOME_VER=$(jq -r '.["shell-version"][]' < "${TMP_DIR}/metadata.json")
# If extension does not have the important key in metadata.json,
# inform the user & fail the build
if [[ "${UUID}" == "null" ]]; then
echo "ERROR: Extension '${EXTENSION_NAME}' doesn't have 'uuid' key inside metadata.json"
echo "You may inform the extension developer about this error, as he can fix it"
exit 1
fi
if [[ "${EXT_GNOME_VER}" == "null" ]]; then
echo "ERROR: Extension '${EXTENSION_NAME}' doesn't have 'shell-version' key inside metadata.json"
echo "You may inform the extension developer about this error, as he can fix it"
exit 1
fi      
# Compare if extension is compatible with current Gnome version
# If extension is not compatible, inform the user & fail the build
if ! [[ "${EXT_GNOME_VER}" =~ "${GNOME_VER}" ]]; then
echo "ERROR: Extension '${EXTENSION_NAME}' is not compatible with current Gnome v${GNOME_VER}!"
exit 1
fi  
# Install main extension files
echo "Installing main extension files"
install -d -m 0755 "/usr/share/gnome-shell/extensions/${UUID}/"
find "${TMP_DIR}" -mindepth 1 -maxdepth 1 ! -path "*locale*" ! -path "*schemas*" -exec cp -r {} "/usr/share/gnome-shell/extensions/${UUID}/" \;
find "/usr/share/gnome-shell/extensions/${UUID}" -type d -exec chmod 0755 {} +
find "/usr/share/gnome-shell/extensions/${UUID}" -type f -exec chmod 0644 {} +
# Install schema
if [[ -d "${TMP_DIR}/schemas" ]]; then
echo "Installing schema extension file"
# Workaround for extensions, which explicitly require compiled schema to be in extension UUID directory (rare scenario due to how extension is programmed in non-standard way)
# Error code example:
# GLib.FileError: Failed to open file “/usr/share/gnome-shell/extensions/flypie@schneegans.github.com/schemas/gschemas.compiled”: open() failed: No such file or directory
# If any extension produces this error, it can be added in if statement below to solve the problem
# Fly-Pie or PaperWM
if [[ "${UUID}" == "flypie@schneegans.github.com" || "${UUID}" == "paperwm@paperwm.github.com" ]]; then
    install -d -m 0755 "/usr/share/gnome-shell/extensions/${UUID}/schemas/"
    install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/gnome-shell/extensions/${UUID}/schemas/"
    glib-compile-schemas "/usr/share/gnome-shell/extensions/${UUID}/schemas/" &>/dev/null
else
    # Regular schema installation
    install -d -m 0755 "/usr/share/glib-2.0/schemas/"
    install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/glib-2.0/schemas/"
fi  
fi  
# Install languages
# Locale is not crucial for extensions to work, as they will fallback to gschema.xml
# Some of them might not have any locale at the moment
# So that's why I made a check for directory
# I made an additional check if language files are available, in case if extension is packaged with an empty folder, like with Default Workspace extension
if [[ -d "${TMP_DIR}/locale/" ]]; then
    if find "${TMP_DIR}/locale/" -type f -name "*.mo" -print -quit | read; then
    echo "Installing language extension files"
    install -d -m 0755 "/usr/share/locale/"
    cp -r "${TMP_DIR}/locale"/* "/usr/share/locale/"
    fi  
fi  
# Delete the temporary directory
echo "Cleaning up the temporary directory"
rm -r "${TMP_DIR}"
echo "Extension '${EXTENSION_NAME}' is successfully installed"

# Compile gschema to include schemas from extensions  & to refresh schema state after uninstall is done
echo "Compiling gschema to include extension schemas & to refresh the schema state"
glib-compile-schemas "/usr/share/glib-2.0/schemas/" &>/dev/null
