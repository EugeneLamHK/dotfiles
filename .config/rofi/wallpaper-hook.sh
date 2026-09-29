#!/bin/bash
# ── Rofi Wallpaper Update Hook ──────────────────────
# Called by waypaper after wallpaper change
# Updates symlink and regenerates matugen colors
# ───────────────────────────────────────────────────

WALLPAPER="$1"
SYMLINK="$HOME/.config/rofi/current-wallpaper"

if [[ -z "$WALLPAPER" ]]; then
    echo "Usage: $0 <wallpaper-path>"
    exit 1
fi

# Update symlink
rm -f "$SYMLINK"
ln -s "$WALLPAPER" "$SYMLINK"
echo "✓ Rofi wallpaper updated: $WALLPAPER"
