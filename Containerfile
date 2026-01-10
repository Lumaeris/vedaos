FROM scratch AS ctx

COPY files/scripts /scripts
COPY files/system /files
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/bin/luks* /files/usr/bin
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/lib/dracut/fido* /files/usr/lib/dracut
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/lib/udev /files/usr/lib/udev
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/shared/usr/lib/modprobe.d/amd* /files/usr/lib/modprobe.d
COPY --from=ghcr.io/projectbluefin/common:latest /system_files/bluefin/usr/lib/systemd/user/bazaar.service /files/usr/lib/systemd/user/bazaar.service
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /files
COPY cosign.pub /files/usr/lib/pki/containers/vedaos.pub

FROM quay.io/fedora/fedora-bootc:43

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=ctx,source=/,dst=/ctx \
    /ctx/scripts/build.sh

RUN rm -rf /var/* && \
    rm -rf /tmp/* && \
    rm -rf /usr/etc && \
    rm -rf /boot && mkdir /boot && \
    mkdir /var/tmp && \
    chmod -R 1777 /var/tmp && \
    bootc container lint
