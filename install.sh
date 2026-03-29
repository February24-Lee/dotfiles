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
        if command -v apt-get &>/dev/null; then
            PKG_MANAGER="apt-get"
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

# Set SUDO variable - skip sudo if running as root or sudo not available
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
    echo "🔑 Running as root, skipping sudo"
elif command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
    echo "⚠️ sudo not found, running without elevated privileges"
fi

# Step 1: Install Zsh if missing
if ! command -v zsh &>/dev/null; then
    echo "⚙️ Installing Zsh..."
    
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install zsh
    else
        $SUDO $PKG_MANAGER update
        $SUDO $PKG_MANAGER install -y zsh
    fi
fi

# Step 2: Restart script using Zsh if not already running in Zsh
if [[ -z "$ZSH_VERSION" ]] && command -v zsh &>/dev/null; then
    echo "🔄 Restarting script with Zsh..."
    exec zsh "$0"
fi

# Step 3: Install essential packages (macOS & Linux)
echo "📦 Installing essential packages..."
if [[ "$PKG_MANAGER" == "brew" ]]; then
    brew install git vim fzf ripgrep fd
elif [[ "$PKG_MANAGER" == "apt-get" ]]; then
    # Git PPA for latest version (needed for lazygit etc.)
    if $SUDO apt-get install -y software-properties-common 2>/dev/null; then
        $SUDO add-apt-repository -y ppa:git-core/ppa 2>/dev/null || true
    fi
    $SUDO apt-get update && $SUDO apt-get install -y git vim fzf ripgrep fd-find unzip
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd  # Ubuntu에서는 fdfind로 설치되므로 fd로 링크
elif [[ "$PKG_MANAGER" == "yum" || "$PKG_MANAGER" == "dnf" ]]; then
    $SUDO $PKG_MANAGER install -y git vim fzf ripgrep fd-find unzip
elif [[ "$PKG_MANAGER" == "pacman" ]]; then
    $SUDO pacman -S --noconfirm git vim fzf ripgrep fd unzip
else
    echo "❌ Unsupported package manager. Skipping fd installation."
fi
# Step  Install NVM, Node.js, and npm
echo "📦 Installing NVM (Node Version Manager)..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
else
    echo "✅ NVM is already installed."
fi

echo "📦 Installing latest LTS version of Node.js..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*' || nvm alias default $(nvm version lts/*)


echo "🔍 Checking Node.js and npm versions..."
node -v
npm -v

# Step: Install uv (Python package manager)
echo "📦 Installing uv..."
if command -v uv &>/dev/null; then
    echo "✅ uv is already installed."
else
    case "$PKG_MANAGER" in
        brew)    brew install uv ;;
        *)       curl -LsSf https://astral.sh/uv/install.sh | sh ;;
    esac
fi

# Step: Install lazygit
echo "📦 Installing lazygit..."
if command -v lazygit &>/dev/null; then
    echo "✅ lazygit is already installed."
else
    case "$PKG_MANAGER" in
        brew) brew install lazygit ;;
        *)
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            ARCH="$(uname -m)"
            case "$ARCH" in
                x86_64|amd64)  LAZYGIT_ARCH="Linux_x86_64" ;;
                aarch64|arm64) LAZYGIT_ARCH="Linux_arm64" ;;
                *) echo "❌ Unsupported architecture for lazygit: $ARCH"; LAZYGIT_ARCH="" ;;
            esac
            if [ -n "$LAZYGIT_ARCH" ]; then
                curl -fLo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_${LAZYGIT_ARCH}.tar.gz"
                tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
                mkdir -p "$HOME/.local/bin"
                mv /tmp/lazygit "$HOME/.local/bin/"
                rm -f /tmp/lazygit.tar.gz
            fi ;;
    esac
fi

# Step: Install Claude Code
echo "📦 Installing Claude Code..."
if command -v claude &>/dev/null; then
    echo "✅ Claude Code is already installed."
else
    npm install -g @anthropic-ai/claude-code
fi

# Step 4: Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💡 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh is already installed."
fi

# Step 5: Install Powerlevel10k
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "💡 Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "✅ Powerlevel10k is already installed."
fi

# Step 6: Install Oh My Zsh Plugins
echo "🔌 Installing Oh My Zsh plugins..."

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "💡 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions is already installed."
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "💡 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "✅ zsh-syntax-highlighting is already installed."
fi

# Step 7: Create Soft Links for dotfiles
echo "🔗 Creating soft links for dotfiles..."
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/.vimrc ~/.vimrc
ln -sf ~/.dotfiles/.tmux.conf ~/.tmux.conf

# Step 8: Ensure Vim Plug is installed
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "💡 Installing Vim Plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "✅ Vim Plug is already installed."
fi

# Step 9: Ensure Autojump is installed (with correct sourcing)
if ! command -v j &>/dev/null; then
    echo "💡 Installing Autojump..."
    
    if [[ "$PKG_MANAGER" == "brew" ]]; then
        brew install autojump
    elif [[ "$PKG_MANAGER" == "apt-get" ]]; then
        $SUDO apt-get install -y autojump
    elif [[ "$PKG_MANAGER" == "yum" || "$PKG_MANAGER" == "dnf" ]]; then
        $SUDO $PKG_MANAGER install -y autojump
    else
        echo "❌ Autojump is not available in this package manager. Skipping."
    fi
else
    echo "✅ Autojump is already installed."
fi

echo ""
echo "============================================"
echo "  Installation Summary"
echo "============================================"
printf "  %-20s %s\n" "Tool" "Status"
echo "--------------------------------------------"
for tool in zsh git vim fzf rg fd node npm uv lazygit claude; do
    if command -v "$tool" &>/dev/null; then
        version=$("$tool" --version 2>/dev/null | head -1) || version="installed"
        printf "  %-20s ✅ %s\n" "$tool" "$version"
    else
        printf "  %-20s ❌ not found\n" "$tool"
    fi
done
echo "============================================"
echo ""
echo "➡️  If you also want to install or update Neovim, run:"
echo "    ./install_nvim.sh --pkg      # Install via package manager (default)"
echo "    ./install_nvim.sh --build    # Build from source"
echo "    ./install_nvim.sh --appimage # Use AppImage binary"
echo ""
echo "💡 You can safely skip this step if Neovim is already installed."
