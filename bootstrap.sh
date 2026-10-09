#!/bin/bash
# Run on a fresh CachyOS install after cloning the bare repo (see README).
set -e

REPO="git@github.com:EugeneLamHK/dotfiles.git"

echo "==> Installing packages"
sudo pacman -S --needed git openssh
sudo pacman -S --needed - < ~/pkglist.txt 2>/dev/null || true

if ! command -v paru &>/dev/null; then
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  (cd /tmp/paru && makepkg -si --noconfirm)
fi
paru -S --needed - < ~/aurlist.txt 2>/dev/null || true

echo "==> Recreating hypr symlink"
mkdir -p ~/Downloads/ConfigFiles
ln -sfn ~/Downloads/ConfigFiles/hypr ~/.config/hypr

echo "==> Done. Log out/in (or reboot) to start Hyprland with your rice."
# ============================================================
# bootstrap.sh v4 ADDITIONS — kokemusu lock/login + Framework
# Append this block to the END of ~/bootstrap.sh
# (idempotent: safe to run multiple times)
# ============================================================

echo "==> v4: lock screen / login / theming"

# ---- packages (belt & suspenders; lists are the source of truth) ----
sudo pacman -S --needed --noconfirm imagemagick hyprlock

# ---- SDDM: use sugar-candy (installed from aurlist) ----
if [[ -f /etc/sddm.conf ]]; then
    if grep -q '^Current=' /etc/sddm.conf; then
        sudo sed -i 's|^Current=.*|Current=sugar-candy|' /etc/sddm.conf
    else
        printf '[Theme]\nCurrent=sugar-candy\n' | sudo tee -a /etc/sddm.conf >/dev/null
    fi
else
    printf '[Theme]\nCurrent=sugar-candy\n' | sudo tee /etc/sddm.conf >/dev/null
fi

# ---- sudoers: allow passwordless sddm-sync (for waypaper hook) ----
echo "$USER ALL=(ALL) NOPASSWD: $HOME/.local/bin/sddm-sync.sh" | sudo tee /etc/sudoers.d/sddm-sync >/dev/null
sudo chmod 440 /etc/sudoers.d/sddm-sync

# ---- ensure the waypaper hook line exists ----
if [[ -f "$HOME/.local/bin/waypaper-post.sh" ]] \
    && ! grep -q sddm-sync "$HOME/.local/bin/waypaper-post.sh"; then
    echo 'sudo -n ~/.local/bin/sddm-sync.sh >/dev/null 2>&1 &' >> "$HOME/.local/bin/waypaper-post.sh"
fi

# ============================================================
# FRAMEWORK 13 PRO — DAY-ONE CHECKLIST (manual, after first login)
# ============================================================
# 1. BIOS: MAX BATTERY profile, Turbo Boost Max 3.0 OFF,
#    Secure Boot OFF, TPM "No operation"
# 2. Fingerprint:  fprintd-enroll -f right-index-finger
#    (PAM for hyprlock/sudo already set up by bootstrap v3;
#     hyprlock fingerprint block is in the generated config)
# 3. Monitor:  hyprctl monitors
#    expect: eDP-1, 2880x1920@120.00000, scale 2
# 4. Hardware video:  vainfo | grep -i h264   (iHD driver)
# 5. Pick a wallpaper in waypaper once → matugen runs →
#    hyprlock.conf + qs Colors generate automatically
# 6. First SDDM sync (needs a running session):
#    sudo ~/.local/bin/sddm-sync.sh
# 7. Battery baseline:  ~/battery-forensics.sh
#    Framework target: 7.5-9h+ real use
# ============================================================
