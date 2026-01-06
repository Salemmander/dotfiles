# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"

# ble.sh - syntax highlighting, autosuggestions, etc.
# Config is in ~/.blerc (loaded automatically by ble.sh)
if [[ -f /usr/share/blesh/ble.sh ]]; then
    source /usr/share/blesh/ble.sh --noattach
elif [[ -f ~/.local/share/blesh/ble.sh ]]; then
    source ~/.local/share/blesh/ble.sh --noattach
fi

# Aliases - use omarchy if available, otherwise use dotfiles version
if [[ -f ~/.local/share/omarchy/default/bash/rc ]]; then
    source ~/.local/share/omarchy/default/bash/rc
elif [[ -f ~/.bash_aliases ]]; then
    source ~/.bash_aliases
elif [[ -f ~/.bash_secrets ]]; then
    source ~/.bash_secrets
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/salem/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/salem/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/salem/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/salem/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

alias c='clear'
alias cs='c;ls'
alias csa='c;lsa'
alias ct='c;lt'
alias cta='c;lta'
alias lt='eza --tree --group-directories-first --level=2 --long --icons --git'

eval "$(starship init bash)"

# Attach ble.sh (must be at the end)
[[ ${BLE_VERSION-} ]] && ble-attach

# Source local env if it exists
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
