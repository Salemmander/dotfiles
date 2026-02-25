autoload -Uz compinit
compinit

export PATH="$HOME/.local/share/nvim/mason/bin:$HOME/.local/bin:$PATH"

# Zsh plugins: ~/.zsh/ (git-cloned) or /usr/share/zsh/plugins/ (pacman)
_source_plugin() {
  if [[ -f ~/.zsh/$1/$1.zsh ]]; then
    source ~/.zsh/$1/$1.zsh
  elif [[ -f /usr/share/zsh/plugins/$1/$1.zsh ]]; then
    source /usr/share/zsh/plugins/$1/$1.zsh
  fi
}

_source_plugin zsh-autosuggestions

_source_plugin zsh-history-substring-search
BINDKEY_DEFAULT_INSTALL=true
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

_source_plugin zsh-syntax-highlighting

unfunction _source_plugin

export EDITOR=nvim

# Omarchy envs and functions (Linux)
[[ -f ~/.local/share/omarchy/default/bash/envs ]] && source ~/.local/share/omarchy/default/bash/envs
[[ -f ~/.local/share/omarchy/default/bash/functions ]] && source ~/.local/share/omarchy/default/bash/functions

# Aliases
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases

oc() {
    if [[ "$1" == "logout" ]]; then
        command oc "$@"
        command oc config unset current-context
    else
        command oc "$@"
    fi
}

autoload -U +X bashcompinit && bashcompinit

# Conda (if installed)
if [[ -d "$HOME/miniconda3" ]]; then
  __conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
  if [[ $? -eq 0 ]]; then
    eval "$__conda_setup"
  else
    if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
      . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
      export PATH="$HOME/miniconda3/bin:$PATH"
    fi
  fi
  unset __conda_setup
fi

# Source machine-specific and private env vars
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

if [[ -o interactive ]]; then
  eval "$(zoxide init --cmd cd zsh)"
fi
eval "$(starship init zsh)"