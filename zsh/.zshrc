autoload -Uz compinit
compinit

# Autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# History Substring Search
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
BINDKEY_DEFAULT_INSTALL=true
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Command Syntax highlighting 
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Source machine-specific and private env vars
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

export EDITOR=nvim

alias c='clear'
alias n='nvim'
alias ls='eza -lh --no-user --group-directories-first --icons="always" --color="always"'
alias lsa='ls -a'
alias lt='eza -h --no-user --group-directories-first --tree --level=2 --long --icons="always"  --color="always" --git'
alias lta='lt -a'
alias csa='c;lsa'
alias cs='c;ls'
alias cta='c;lta'
alias ct='c;lt'

autoload -U +X bashcompinit && bashcompinit

eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"


