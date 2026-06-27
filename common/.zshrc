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
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

_source_plugin zsh-syntax-highlighting

_source_plugin zsh-history-substring-search
BINDKEY_DEFAULT_INSTALL=true
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down

unfunction _source_plugin

export EDITOR=nvim
bindkey -v
KEYTIMEOUT=1

shift-space() { LBUFFER+=" " }
zle -N shift-space
bindkey -M viins $'\e[32;2u' shift-space

zle-keymap-select() {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[1 q'
  else
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() { echo -ne '\e[5 q' }
zle -N zle-line-init

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

# Source machine-specific and private env vars
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

if [[ -o interactive ]]; then
  eval "$(zoxide init --cmd cd zsh)"
fi
eval "$(starship init zsh)"
