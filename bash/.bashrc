# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"

# ble.sh - syntax highlighting, autosuggestions, etc.
[[ -f /usr/share/blesh/ble.sh ]] && source /usr/share/blesh/ble.sh --noattach
ble-face auto_complete='fg=8'
ble-face region_match=''

# Command highlighting like zsh-syntax-highlighting (green = valid, red = invalid)
ble-face syntax_command='fg=green'
ble-face command_builtin='fg=green'
ble-face command_builtin_dot='fg=green'
ble-face command_alias='fg=green'
ble-face command_function='fg=green'
ble-face syntax_error='fg=red'

ble-face syntax_tilde='fg=252'
ble-face filename_directory='fg=252'
ble-face filename_executable='fg=252'
ble-face filename_link='fg=252'
ble-face filename_orphan='fg=252'
ble-face filename_other='fg=252'
ble-face filename_setuid='fg=252'
ble-face filename_setgid='fg=252'

# History search like zsh-history-substring-search (no info line, substring match)
ble-bind -f up   'history-search-backward hide-status:immediate-accept:substr'
ble-bind -f down 'history-search-forward hide-status:immediate-accept:substr'

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
[[ -f ~/.local/share/omarchy/default/bash/rc ]] && source ~/.local/share/omarchy/default/bash/rc


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

. "$HOME/.local/share/../bin/env"
