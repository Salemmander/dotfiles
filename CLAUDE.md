# AGENTS.md / CLAUDE.md

This file provides guidance to AI coding agents (Antigravity CLI, Claude Code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow. Configuration files are organized into "packages" that can be selectively symlinked to the home directory.

## Structure

- `common/` - Cross-platform configs (zsh, nvim, tmux, starship, `.local/bin/` helpers)
- `mac/` - macOS-specific configs (ghostty terminal, nvim theme)
- `omarchy/` - Omarchy/Hyprland user overrides (Linux)
- `pc/` - Dual-monitor Acer PC Hyprland overrides
- `claude/` - Claude Code global config, hooks, and skills (`~/.claude/`)
- `antigravity/` - Antigravity CLI global config, hooks, and skills (`~/.gemini/`)
- `KEYBINDS.md` - Quick reference for Neovim/tmux/agy keybinds and skills

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

- **Shell**: zsh with starship prompt
- **Editor**: Neovim with LazyVim distribution
- **Terminal multiplexer**: tmux with TPM plugin manager
- **Navigation**: zoxide (cd replacement), eza (ls replacement)

## Dependencies Setup

Zsh plugins:

- Mac: clone to ~/.zsh/ (zsh-autosuggestions, zsh-history-substring-search, zsh-syntax-highlighting)
- Linux: install via pacman (zsh-autosuggestions, zsh-history-substring-search, zsh-syntax-highlighting)

Tmux plugins: Install TPM to ~/.tmux/plugins/tpm, then prefix + I to install plugins.

## Notes

- `.stow-local-ignore` files control what stow ignores when symlinking
- Machine-specific env vars go in `~/.zshrc.local` (not tracked)
- LazyVim plugin lock file and theme are gitignored
