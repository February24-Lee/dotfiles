#!/usr/bin/env bash
set -euo pipefail

MODE="pkg" # default
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pkg) MODE="pkg"; shift ;;
    --build) MODE="build"; shift ;;
    --appimage) MODE="appimage"; shift ;;
    -h|--help)
      echo "Usage: $0 [--pkg|--build|--appimage]"
      exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "🛠️ Detecting system..."
OS="$(uname -s)"
case "$OS" in
  Darwin*) OS_TYPE="macOS"; PKG_MANAGER="brew" ;;
  Linux*)
    OS_TYPE="Linux"
    if command -v apt-get &>/dev/null; then PKG_MANAGER="apt-get"
    elif command -v dnf &>/dev/null; then PKG_MANAGER="dnf"
    elif command -v yum &>/dev/null; then PKG_MANAGER="yum"
    elif command -v pacman &>/dev/null; then PKG_MANAGER="pacman"
    else echo "❌ Unsupported package manager."; exit 1; fi ;;
  *) echo "❌ Unsupported operating system: $OS"; exit 1 ;;
esac
echo "🛠️ Detected OS: $OS_TYPE"
echo "📦 Using package manager: $PKG_MANAGER (mode: $MODE)"

# Set SUDO variable - skip sudo if running as root
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
    echo "🔑 Running as root, skipping sudo"
else
    SUDO="sudo"
fi

# Function to install Neovim via appimage (works without FUSE in containers)
install_appimage() {
  echo "📦 Installing Neovim via appimage..."
  curl -Lo /tmp/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x /tmp/nvim.appimage

  # Try to extract appimage (works without FUSE)
  cd /tmp
  ./nvim.appimage --appimage-extract >/dev/null 2>&1 || true

  if [ -d "/tmp/squashfs-root" ]; then
    # Extracted successfully - install extracted version
    $SUDO rm -rf /opt/nvim
    $SUDO mv /tmp/squashfs-root /opt/nvim
    $SUDO ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
    echo "✅ Neovim installed (extracted appimage)"
  else
    # Extraction failed - try direct appimage (requires FUSE)
    $SUDO mv /tmp/nvim.appimage /usr/local/bin/nvim
    echo "✅ Neovim installed (appimage)"
  fi
  rm -f /tmp/nvim.appimage
}

# (Optional) Assume essential tools are already installed via install.sh
# Only install build dependencies if --build mode is selected
if [[ "$MODE" == "build" ]]; then
  echo "📦 Installing build dependencies..."
  case "$PKG_MANAGER" in
    brew)
      brew install ninja gettext libtool automake cmake pkg-config ;;
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl ;;
    dnf|yum)
      $SUDO "$PKG_MANAGER" install -y ninja-build gettext libtool autoconf automake cmake gcc-c++ pkgconfig unzip curl || true ;;
    pacman)
      $SUDO pacman -S --noconfirm base-devel ninja gettext libtool autoconf automake cmake pkgconf unzip curl ;;
  esac
fi

# Install Neovim (different modes)
echo "🚀 Installing Neovim..."
if [[ "$MODE" == "pkg" ]]; then
  case "$PKG_MANAGER" in
    brew)  brew install neovim ;;
    apt-get)
      # Try PPA first, fallback to appimage if it fails
      if $SUDO apt-get update && \
         $SUDO apt-get install -y software-properties-common python3-apt && \
         $SUDO add-apt-repository -y ppa:neovim-ppa/unstable && \
         $SUDO apt-get update && \
         $SUDO apt-get install -y neovim; then
        echo "✅ Neovim installed via PPA"
      else
        echo "⚠️ PPA failed, falling back to appimage..."
        install_appimage
      fi ;;
    dnf|yum|pacman) $SUDO "$PKG_MANAGER" install -y neovim ;;
  esac
elif [[ "$MODE" == "build" ]]; then
  tmpdir="$(mktemp -d)"
  git clone https://github.com/neovim/neovim.git "$tmpdir/neovim"
  (cd "$tmpdir/neovim" && make CMAKE_BUILD_TYPE=Release && $SUDO make install)
  rm -rf "$tmpdir"
elif [[ "$MODE" == "appimage" ]]; then
  install_appimage
fi

# Link Neovim config
mkdir -p "$HOME/.config"
ln -snf "$HOME/.dotfiles/.config/nvim" "$HOME/.config/nvim"

# Bootstrap Lazy.nvim
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_DIR" ]; then
  git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
fi

echo "✅ Done."
command -v nvim >/dev/null 2>&1 && nvim --version | head -n1 || echo "⚠️ nvim not found in PATH"
