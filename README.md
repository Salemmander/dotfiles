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

## omarchy/

Omarchy (Hyprland) user overrides. Does not replace packaged Omarchy defaults — only the files you customized.

**Contents:**

- `.config/hypr/monitors.lua` - Dual Acer 27" layout
- `.config/hypr/hyprland.lua` - Workspace pinning (right 1-5, left 6-10)
- `.config/hypr/bindings.lua` - Per-monitor Super+1-5, Super+H/L monitor focus
- `.config/hypr/autostart.lua` / `hyprsunset.conf` - Night light 20:00-07:00
- `.config/hypr/input.lua` - Caps as Ctrl, mouse feel
- `.config/omarchy/shell.json` - Bar layout
- `.config/omarchy/plugins/salem.workspaces/` - Dual-monitor workspace bar widget

**Deploy:**

```bash
stow -t ~ omarchy
```
