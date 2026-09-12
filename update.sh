#!/usr/bin/env bash
# archbtw update.sh — re-capture live system into the repo. Run interactively (sudo parts prompt).
# Usage: ./update.sh
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> packages"
pacman -Qqen | sort | grep -v -e '^limine$' -e '^yay-debug$' > "$REPO_DIR/packages/pacman.txt"
pacman -Qqem | sort | grep -v -e '^yay$' -e '^yay-debug$' > "$REPO_DIR/packages/aur.txt"
flatpak list --app --columns=application 2>/dev/null | sort > "$REPO_DIR/packages/flatpak.txt" || true
systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort > "$REPO_DIR/packages/services-system-full.txt"
systemctl --user list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort > "$REPO_DIR/packages/services-user.txt"

echo "==> visor ESP"
cp -f /boot/EFI/visor/boot.conf "$REPO_DIR/system/esp/visor/boot.conf"
cp -f /boot/EFI/visor/themes/noctalia.conf "$REPO_DIR/system/esp/visor/themes/noctalia.conf"
[ -f /boot/EFI/visor/backgrounds/visor-wallpaper.png ] && cp -f /boot/EFI/visor/backgrounds/visor-wallpaper.png "$REPO_DIR/system/esp/visor/backgrounds/" || true
for icon in arch.png windows.png power_shutdown.png power_reboot.png power_bios.png; do
  [ -f "/boot/EFI/visor/icons/$icon" ] && cp -f "/boot/EFI/visor/icons/$icon" "$REPO_DIR/system/esp/visor/icons/" || true
done

echo "==> noctalia GUI state"
cp -f "$HOME/.local/state/noctalia/settings.toml" "$HOME/.local/state/noctalia/state.toml" "$REPO_DIR/noctalia-state/"

echo "==> keyd + greetd"
cp -f /etc/keyd/default.conf "$REPO_DIR/system/etc/keyd/default.conf"
cp -f /etc/greetd/config.toml "$REPO_DIR/system/etc/greetd/config.toml"

echo "done."
