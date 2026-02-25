#!/usr/bin/env bash
set -e

echo "Installing dependencies for macOS..."
echo

# Check for Homebrew
if ! command -v brew &>/dev/null; then
	echo "Error: Homebrew is not installed."
	echo "Install it from https://brew.sh"
	exit 1
fi

# Core packages
echo "Installing core packages..."
brew install neovim tmux starship zoxide eza jq stow fzf bat

# Ghostty terminal (optional)
echo
echo "Installing Ghostty terminal..."
brew install --cask ghostty || echo "Ghostty install skipped (may already be installed or unavailable)"

# TPM for tmux
echo
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
	echo "TPM already installed, skipping..."
else
	echo "Installing TPM (Tmux Plugin Manager)..."
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Zsh plugins
echo
echo "Installing zsh plugins..."
mkdir -p ~/.zsh

if [ -d "$HOME/.zsh/zsh-autosuggestions" ]; then
	echo "zsh-autosuggestions already installed, skipping..."
else
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

if [ -d "$HOME/.zsh/zsh-history-substring-search" ]; then
	echo "zsh-history-substring-search already installed, skipping..."
else
	git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh/zsh-history-substring-search
fi

if [ -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
	echo "zsh-syntax-highlighting already installed, skipping..."
else
	git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
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
NVIM_VERSION=$(nvim --version | head -1 | sed 's/NVIM v//' | cut -d'-' -f1)
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
echo "  stow -t ~ common mac claude"
echo
echo "After deploying, open tmux and press prefix + I to install plugins."
echo "Create ~/.zshrc.local for machine-specific environment variables."
