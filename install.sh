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
    brew install git vim autojump fzf ripgrep
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

# Step 7: Set Powerlevel10k theme in ~/.zshrc
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc; then
    echo "🎨 Applying Powerlevel10k theme..."
    sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc 2>/dev/null || \
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# Step 8: Install zsh-autosuggestions plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "💡 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions is already installed."
fi

# Step 9: Install Vim Plug (for Vim plugins)
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "💡 Installing Vim Plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "✅ Vim Plug is already installed."
fi

# Step 10: Create symbolic links for dotfiles
echo "🔗 Creating symbolic links for dotfiles..."
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.vimrc ~/.vimrc

# Step 11: Set Zsh as the default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "⚙️ Setting Zsh as the default shell..."
    
    # Ensure Zsh is in /etc/shells before changing the default shell
    if ! grep -q "$(which zsh)" /etc/shells; then
        echo "$(which zsh)" | sudo tee -a /etc/shells
    fi

    chsh -s "$(which zsh)"
fi

# Step 12: Install Powerline Fonts (macOS only)
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "💡 Installing Powerline fonts (MesloLGS NF)..."
    brew install font-meslo-lg-nerd-font
fi

# Step 13: Apply the new settings
echo "🚀 Applying new settings..."
source ~/.zshrc

echo "✅ Setup complete! 🎉"
echo "🔔 Run 'p10k configure' to customize your Powerlevel10k prompt."
