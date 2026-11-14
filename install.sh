#!/bin/sh
# Install Poni NG for Linux from the latest release, for this user only
# (no sudo): the app in ~/.local/bin, its menu entry and icon in ~/.local/share.
#
#   curl -fsSL https://raw.githubusercontent.com/anggaaaaaaaaaaar/poni-release/main/install.sh | sh
#
# Run it again to update. `sh install.sh --uninstall` removes it all,
# Start at login included. Your settings and data stay in ~/.local/share
# unless you delete them yourself.
set -eu

# Releases live in a public repository of their own; the source is in poni-ng.
REPO="anggaaaaaaaaaaar/poni-release"
BIN_DIR="${HOME}/.local/bin"
DATA="${XDG_DATA_HOME:-${HOME}/.local/share}"
CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}"
APP="${DATA}/applications/poni-ng.desktop"
ICON="${DATA}/icons/hicolor/512x512/apps/poni-ng.png"
AUTOSTART="${CONFIG}/autostart/poni-ng.desktop"

say() { printf '%s\n' "$*"; }
die() { printf 'install: %s\n' "$*" >&2; exit 1; }

stop_running() {
	if command -v pkill >/dev/null 2>&1; then
		pkill -x poni 2>/dev/null || true
		sleep 0.5
	fi
}

refresh_menus() {
	command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "${DATA}/applications" >/dev/null 2>&1 || true
	command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q "${DATA}/icons/hicolor" >/dev/null 2>&1 || true
	command -v kbuildsycoca6 >/dev/null 2>&1 && kbuildsycoca6 >/dev/null 2>&1 || true
}

if [ "${1:-}" = "--uninstall" ]; then
	stop_running
	rm -f "${BIN_DIR}/poni" "${APP}" "${ICON}" "${AUTOSTART}"
	refresh_menus
	say "Poni NG is removed. Its settings stay in ${DATA}/poni-ng; delete that folder to forget them."
	exit 0
fi

case "$(uname -m)" in
	x86_64 | amd64) ARCH=x86_64 ;;
	*) die "only x86_64 builds are published so far (this machine is $(uname -m)). Build from source: see docs/linux.md." ;;
esac

if command -v curl >/dev/null 2>&1; then
	fetch() { curl -fL --progress-bar -o "$2" "$1"; }
elif command -v wget >/dev/null 2>&1; then
	fetch() { wget -q --show-progress -O "$2" "$1"; }
else
	die "needs curl or wget"
fi

TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT
# PONI_URL: another tarball (a test build, a mirror).
URL="${PONI_URL:-https://github.com/${REPO}/releases/latest/download/poni-ng-linux-${ARCH}.tar.gz}"
say "Downloading ${URL}"
fetch "${URL}" "${TMP}/poni.tar.gz" || die "the download failed (is there a release yet? https://github.com/${REPO}/releases)"
tar -xzf "${TMP}/poni.tar.gz" -C "${TMP}"
[ -x "${TMP}/poni/poni" ] || die "the download has no poni binary in it"

stop_running
# linux-v0.2.30.1 went out as "oyenza-studio": take its menu entry, icon and
# login item away, and keep its settings under the new name.
rm -f "${DATA}/applications/oyenza-studio.desktop" "${DATA}/icons/hicolor/512x512/apps/oyenza-studio.png"
if [ -f "${CONFIG}/autostart/oyenza-studio.desktop" ]; then
	rm -f "${CONFIG}/autostart/oyenza-studio.desktop"
	RELINK_LOGIN=1
fi
if [ -d "${DATA}/oyenza-studio" ] && [ ! -e "${DATA}/poni-ng" ]; then
	mv "${DATA}/oyenza-studio" "${DATA}/poni-ng"
fi
mkdir -p "${BIN_DIR}" "$(dirname "${APP}")" "$(dirname "${ICON}")"
install -m 755 "${TMP}/poni/poni" "${BIN_DIR}/poni"
install -m 644 "${TMP}/poni/poni-ng.png" "${ICON}"
# The menu entry runs this copy by its full path: ~/.local/bin isn't on
# every desktop session's PATH.
sed "s|^Exec=.*|Exec=\"${BIN_DIR}/poni\"|" "${TMP}/poni/poni-ng.desktop" > "${APP}"
chmod 644 "${APP}"
if [ -n "${RELINK_LOGIN:-}" ]; then
	mkdir -p "$(dirname "${AUTOSTART}")"
	sed "s|^Exec=.*|Exec=\"${BIN_DIR}/poni\"|" "${APP}" > "${AUTOSTART}"
fi
refresh_menus

say "Installed Poni NG $("${BIN_DIR}/poni" --version 2>/dev/null || true) to ${BIN_DIR}/poni"

# What the island uses if it is there.
missing=""
command -v pactl >/dev/null 2>&1 || missing="${missing} pactl"
if [ -n "${WAYLAND_DISPLAY:-}" ]; then
	command -v wl-copy >/dev/null 2>&1 || missing="${missing} wl-copy"
fi
if [ -n "${missing}" ]; then
	say ""
	say "Optional, not found:${missing} (volume pop-ups, clipboard)."
	if command -v dnf >/dev/null 2>&1; then
		say "  sudo dnf install pulseaudio-utils wl-clipboard"
	elif command -v apt-get >/dev/null 2>&1; then
		say "  sudo apt install pulseaudio-utils wl-clipboard"
	elif command -v pacman >/dev/null 2>&1; then
		say "  sudo pacman -S libpulse wl-clipboard"
	fi
fi

# Start it now, detached from this terminal.
if [ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]; then
	nohup "${BIN_DIR}/poni" >/dev/null 2>&1 &
	say ""
	say "Poni NG is running: point at the top of the screen. Right-click the island for Settings."
else
	say "Start it from your app menu (Poni NG)."
fi
