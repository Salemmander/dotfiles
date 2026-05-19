# dotfiles

Personal dotfiles managed with GNU Stow.

## Stow Usage

```bash
# Deploy a package
stow -t ~ <package>

# Remove a package
stow -D -t ~ <package>

# Preview changes (dry run)
stow -n -v -t ~ <package>
```

## Quick Install

Install scripts automate dependency installation for each platform:

```bash
# Arch Linux
./install-arch.sh

# Ubuntu
./install-ubuntu.sh

# macOS
./install-mac.sh
```

Then deploy configs with stow (see per-package instructions below).

---

## common/

Cross-platform configurations for Neovim, tmux, and starship prompt.

**Contents:**

- `.tmux.conf` - Tmux with vim-like keybindings
- `.config/nvim/` - Neovim with LazyVim distribution
- `.config/starship.toml` - Starship prompt theme

**Install dependencies:**

```bash
# macOS
brew install neovim tmux starship

# Arch Linux
sudo pacman -S neovim tmux starship
```

**Install TPM (Tmux Plugin Manager):**

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then open tmux and press `prefix + I` to install plugins.

Neovim plugins install automatically via lazy.nvim on first launch.

**Deploy:**

```bash
stow -t ~ common
```

---

## mac/

macOS-specific configs for zsh and Ghostty terminal.

**Contents:**

- `.zshrc` - Zsh configuration with plugins and aliases
- `.config/ghostty/config` - Ghostty terminal settings
- `.config/nvim/lua/plugins/theme.lua` - macOS theme override

**Install dependencies:**

```bash
brew install zsh zoxide eza starship

# Optional: Ghostty terminal
brew install --cask ghostty
```

**Install zsh plugins:**

```bash
mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
```

**Deploy:**

```bash
stow -t ~ mac
```

Create `~/.zshrc.local` for machine-specific environment variables (not tracked).

---

## bash/

Bash shell configuration for Linux systems.

**Contents:**

- `.bashrc` - Bash config with ble.sh, aliases, conda setup
- `.bash_profile` - Sources .bashrc

**Install dependencies:**

```bash
# Arch Linux
sudo pacman -S bash zoxide eza starship
```

**Install ble.sh (syntax highlighting & autosuggestions):**

```bash
# From source
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local

# Or via AUR
yay -S blesh-git
```

**Deploy:**

```bash
stow -t ~ bash
```

---

## hyprland/

Shared Hyprland configuration used on all Linux machines (laptop + desktop).

**Contents:**

- `.config/hypr/bindings.conf` - Custom keybindings, application launchers, and webapp shortcuts (user overrides for Omarchy defaults)

**Install dependencies:**

```bash
# Arch Linux
sudo pacman -S hyprland
```

**Deploy (all machines):**

```bash
stow -t ~ hyprland
```

---

## hyprland-laptop/

Laptop-specific Hyprland configuration. Contains monitor layout, clamshell mode, lid handling, and hardware-specific autostart. **Only stow this on the laptop.**

**Contents:**

- `.config/hypr/monitors.conf` - Monitor layout, workspace pinning, and lid switch bindings
- `.config/hypr/autostart.conf` - Laptop-only autostart commands
- `.config/hypr/scripts/lid-close.sh` - Disable internal display / suspend on lid close
- `.config/hypr/scripts/lid-open.sh` - Restore internal display on lid open

**Deploy (laptop only):**

```bash
stow -t ~ hyprland
stow -t ~ hyprland-laptop
```

**On desktop machines:** Only run `stow hyprland`. The laptop-specific files will not exist.
