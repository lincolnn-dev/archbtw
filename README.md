# archbtw

Restore kit for this machine: packages, Visor boot entries, dotfiles, Noctalia state, services.

## Run

```bash
./install.sh                    # full restore (run after archinstall minimal)
./install.sh --dry-run          # preview, changes nothing
./install.sh --packages-only    # packages + flatpak only
./update.sh                     # re-capture this machine into the repo, then git add/commit/push
```

## What `install.sh` does

1. Installs repo + AUR packages (bootstraps `yay`), Flatpak apps.
2. Installs Visor to the ESP, then overlays this repo's `boot.conf`, theme, wallpaper, icons.
3. Stows `dotfiles/` (`zsh`, `kitty`, `zed`, `clamui`, `noctalia` templates, `helium` flags, `spicetify`, `wallpapers`); clones the manual zsh plugin.
4. Restores Noctalia `settings.toml`/`state.toml` (all enabled templates). Launch Noctalia once to regenerate theme files.
5. Restores `keyd`, `greetd`, `zram-generator` configs + `visor-install` helper and its sudoers rule.
6. Installs spicetify (official script), clones Comfy, applies `current_theme Comfy` config set. Spotify must be downloaded once via `spotify-launcher` first.
7. Enables services, enables UFW (default config).
8. Refreshes font cache and user dirs.

## Manual follow-ups

- `chsh -s /usr/bin/zsh`
- `spotify-launcher` once → `spicetify apply` (if deferred)
- `snapper -c root create-config /` (optional)
- Noctalia → confirm template toggles (Spicetify etc.)

## Layout

| Path | Contents |
|---|---|
| `install.sh` / `update.sh` | restore / capture |
| `packages/` | `pacman.txt`, `aur.txt` (`yay` excluded — bootstrapped), `flatpak.txt`, `services-system.txt` (curated) + `-full` reference, `services-user.txt` |
| `dotfiles/*/` | stow packages, each mirroring `$HOME` |
| `noctalia-state/` | `settings.toml`, `state.toml` (restored via copy, not stow — Noctalia rewrites them) |
| `system/esp/visor/` | `boot.conf`, theme, wallpaper, icons (overlay after `visor install`) |
| `system/etc/` | `keyd`, `greetd`, `zram-generator` (+ snapper placeholder) |
| `system/usr-local/bin/` + `system/sudoers.d/` | `visor-install` helper + its sudo rule |

Generated files (`*/themes/noctalia.*`, `*.bak`, Noctalia caches/plugins, runtime JSON) are gitignored.
