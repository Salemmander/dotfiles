#!/usr/bin/env bash
set -e

echo "Installing dependencies for Arch Linux..."
echo

# Core packages (common + bash)
echo "Installing core packages..."
sudo pacman -S --needed neovim tmux starship zoxide eza bash

# Hyprland
echo
echo "Installing Hyprland..."
sudo pacman -S --needed hyprland

# TPM for tmux
echo
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "TPM already installed, skipping..."
else
    echo "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ble.sh instructions
echo
echo "=== ble.sh Installation ==="
echo "ble.sh provides syntax highlighting and autosuggestions for bash."
echo "Install via AUR:"
echo "  yay -S blesh-git"
echo
echo "Or from source:"
echo "  git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git"
echo "  make -C ble.sh install PREFIX=~/.local"

# Verify neovim version
echo
NVIM_VERSION=$(nvim --version | head -1 | grep -oP 'v\K[0-9]+\.[0-9]+')
NVIM_MAJOR=$(echo "$NVIM_VERSION" | cut -d. -f1)
NVIM_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)

if [ "$NVIM_MAJOR" -eq 0 ] && [ "$NVIM_MINOR" -lt 11 ]; then
    echo "WARNING: Neovim version $NVIM_VERSION is older than 0.11"
    echo "LazyVim may not work correctly. Consider updating neovim."
else
    echo "Neovim version $NVIM_VERSION OK"
fi

echo
echo "=== Installation Complete ==="
echo
echo "Deploy configs with stow:"
echo "  stow -t ~ common bash hyprland"
echo
echo "After deploying, open tmux and press prefix + I to install plugins."
