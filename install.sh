#!/usr/bin/env bash
# archbtw install.sh — archinstall-minimal -> packages + visor + dotfiles + services.
# Usage: ./install.sh [--packages-only] [--dry-run]
#   --packages-only: only pacman/aur/flatpak (safe in containers, skips ESP/sudoers/systemctl/stow)
#   --dry-run: print what would run, change nothing
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_ONLY=0
DRY_RUN=0
for a in "$@"; do
  case "$a" in
    --packages-only) PACKAGES_ONLY=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help) echo "Usage: $0 [--packages-only] [--dry-run]"; exit 0 ;;
    *) echo "unknown arg: $a" >&2; exit 1 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then echo "+ $*"; else echo "+ $*"; "$@"; fi
}

pkg_list() { # $1=file -> stdout filtered (strip comments/blank)
  grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' "$1" || true
}

require_arch() {
  [ -f /etc/arch-release ] || { echo "not Arch, aborting" >&2; exit 1; }
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then return 0; fi
  echo "==> bootstrapping yay"
  run sudo pacman -S --needed --noconfirm base-devel git
  if [ "$DRY_RUN" -eq 1 ]; then return 0; fi
  rm -rf /tmp/yay-bootstrap
  git clone https://aur.archlinux.org/yay.git /tmp/yay-bootstrap
  (cd /tmp/yay-bootstrap && makepkg -si --noconfirm)
  rm -rf /tmp/yay-bootstrap
}

install_packages() {
  echo "==> repo packages"
  # shellcheck disable=SC2046
  run sudo pacman -S --needed --noconfirm $(pkg_list "$REPO_DIR/packages/pacman.txt")
  ensure_yay
  if [ -s "$REPO_DIR/packages/aur.txt" ]; then
    # shellcheck disable=SC2046
    run yay -S --needed --noconfirm $(pkg_list "$REPO_DIR/packages/aur.txt")
  fi
  if [ -s "$REPO_DIR/packages/flatpak.txt" ]; then
    run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    # shellcheck disable=SC2046
    run flatpak install -y flathub $(pkg_list "$REPO_DIR/packages/flatpak.txt")
  fi
}

install_visor() {
  # Visor FIRST for defaults, THEN overlay ours (boot.conf/themes/backgrounds/icons).
  command -v visor >/dev/null 2>&1 || { echo "visor not installed, skipping ESP step"; return 0; }
  if [ ! -d /boot/EFI ] && [ ! -d /boot ]; then echo "no /boot, skipping visor ESP"; return 0; fi
  echo "==> visor defaults"
  run sudo visor install --esp /boot --boot-entry
  run visor config validate --file "$REPO_DIR/system/esp/visor/boot.conf" || true
  echo "==> visor overlay (ours wins)"
  run sudo mkdir -p /boot/EFI/visor/themes /boot/EFI/visor/backgrounds /boot/EFI/visor/icons
  run sudo cp -f "$REPO_DIR/system/esp/visor/boot.conf" /boot/EFI/visor/boot.conf
  run sudo cp -f "$REPO_DIR/system/esp/visor/themes/noctalia.conf" /boot/EFI/visor/themes/noctalia.conf
  if [ -f "$REPO_DIR/system/esp/visor/backgrounds/visor-wallpaper.png" ]; then
    run sudo cp -f "$REPO_DIR/system/esp/visor/backgrounds/visor-wallpaper.png" /boot/EFI/visor/backgrounds/visor-wallpaper.png
  fi
  for icon in arch.png windows.png power_shutdown.png power_reboot.png power_bios.png; do
    [ -f "$REPO_DIR/system/esp/visor/icons/$icon" ] || continue
    run sudo cp -f "$REPO_DIR/system/esp/visor/icons/$icon" "/boot/EFI/visor/icons/$icon"
  done
}

