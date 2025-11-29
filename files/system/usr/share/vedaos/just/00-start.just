default:
    @vjust --choose

update:
    #!/usr/bin/env bash
    rpm-ostree update
    flatpak update -y
    brew update
    brew upgrade
