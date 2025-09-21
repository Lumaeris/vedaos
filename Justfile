iso:
    @just iso-desktop

iso-desktop:
    #!/bin/sh
    bluebuild generate-iso -R podman --iso-name vedaos.iso image ghcr.io/lumaeris/vedaos

iso-hardened-amd:
    #!/bin/sh
    bluebuild generate-iso -R podman --secure-boot-url "https://github.com/secureblue/secureblue/raw/refs/heads/live/files/system/etc/pki/akmods/certs/akmods-secureblue.der" --enrollment-password "secureblue" --iso-name vedaos-hardened-amd.iso image ghcr.io/lumaeris/vedaos-hardened:amd

iso-server:
    #!/bin/sh
    sudo podman pull ghcr.io/lumaeris/vedaos-server:latest
    mkdir output
    sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v ./config_server.toml:/config.toml:ro -v ./output:/output -v /var/lib/containers/storage:/var/lib/containers/storage quay.io/centos-bootc/bootc-image-builder:latest --type anaconda-iso --use-librepo=True ghcr.io/lumaeris/vedaos-server:latest
