<p align="center"><img src="docs/poni-ng-icon.png" width="96" alt="Poni NG icon: a black island at the top of a blue-violet tile"></p>

<h1 align="center">Poni NG</h1>

<p align="center">A dynamic island for the Linux desktop.</p>

This repository holds Poni NG's Linux releases and its installer.

Poni NG is a fork of [Oyenza Studio](https://github.com/lucacadalora/oyenza-studio) by Jatevo Labs, the MIT-licensed island app for Windows and macOS. The pages, the drawing and the motion come from upstream's code. The fork adds the Linux window, input and system services, and replaces upstream's name, logo and Oyen character with its own name, icon and mascot (Poni, a lavender pony).

Poni NG puts a small black island at the top of your screen. Point at it and it opens into pages: what's playing with synced lyrics, timers and focus sessions, tasks, today's calendar, and your system's CPU, memory and battery. Volume and battery changes show up as small pop-ups on the island itself.

## Install

For your user only, no sudo needed. Run the same line again to update:

```sh
curl -fsSL https://raw.githubusercontent.com/anggaaaaaaaaaaar/poni-release/main/install.sh | sh
```

It puts `poni` in `~/.local/bin`, adds Poni NG to your app menu, and starts it. To remove it:

```sh
curl -fsSL https://raw.githubusercontent.com/anggaaaaaaaaaaar/poni-release/main/install.sh | sh -s -- --uninstall
```

On Fedora, you can install the RPM from the [latest release](https://github.com/anggaaaaaaaaaaar/poni-release/releases/latest) instead:

```sh
sudo dnf install ./poni-ng-*.x86_64.rpm
```

Builds are for x86_64 and need glibc 2.35 or newer (Ubuntu 22.04, Fedora 36 and later).

## Desktops

| Desktop | How the island shows |
| --- | --- |
| KDE Plasma, Hyprland, Sway, COSMIC | A native Wayland layer-shell overlay, sharp at fractional scales |
| GNOME (Wayland) | An X11 window through XWayland |
| Xfce, Cinnamon, i3 and other X11 desktops | An X11 window |

Right-click the island for Settings. Volume pop-ups need `pactl` (`pulseaudio-utils` on Fedora).

## License

Poni NG is released under the [MIT license](LICENSE), as Oyenza Studio is. The license keeps upstream's copyright notice (Jatevo Labs) next to the fork's. [THIRD-PARTY-NOTICES.txt](THIRD-PARTY-NOTICES.txt) lists the licenses of the data and Rust crates the app is built from. Both files also ship inside every download.

The Oyenza Studio name, its logo and the Oyen character belong to upstream and aren't covered by the MIT license, so Poni NG doesn't use them. The Oyenza logo appears only on the pages for Oyenza's own account service, the same way other services' logos do. Poni NG isn't made or endorsed by Jatevo Labs.
