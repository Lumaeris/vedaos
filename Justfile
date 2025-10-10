iso:
    @just iso-desktop

iso-desktop:
    #!/bin/sh
    bluebuild generate-iso -R podman --iso-name vedaos.iso image ghcr.io/lumaeris/vedaos

iso-desktop-lts:
    #!/bin/sh
    #bluebuild generate-iso -R podman --iso-name vedaos-lts.iso image ghcr.io/lumaeris/vedaos-lts

iso-server:
    #!/bin/sh
    sudo podman pull ghcr.io/lumaeris/vedaos-server:latest
    mkdir output
    sudo podman run --rm -it --privileged --pull=newer --security-opt label=type:unconfined_t -v ./config_server.toml:/config.toml:ro -v ./output:/output -v /var/lib/containers/storage:/var/lib/containers/storage quay.io/centos-bootc/bootc-image-builder:latest --type anaconda-iso --use-librepo=True ghcr.io/lumaeris/vedaos-server:latest
