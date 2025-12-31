# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow. Configuration files are organized into "packages" that can be selectively symlinked to the home directory.

## Structure

- `common/` - Cross-platform configs (nvim, tmux, starship)
- `mac/` - macOS-specific configs (zsh, ghostty terminal)
- `bash/` - Bash shell configs (used on Linux/Omarchy)
- `hyprland/` - Hyprland window manager configs (Linux)

## Stow Usage

Deploy a package:
```bash
stow -t ~ common   # Symlink common configs to home
stow -t ~ mac      # Symlink mac configs to home
```

Remove a package:
```bash
stow -D -t ~ common
```

## Key Tools

- **Shell**: zsh (mac) or bash (linux) with starship prompt
- **Editor**: Neovim with LazyVim distribution
- **Terminal multiplexer**: tmux with TPM plugin manager
- **Navigation**: zoxide (cd replacement), eza (ls replacement)

## Dependencies Setup

Zsh plugins (clone to ~/.zsh/):
- zsh-autosuggestions
- zsh-history-substring-search
- zsh-syntax-highlighting

Tmux plugins: Install TPM to ~/.tmux/plugins/tpm, then prefix + I to install plugins.

## Notes

- `.stow-local-ignore` files control what stow ignores when symlinking
- Machine-specific env vars go in `~/.zshrc.local` (not tracked)
- LazyVim plugin lock file and theme are gitignored
