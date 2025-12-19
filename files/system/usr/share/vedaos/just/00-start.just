default:
    @vjust --choose

update:
    #!/usr/bin/env bash
    rpm-ostree update
    flatpak update -y
    brew update
    brew upgrade
    echo "If you want to also update Distrobox containers, press ENTER. Otherwise press CTRL+C."
    read i
    distrobox upgrade -a

enable-tpm2-unlock:
    sudo /usr/libexec/luks-enable-tpm2-autounlock

disable-tpm2-unlock:
    sudo /usr/libexec/luks-disable-tpm2-autounlock

install-default-flatpaks:
    #!/usr/bin/env bash
    flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
    # Disable Fedora Flatpak remotes
       for remote in fedora fedora-testing; do
           if flatpak remote-list | grep -q "$remote"; then
               flatpak remote-delete "$remote"
           fi
       done
    FLATPAK_LIST="$(curl https://raw.githubusercontent.com/Lumaeris/vedaos/main/files/flatpaks | tr '\n' ' ')"
    flatpak --system -y install --reinstall --or-update ${FLATPAK_LIST}

reset-steam:
    #!/usr/bin/env bash
    STEAMPATH="$HOME/.local/share/Steam"
    # Get a list of the contents of steams top level directory except a list of folders/files we can skip to avoid losing data
    STEAMFILES=$(ls ~/.local/share/Steam/ | grep -vP "(userdata|compatibilitytools\.d|config|controller_base|steamapps|music)")
    echo "This script will ${b}remove${n} a bunch of files from $STEAMPATH and sign you out of steam!"
    echo "However your games, music, saves, controller profiles and compatibilitytools/custom-proton will not be touched."
    echo "To cancel and abort this operation press CTRL+C now, to continue press ENTER."
    read i
    killall -9 steam
    sleep 1
    echo "Resetting Steam to a freshly installed state."
    # Loop through each file and process it
    for STEAMFILE in $STEAMFILES
    do
      if [ -d "$STEAMPATH/$STEAMFILE" ]; then
        rm -rv "$STEAMPATH/$STEAMFILE"
      elif [ -f "$STEAMPATH/$STEAMFILE" ]; then
        rm -v "$STEAMPATH/$STEAMFILE"
      fi
    done
    sleep 1
    vedaos-steam &
    exit 0

toggle-updates:
    #!/usr/bin/env bash
    if systemctl is-enabled uupd.timer >/dev/null; then
        systemctl disable uupd.timer
        echo "Autoupdates has been disabled."
    else
        systemctl enable uupd.timer
        echo "Autoupdates has been enabled."
    fi

restore-nvidia-settings:
    #!/usr/bin/env bash
    mkdir -p $HOME/.local/share/applications
    if [ ! -f $HOME/.local/share/applications/nvidia-settings.desktop ]; then
        cp /usr/share/applications/nvidia-settings.desktop $HOME/.local/share/applications/nvidia-settings.desktop
        sed -i '/^Hidden=/d' $HOME/.local/share/applications/nvidia-settings.desktop
    fi

install-docker:
    #!/usr/bin/env bash
    echo "This script downloads lima and docker-cli from brew and it downloads bootc image made for lima in order to use Docker."
    echo "https://github.com/tulilirockz/carinata"
    echo "Press ENTER to continue, otherwise press CTRL+C."
    read i
    brew install lima docker
    limactl create --name=docker --yes https://raw.githubusercontent.com/tulilirockz/carinata/refs/heads/main/docker-carinata-rootful.yaml
