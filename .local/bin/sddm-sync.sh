#!/usr/bin/env bash
# sddm-sync.sh — SDDM background = blurred copy of the CURRENT wallpaper
# (via awww), accent color = wallpaper average (brightened), via ImageMagick.
# Run with:  sudo ~/.local/bin/sddm-sync.sh
set -euo pipefail

REAL_USER="${SUDO_USER:-$USER}"
THEME=/usr/share/sddm/themes/sugar-candy

# 1. live wallpaper from awww
WALL=$(sudo -u "$REAL_USER" \
    XDG_RUNTIME_DIR="/run/user/$(id -u "$REAL_USER")" \
    WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}" \
    awww query 2>/dev/null | sed -n 's/.*image: //p' | head -1 || true)

if [[ -z "${WALL:-}" || ! -f "$WALL" ]]; then
    echo "!! could not resolve wallpaper from awww (got: '${WALL:-empty}')" >&2
    exit 1
fi

command -v magick >/dev/null || { echo "!! imagemagick not installed: sudo pacman -S imagemagick" >&2; exit 1; }

# 2. native resolution
RES=$(sudo -u "$REAL_USER" XDG_RUNTIME_DIR="/run/user/$(id -u "$REAL_USER")" \
    hyprctl monitors 2>/dev/null | grep -o '[0-9]\+x[0-9]\+@' | head -1 | tr -d '@' || true)
RES="${RES:-2880x1800}"

# 3. blurred wallpaper background, cover-cropped to native res
magick "$WALL" \
    -resize "${RES}^" -gravity center -extent "$RES" \
    -blur 0x14 \
    "$THEME/Backgrounds/kokemusu.png"

# 4. accent = wallpaper's average color, brightened + saturated
COLOR=$(magick "$WALL" -resize 1x1 -modulate 130,140 \
    -depth 8 txt: | grep -o '#[0-9a-fA-F]\{6\}' | head -1)
COLOR="${COLOR:-#a9c7ff}"

# 5. write into the theme
sed -i "s|^Background=.*|Background=\"Backgrounds/kokemusu.png\"|" "$THEME/theme.conf"
# monochrome UI: white for normal + focused text (always readable on any wallpaper)
sed -i "s|^AccentColor=.*|AccentColor=\"#ffffff\"|" "$THEME/theme.conf"
sed -i "s|^MainColor=.*|MainColor=\"#ffffff\"|" "$THEME/theme.conf"

echo "SDDM synced: blurred $(basename "$WALL") at $RES, accent $COLOR"
