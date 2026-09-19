#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

omarchy pkg add stow zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting zoxide starship tailscale bitwarden

omarchy install terminal ghostty
omarchy default terminal ghostty
omarchy install browser brave
omarchy default browser brave

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/zsh ]; then
	chsh -s /usr/bin/zsh
fi

echo
read -r -p "One monitor or two? [1/2] " monitors

packages=(common omarchy)
if [ "$monitors" = 2 ]; then
	packages+=(pc)
fi

# Omarchy stock files block stow. Move them aside, then link ours.
backup="$HOME/dotfiles-backup/$(date +%F)-pre-stow"
for pkg in "${packages[@]}"; do
	find "$pkg" -type f | while read -r f; do
		rel="${f#"$pkg"/}"
		dest="$HOME/$rel"
		if [ -e "$dest" ] && [ ! -L "$dest" ]; then
			mkdir -p "$backup/$(dirname "$rel")"
			mv "$dest" "$backup/$rel"
		fi
	done
done

stow -t ~ "${packages[@]}"
