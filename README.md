# VedaOS

Opinionated custom image with Steam, GNOME and minimum installed packages, based on [fedora-bootc](https://docs.fedoraproject.org/en-US/bootc/). Personal project with frequent changes.

<img width="1920" height="1080" alt="Screenshot" src="https://github.com/user-attachments/assets/e5873fae-ac1f-41e4-b6e7-0adbfe73f39a" />

Ready and fully functional for daily usage. Even though it's created for myself, you can use it if all you need is native Steam, Flatpak and Homebrew apps :slightly_smiling_face:

## What does it have?

- Starting from `quay.io/fedora/fedora-bootc` instead of [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue), that way we don't get any unwanted changes/packages from Silverblue.
- Uses [CachyOS' kernel](https://github.com/CachyOS/linux-cachyos) (not Clang with Thin LTO because of NVIDIA bug of some sort).
- One of the first [BlueBuild](https://blue-build.org/) images to switch to rpm-ostree's [`build-chunked-oci`](https://coreos.github.io/rpm-ostree/build-chunked-oci/) instead of relying on [hhd's rechunker](https://github.com/hhd-dev/rechunk) which had unnecessary fixes and file permission issues.
- Includes a service to fix `/etc/group` and `/etc/gshadow` desynchronization caused by hhd's rechunker, provided by Tulip (@tulilirockz)! ([`/usr/bin/rechunker-group-fix`](https://github.com/Lumaeris/vedaos/blob/main/files/system/usr/bin/rechunker-group-fix) and [related systemd service](https://github.com/Lumaeris/vedaos/blob/main/files/system/usr/lib/systemd/system/rechunker-group-fix.service)). It's also available on [Zirconium](https://github.com/zirconium-dev/zirconium) now after being proven that it works.
- Same "batteries" you would expect from any [Universal Blue base image](https://github.com/ublue-os/main).
- Necessary packages for [GNOME](https://gnome.org). Took an inspiration from [Bluefin LTS](https://github.com/ublue-os/bluefin-lts).
- [Some extensions](#extensions) for GNOME!
- Applied [MoreWaita icon pack](https://github.com/somepaulo/MoreWaita) and [adw-gtk3 theme](https://github.com/lassekongo83/adw-gtk3) by default.
- [NVIDIA Open drivers](https://github.com/NVIDIA/open-gpu-kernel-modules) are included out of the box (you can still use it on your AMD machine though). Supported GPUs are GTX 16xx and RTX series.
- Natively available [Steam](https://steampowered.com). Do I need to say much?
- [Gamescope](https://github.com/bazzite-org/gamescope) is here if needed.
- [extest](https://github.com/bazzite-org/extest) library is included as well so Steam won't freak out of seeing any controller.
- `rpm-ostree` is available for layering packages! ***But*** it's not adviced to do so, unless it's [Mullvad VPN](http://mullvad.net/) or something similar.
- [Homebrew](https://brew.sh/) is available as well! [Universal Blue's tap](https://github.com/ublue-os/homebrew-tap) does work here (I'm using their VSCodium package just fine)!
- [Tailscale](https://tailscale.com) since why not.
- [Winetricks](https://github.com/Winetricks/winetricks). Still useful. `¯\_(ᵕ—ᴗ—)_/¯`
- [foundry](https://gitlab.gnome.org/GNOME/foundry). kolunmi suggested it to me as an alternative for GNOME Builder. It requires [flatpak-builder](https://github.com/flatpak/flatpak-builder) to be installed, which it is now.
- [Podman](https://podman.io/) and [podman-compose](https://github.com/containers/podman-compose) is here. Not the fan of the latter but it's needed for [WinBoat](https://www.winboat.app/), so whatever.
- [distrobox](https://distrobox.it/)! A better alternative to toolbx.
- Using [BlueBuild](https://blue-build.org/) as a toolkit to create these images! It really does a heavy-lifting so we don't have to manually fix something that broke just because. [Their CLI](https://github.com/blue-build/cli) is also included here.
- Oh, we also have an autoupdater - [uupd](https://github.com/ublue-os/uupd)!

### Extensions

- [User Themes](https://extensions.gnome.org/extension/19)
- [Caffeine](https://extensions.gnome.org/extension/517)
- [AppIndicator Support](https://extensions.gnome.org/extension/615)
- [Blur my Shell](https://extensions.gnome.org/extension/3193)
- [Hot Edge](https://extensions.gnome.org/extension/4222)
- [Alphabetical App Grid](https://extensions.gnome.org/extension/4269)
- [RebootToUEFI](https://extensions.gnome.org/extension/5105)
- [Accent Icons](https://extensions.gnome.org/extension/7535)
- [adw-gtk3 Colorizer](https://extensions.gnome.org/extension/8084)

Feel free to disable them and install your favorites using [Extension Manager](https://flathub.org/apps/com.mattjakeman.ExtensionManager). Oh btw, they aren't configured in any way. All defaults babeh!

## Installation

I did ISO mostly for myself :3c, here ya go: https://drive.google.com/file/d/12df9dw1gZOgqBHqiIs0-MXEEbKA1MT5c/view?usp=sharing (sha256: `65a5fad3cebedba0f8f997891931b19119bb67a31a9d70838b9f2a90d4c691bb`) or download it from GitHub action artifacts: https://github.com/Lumaeris/vedaos/actions/runs/20394427319. I'm ain't gonna setting up R2 storage just for this lol

Alternatively, if you have to, here's a command to manually rebase to it from any other Fedora Atomic image (like Bluefin) (don't forget to add `--enforce-container-sigpolicy` after doing so and rebooting so you'll be on signed image):

```bash
sudo bootc switch ghcr.io/lumaeris/vedaos
```

## Interesting images

Here's a lil list of images that were done by my friendos! :D

- [Zirconium](https://github.com/zirconium-dev/zirconium) - THE Niri bootc image. It already does have some users! I've PR'd NVIDIA support btw.
- [XeniaOS](https://github.com/XeniaMeraki/XeniaOS) - Also a Niri bootc image, but this time using [Arch bootc](https://github.com/bootcrew/arch-bootc) image. Highly experimental.
- [solarpowered](https://github.com/askpng/solarpowered) - Yet another personal image. We share some experiences with each other to resolve some issues and stuff.
- [MizukiOS](https://github.com/koitorin/MizukiOS) - Niri bootc! Another one!! So many of these!!! It uses Bazzite GNOME as a base.
- [Entire Bootcrew project](https://github.com/bootcrew)! Tulip really cooked hard here.

## Dependence on Universal Blue

This list only exists for informational purposes.

### Direct

- ~~hhd's rechunker~~ - not anymore! We use upstream's `build-chunked-oci` as mentioned above.
- Some packages marked as "batteries" - oversteer-udev, ublue-os-luks and ublue-os-udev-rules.
- brew - https://github.com/ublue-os/brew
- uupd - even though it was designed for ublue systems, it can still be used on any atomic system.
- Steam Deck backgrounds repackaged by Bazzite.
- Bazzite's fork of Gamescope.
- Bazzite's fork of libextest (not really any different from upstream).
- [Titanoboa](https://github.com/ublue-os/titanoboa) for Live ISO. Would be used very rarely though.

### In-direct

- Package lists taken from ublue base image and Bluefin LTS.
- Some specific useful fixes from them.
- The reason I started using Fedora Atomic in a first place :P.
- BlueBuild was influenced by ublue, now it's independent from them.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/lumaeris/vedaos
```
