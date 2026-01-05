#!/usr/bin/env bash
set -e

echo "Installing dependencies for Ubuntu..."
echo

# Update package list
sudo apt update

# Core packages
echo "Installing core packages..."
sudo apt install -y tmux bash git curl build-essential

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
if command -v zoxide &> /dev/null; then
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
if command -v starship &> /dev/null; then
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

# ble.sh (from source)
echo
echo "Installing ble.sh..."
if [ -f ~/.local/share/blesh/ble.sh ]; then
    echo "ble.sh already installed, skipping..."
else
    sudo apt install -y gawk
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
    make -C /tmp/ble.sh install PREFIX=~/.local
    rm -rf /tmp/ble.sh
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
echo "  sudo apt install stow"
echo "  stow -t ~ common bash"
echo
echo "After deploying, open tmux and press prefix + I to install plugins."
