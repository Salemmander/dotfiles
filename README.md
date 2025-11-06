# dotfiles

My dotfiles managed with GNU Stow

## Dependencies

### zsh

1. Create the directory

```bash
mkdir ~/.zsh
```

2. Clone zsh plugins into it

```bash
git clone <https://github.com/zsh-users/zsh-autosuggestions> ~/.zsh/zsh-autosuggestions
git clone <https://github.com/zsh-users/zsh-history-substring-search> ~/.zsh/zsh-history-substring-search
git clone <https://github.com/zsh-users/zsh-syntax-highlighting> ~/.zsh/zsh-syntax-highlighting
```

3. Brew install

```bash
brew install eza neovim zoxide starship tmux
```

4. TPM install

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
