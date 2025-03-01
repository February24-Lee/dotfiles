# Enable Powerlevel10k instant prompt (must be at the top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

# Use Powerlevel10k as the theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (Avoid duplicate entries)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)

source $ZSH/oh-my-zsh.sh

# Ensure Powerlevel10k settings are loaded
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Homebrew auto-detect for macOS/Linux
if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
    # Autojump for Homebrew installations
    [ -f "$(brew --prefix)/etc/profile.d/autojump.sh" ] && . "$(brew --prefix)/etc/profile.d/autojump.sh"
elif [ -f "/usr/share/autojump/autojump.sh" ]; then
    . "/usr/share/autojump/autojump.sh"
elif [ -f "/etc/profile.d/autojump.sh" ]; then
    . "/etc/profile.d/autojump.sh"
fi

# fzf integration (if installed)
if command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_DEFAULT_OPTS='-m'
fi

# If Powerlevel10k config is missing, remind user
if [[ ! -f ~/.p10k.zsh ]]; then
    echo "🚀 Powerlevel10k is installed but not configured!"
    echo "🔧 Run 'p10k configure' to customize your prompt."
fi

# Node.js (NVM) settings
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Conda settings
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
