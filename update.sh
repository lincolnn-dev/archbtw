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

echo "==> visor ESP (overlay source)"
cp -f /boot/EFI/visor/boot.conf "$REPO_DIR/system/esp/visor/boot.conf"
cp -f /boot/EFI/visor/themes/noctalia.conf "$REPO_DIR/system/esp/visor/themes/noctalia.conf"
[ -f /boot/EFI/visor/backgrounds/visor-wallpaper.png ] && cp -f /boot/EFI/visor/backgrounds/visor-wallpaper.png "$REPO_DIR/system/esp/visor/backgrounds/" || true
for icon in arch.png windows.png power_shutdown.png power_reboot.png power_bios.png; do
  [ -f "/boot/EFI/visor/icons/$icon" ] && cp -f "/boot/EFI/visor/icons/$icon" "$REPO_DIR/system/esp/visor/icons/" || true
done

echo "==> noctalia GUI state + user templates"
cp -f "$HOME/.local/state/noctalia/settings.toml" "$HOME/.local/state/noctalia/state.toml" "$REPO_DIR/noctalia-state/"
cp -f "$HOME/.config/noctalia/templates.toml" "$REPO_DIR/dotfiles/noctalia/.config/noctalia/templates.toml"
cp -f "$HOME/.config/noctalia/templates/visor.conf" "$REPO_DIR/dotfiles/noctalia/.config/noctalia/templates/visor.conf"
cp -f "$HOME"/.config/noctalia/palettes/*.json "$REPO_DIR/dotfiles/noctalia/.config/noctalia/palettes/" 2>/dev/null || true
rsync -a --delete "$HOME/Pictures/wallpapers/" "$REPO_DIR/dotfiles/wallpapers/Pictures/wallpapers/" 2>/dev/null || cp -f "$HOME"/Pictures/wallpapers/* "$REPO_DIR/dotfiles/wallpapers/Pictures/wallpapers/"

echo "==> system /etc (world-readable now; sudo parts best-effort)"
cp -f /etc/keyd/default.conf "$REPO_DIR/system/etc/keyd/default.conf"
cp -f /etc/greetd/config.toml "$REPO_DIR/system/etc/greetd/config.toml"
cp -f /etc/systemd/zram-generator.conf "$REPO_DIR/system/etc/zram-generator.conf" 2>/dev/null || true
cp -f /usr/local/bin/visor-install "$REPO_DIR/system/usr-local/bin/visor-install"
cp -f "$HOME/.config/noctalia/templates/visor-nopasswd.sudoers" "$REPO_DIR/system/sudoers.d/visor-noctalia" 2>/dev/null || sudo cp -f /etc/sudoers.d/visor-noctalia "$REPO_DIR/system/sudoers.d/visor-noctalia" 2>/dev/null || echo "    (sudoers.d needs sudo, skipped)"
sudo cp -f /etc/snapper/configs/root /etc/snapper/configs/home "$REPO_DIR/system/etc/snapper/configs/" 2>/dev/null || echo "    (snapper needs sudo, skipped)"

echo "==> dotfiles (base configs only, never generated noctalia outputs)"
for f in zed/.config/zed/settings.json helium/.config/helium-browser-flags.conf spicetify/.config/spicetify/config-xpui.ini; do
  src="$HOME/.config/$(echo "$f" | cut -d/ -f2-)"
  # map: zed settings, helium flags, spicetify ini
  case "$f" in
    zed*) [ -f "$HOME/.config/zed/settings.json" ] && cp -f "$HOME/.config/zed/settings.json" "$REPO_DIR/dotfiles/zed/.config/zed/settings.json" || true ;;
    helium*) [ -f "$HOME/.config/helium-browser-flags.conf" ] && cp -f "$HOME/.config/helium-browser-flags.conf" "$REPO_DIR/dotfiles/helium/.config/helium-browser-flags.conf" || true ;;
    spicetify*) [ -f "$HOME/.config/spicetify/config-xpui.ini" ] && cp -f "$HOME/.config/spicetify/config-xpui.ini" "$REPO_DIR/dotfiles/spicetify/.config/spicetify/config-xpui.ini" || true ;;
  esac
done
[ -d "$HOME/.config/spicetify/Themes" ] && cp -rf "$HOME/.config/spicetify/Themes/." "$REPO_DIR/dotfiles/spicetify/.config/spicetify/Themes/" || true
# normalize $HOME so restore works even if username changes
[ -f "$HOME/.zshrc" ] && sed "s|$HOME|\$HOME|g" "$HOME/.zshrc" > "$REPO_DIR/dotfiles/zsh/.zshrc" || true
[ -f "$HOME/.config/kitty/kitty.conf" ] && cp -f "$HOME/.config/kitty/kitty.conf" "$REPO_DIR/dotfiles/kitty/.config/kitty/kitty.conf" || true
[ -f "$HOME/.config/clamui/settings.json" ] && cp -f "$HOME/.config/clamui/settings.json" "$REPO_DIR/dotfiles/clamui/.config/clamui/settings.json" || true
[ -f "$HOME/.config/clamui/profiles.json" ] && cp -f "$HOME/.config/clamui/profiles.json" "$REPO_DIR/dotfiles/clamui/.config/clamui/profiles.json" || true

echo "done. Review with: git -C \"$REPO_DIR\" status --porcelain=v1 && git -C \"$REPO_DIR\" diff --stat"
