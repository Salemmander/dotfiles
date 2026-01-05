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

# ble.sh (from AUR)
echo
echo "Installing ble.sh..."
if command -v ble &> /dev/null || [ -f ~/.local/share/blesh/ble.sh ]; then
    echo "ble.sh already installed, skipping..."
else
    if command -v yay &> /dev/null; then
        yay -S --needed blesh-git
    elif command -v paru &> /dev/null; then
        paru -S --needed blesh-git
    else
        echo "WARNING: No AUR helper (yay/paru) found. Install blesh-git manually:"
        echo "  yay -S blesh-git"
    fi
fi

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
