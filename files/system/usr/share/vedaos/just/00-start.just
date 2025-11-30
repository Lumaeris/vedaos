default:
    @vjust --choose

update:
    #!/usr/bin/env bash
    rpm-ostree update
    flatpak update -y
    brew update
    brew upgrade

install-default-flatpaks:
    #!/usr/bin/env bash
    flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
    # Disable Fedora Flatpak remotes
       for remote in fedora fedora-testing; do
           if flatpak remote-list | grep -q "$remote"; then
               flatpak remote-delete "$remote"
           fi
       done
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/Lumaeris/vedaos/main/installer/flatpaks | tr '\n' ' ')"
    flatpak --system -y install --reinstall --or-update ${FLATPAK_LIST}
