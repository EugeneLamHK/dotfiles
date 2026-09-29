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
