iso:
    @just iso-desktop

iso-desktop:
    #!/bin/sh
    bluebuild generate-iso -R podman --iso-name vedaos.iso image ghcr.io/lumaeris/vedaos

iso-desktop:
    #!/bin/sh
    bluebuild generate-iso -R podman --iso-name vedaos-deck.iso image ghcr.io/lumaeris/vedaos-deck
