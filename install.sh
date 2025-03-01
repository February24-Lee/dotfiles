#!/bin/bash

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
    echo "⚙️ Zsh is not installed. Installing Zsh..."
    
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

# Step 3: Install Homebrew (macOS & Linux)
if [[ "$PKG_MANAGER" == "brew" ]]; then
    if ! command -v brew &>/dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "✅ Homebrew is already installed."
    fi
fi

# Step 4: Install essential packages
echo "📦 Installing essential packages..."
if [[ "$PKG_MANAGER" == "brew" ]]; then
    brew install git vim fzf ripgrep
elif [[ "$PKG_MANAGER" == "apt" ]]; then
    sudo apt update && sudo apt install -y git vim fzf ripgrep
elif [[ "$PKG_MANAGER" == "yum" || "$PKG_MANAGER" == "dnf" ]]; then
    sudo $PKG_MANAGER install -y git vim fzf ripgrep
fi

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

# Step 7: Install zsh-autosuggestions plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "💡 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions is already installed."
fi

# Step 8: Install zsh-syntax-highlighting plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "💡 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting is already installed."
fi

# Step 9: Install Autojump
if ! command -v j &>/dev/null; then
    echo "💡 Installing Autojump..."
    
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install autojump
    elif [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt install -y autojump
    elif [[ "$PKG_MANAGER" == "yum" || "$PKG_MANAGER" == "dnf" ]]; then
        sudo $PKG_MANAGER install -y autojump
    fi
else
    echo "✅ Autojump is already installed."
fi

# Step 10: Configure ~/.zshrc for Autojump
if ! grep -q "autojump.sh" ~/.zshrc; then
    echo "🔧 Configuring Autojump in ~/.zshrc..."
    echo '[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh' >> ~/.zshrc
    echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)' >> ~/.zshrc
fi

# Step 11: Apply the new settings
echo "🚀 Applying new settings..."
source ~/.zshrc

# Step 12: Restart shell session for Autojump to work properly
echo "🔄 Restarting Zsh session..."
exec zsh

echo "✅ Setup complete! 🎉"
