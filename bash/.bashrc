# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc


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
