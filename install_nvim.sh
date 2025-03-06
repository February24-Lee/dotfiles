#!/bin/bash

# 🛠️ Detect operating system
echo "🛠️ Detecting system..."
OS="$(uname -s)"

case "$OS" in
    Darwin*)
        OS_TYPE="macOS"
        PKG_MANAGER="brew"
        ;;
    Linux*)
        OS_TYPE="Linux"
        if command -v apt &>/dev/null; then
            PKG_MANAGER="apt"
        elif command -v yum &>/dev/null; then
            PKG_MANAGER="yum"
        elif command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
        else
            echo "❌ Unsupported package manager."
            exit 1
        fi
        ;;
    *)
        echo "❌ Unsupported operating system: $OS"
        exit 1
        ;;
esac

echo "🛠️ Detected OS: $OS_TYPE"
echo "📦 Using package manager: $PKG_MANAGER"

# Step 1: Install Zsh if missing
if ! command -v zsh &>/dev/null; then
    echo "⚙️ Installing Zsh..."
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install zsh
    else
        sudo $PKG_MANAGER install -y zsh
    fi
fi

# Step 2: Restart script using Zsh if not already running in Zsh
if [[ -z "$ZSH_VERSION" ]]; then
    echo "🔄 Restarting script with Zsh..."
    exec zsh "$0"
    exit
fi

# Step 3: Install essential packages
echo "📦 Installing essential packages..."
if [[ "$PKG_MANAGER" == "brew" ]]; then
    brew install git neovim fzf ripgrep universal-ctags autojump
elif [[ "$PKG_MANAGER" == "apt" ]]; then
    sudo apt update && sudo apt install -y git neovim fzf ripgrep universal-ctags autojump
elif [[ "$PKG_MANAGER" == "yum" || "$PKG_MANAGER" == "dnf" ]]; then
    sudo $PKG_MANAGER install -y git neovim fzf ripgrep ctags autojump
fi

# Step 4: Ensure Neovim is the default editor
#echo "🔗 Setting up Neovim as default editor..."
#ln -sf "$(which nvim)" /usr/local/bin/vim
#ln -sf "$(which nvim)" /usr/local/bin/vi
#ln -sf "$(which nvim)" /usr/local/bin/editor

# Step 5: Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💡 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh is already installed."
fi

# Step 6: Install Powerlevel10k
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "💡 Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "✅ Powerlevel10k is already installed."
fi

# Step 7: Install Oh My Zsh Plugins
echo "🔌 Installing Oh My Zsh plugins..."

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "💡 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions is already installed."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "💡 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting is already installed."
fi

# Step 8: Ensure Neovim config directory exists
if [ ! -d "$HOME/.config/" ]; then
    echo "📁 Creating Neovim config directory..."
    mkdir -p "$HOME/.config/"
fi

# Step 9: Link Neovim config file
echo "🔗 Linking Neovim config file..."
ln -sf "$HOME/.dotfiles/.config/nvim/" "$HOME/.config/nvim"

# Step 10: Ensure Lazy.nvim is installed
LAZY_NVM_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_NVM_DIR" ]; then
    echo "💡 Installing Lazy.nvim..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_NVM_DIR"
else
    echo "✅ Lazy.nvim is already installed."
fi

# Step 11: Apply new settings
echo "🚀 Applying new settings..."
source ~/.zshrc

# Step 12: Restart shell session
echo "🔄 Restarting Zsh session..."
exec zsh

