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
