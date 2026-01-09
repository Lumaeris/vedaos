FROM scratch AS ctx

COPY files/scripts /scripts
COPY files/system /files
COPY cosign.pub /files/usr/lib/pki/containers/vedaos.pub

FROM quay.io/fedora/fedora-bootc:43

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/ctx \
    /ctx/scripts/build.sh
