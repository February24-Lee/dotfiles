# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

# Use Powerlevel10k as the theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Ensure Powerlevel10k settings are loaded
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Plugins
plugins=(git zsh-autosuggestions autojump)

# Homebrew auto-detect for macOS/Linux
if command -v brew &>/dev/null; then
    eval "$(brew shellenv)"
fi

# fzf integration (if installed)
if command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files'
    export FZF_DEFAULT_OPTS='-m'
fi

# If Powerlevel10k config is missing, run configuration wizard
if [[ ! -f ~/.p10k.zsh ]]; then
    echo "🚀 Powerlevel10k is installed but not configured!"
    echo "🔧 Run 'p10k configure' to customize your prompt."
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# export PATH="$HOME/miniconda/bin:$PATH"  # commented out by conda initialize
plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/donaldlee/miniconda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/donaldlee/miniconda/etc/profile.d/conda.sh" ]; then
        . "/Users/donaldlee/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/Users/donaldlee/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

