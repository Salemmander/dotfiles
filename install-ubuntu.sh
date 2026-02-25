#!/usr/bin/env bash
set -e

echo "Installing dependencies for Ubuntu..."
echo

# Update package list
sudo apt update

# Core packages
echo "Installing core packages..."
sudo apt install -y zsh jq tmux git curl stow fzf bat

# Neovim (PPA for latest version)
echo
echo "Installing Neovim from PPA..."
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

# zoxide
echo
echo "Installing zoxide..."
if command -v zoxide &>/dev/null; then
	echo "zoxide already installed, skipping..."
else
	curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# eza
echo
echo "Installing eza..."
sudo apt install -y gpg wget
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# starship
echo
echo "Installing starship..."
if command -v starship &>/dev/null; then
	echo "starship already installed, skipping..."
else
	curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

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
for plugin in zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting; do
	if [ -d "$HOME/.zsh/$plugin" ]; then
		echo "$plugin already installed, skipping..."
	else
		git clone "https://github.com/zsh-users/$plugin" "$HOME/.zsh/$plugin"
	fi
done

# Set zsh as default shell
echo
if [ "$SHELL" = "$(which zsh)" ]; then
	echo "zsh is already the default shell, skipping..."
else
	echo "Setting zsh as default shell..."
	sudo chsh -s "$(which zsh)" "$USER"
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
echo "  stow -t ~ common claude"
echo
echo "After deploying, open tmux and press prefix + I to install plugins."
