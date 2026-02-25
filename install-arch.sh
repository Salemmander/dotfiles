#!/usr/bin/env bash
set -e

echo "Installing dependencies for Arch Linux..."
echo

# Core packages
echo "Installing core packages..."
sudo pacman -S --needed neovim tmux starship zoxide eza zsh jq stow fzf bat

# Zsh plugins
echo
echo "Installing zsh plugins..."
sudo pacman -S --needed zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting

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

# Claude Code
echo
echo "Installing Claude Code..."
if command -v claude &>/dev/null; then
	echo "Claude Code already installed, skipping..."
else
	curl -fsSL https://claude.ai/install.sh | bash
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
echo "  stow -t ~ common hyprland claude"
echo
echo "After deploying, open tmux and press prefix + I to install plugins."
echo
echo "To use zsh in Ghostty, add this to ~/.config/ghostty/config:"
echo "  command = /usr/bin/zsh"