stow_dotfiles() {
  command -v stow >/dev/null 2>&1 || { echo "stow missing, skipping dotfiles"; return 0; }
  echo "==> zsh plugins (manual clones, not packaged)"
  if [ ! -f "$HOME/.local/share/zsh/plugins/zsh-shift-select/zsh-shift-select.plugin.zsh" ]; then
    run mkdir -p "$HOME/.local/share/zsh/plugins"
    run git clone https://github.com/jirutka/zsh-shift-select "$HOME/.local/share/zsh/plugins/zsh-shift-select"
  fi
  echo "==> dotfiles (stow)"
  for pkg in "$REPO_DIR"/dotfiles/*/; do
    [ -d "$pkg" ] || continue
    name="$(basename "$pkg")"
    run stow -d "$REPO_DIR/dotfiles" -t "$HOME" --restow "$name"
  done
}

restore_state() {
  echo "==> noctalia GUI state (settings.toml/state.toml hold builtin[9]+community[8]+visor user template lists)"
  if [ "$DRY_RUN" -eq 1 ]; then echo "+ cp noctalia-state/* -> ~/.local/state/noctalia/"; return 0; fi
  mkdir -p "$HOME/.local/state/noctalia"
  for f in settings.toml state.toml; do
    [ -f "$REPO_DIR/noctalia-state/$f" ] || continue
    [ -f "$HOME/.local/state/noctalia/$f" ] && cp -f "$HOME/.local/state/noctalia/$f" "$HOME/.local/state/noctalia/$f.bak"
    cp -f "$REPO_DIR/noctalia-state/$f" "$HOME/.local/state/noctalia/$f"
  done
  echo "    launch Noctalia once to regenerate theme outputs (kitty/zed/btop/fastfetch/...) + visor hook"
}

restore_system_etc() {
  echo "==> system /etc + helpers"
  run sudo cp -f "$REPO_DIR/system/etc/keyd/default.conf" /etc/keyd/default.conf
  run sudo cp -f "$REPO_DIR/system/etc/greetd/config.toml" /etc/greetd/config.toml
  [ -f "$REPO_DIR/system/etc/zram-generator.conf" ] && run sudo cp -f "$REPO_DIR/system/etc/zram-generator.conf" /etc/systemd/zram-generator.conf || true
  run sudo install -m0755 "$REPO_DIR/system/usr-local/bin/visor-install" /usr/local/bin/visor-install
  run sudo install -m0440 "$REPO_DIR/system/sudoers.d/visor-noctalia" /etc/sudoers.d/visor-noctalia
  run sudo visudo -c -f /etc/sudoers.d/visor-noctalia || true
  echo "    NOTE: snapper configs need sudo interactively: snapper -c root create-config / (if missing)"
}

install_spotify() {
  # Noctalia community template: https://docs.noctalia.dev/noctalia/templates/community/spotify/
  # Spotify itself comes from spotify-launcher (pacman.txt); theming via spicetify + Comfy.
  echo "==> spotify + spicetify"
  local spicetify_bin color_scheme spotify_dir theme_dir
  if command -v spicetify >/dev/null 2>&1; then
    spicetify_bin="spicetify"
  elif [ -x "$HOME/.spicetify/spicetify" ]; then
    spicetify_bin="$HOME/.spicetify/spicetify"
  else
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "+ curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh"
    else
      echo "+ curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh"
      curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
    fi
    spicetify_bin="$HOME/.spicetify/spicetify"
  fi
  # Spotify must be downloaded once via spotify-launcher before spicetify can apply.
  spotify_dir="$HOME/.local/share/spotify-launcher/install/usr/share/spotify"
  if [ ! -d "$spotify_dir" ]; then
    echo "    Spotify not downloaded yet — run 'spotify-launcher' once, then re-run: spicetify apply"
    [ "$DRY_RUN" -eq 1 ] || return 0
  fi
  theme_dir="$HOME/.config/spicetify/Themes"
  if [ ! -d "$theme_dir/Comfy" ]; then
    run mkdir -p "$theme_dir"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "+ git clone Comfy repo -> $theme_dir/Comfy"
    else
      rm -rf /tmp/ComfyRepo
      git clone https://github.com/Comfy-Themes/Spicetify.git /tmp/ComfyRepo
      mv /tmp/ComfyRepo/Comfy "$theme_dir/Comfy"
      rm -rf /tmp/ComfyRepo
    fi
  fi
  color_scheme="${SPICETIFY_COLOR:-Comfy}"
  run "$spicetify_bin" config current_theme Comfy
  run "$spicetify_bin" config color_scheme "$color_scheme"
  run "$spicetify_bin" config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1
  run "$spicetify_bin" apply
  echo "    then enable the Spicetify template in Noctalia (Settings -> Color Scheme -> Templates), already in community_ids"
}

enable_ufw() {
  # Default config only: ufw enable flips ENABLED=yes in /etc/ufw/ufw.conf.
  echo "==> ufw (default config)"
  run sudo ufw --force enable
  run sudo systemctl enable ufw.service
}

enable_services() {
  echo "==> services"
  if [ -f "$REPO_DIR/packages/services-system.txt" ]; then
    # ufw handled separately (needs 'ufw enable', not just systemctl)
    # shellcheck disable=SC2046
    run sudo systemctl enable $(pkg_list "$REPO_DIR/packages/services-system.txt" | grep -v -e '^ufw.service$')
  fi
  if [ -f "$REPO_DIR/packages/services-user.txt" ]; then
    # shellcheck disable=SC2046
    run systemctl --user enable $(pkg_list "$REPO_DIR/packages/services-user.txt")
  fi
}

finish() {
  echo "==> finish"
  run fc-cache -f >/dev/null || true
  run xdg-user-dirs-update || true
  echo "done. Reboot and check: visor menu (Arch+Windows) -> noctalia-greeter -> hyprland, audio, keyd."
}

main() {
  require_arch
  install_packages
  if [ "$PACKAGES_ONLY" -eq 1 ]; then echo "(--packages-only: stopping before visor/dotfiles/services)"; exit 0; fi
  install_visor
  stow_dotfiles
  restore_state
  restore_system_etc
  install_spotify
  enable_ufw
  enable_services
  finish
}

main "$@"
