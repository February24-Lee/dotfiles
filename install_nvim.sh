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

# Function to install Neovim via appimage (works without FUSE in containers)
install_appimage() {
  echo "📦 Installing Neovim via appimage..."

  # Detect architecture and set correct filename
  local arch file
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)  file="nvim-linux-x86_64.appimage" ;;
    aarch64|arm64) file="nvim-linux-arm64.appimage" ;;
    *)
      echo "❌ Unsupported architecture: $arch"
      return 1
      ;;
  esac

  local url="https://github.com/neovim/neovim/releases/latest/download/${file}"
  echo "📥 Downloading: $url"

  # Download with retry and fail-fast
  if ! curl -fL --retry 6 --retry-delay 2 --retry-all-errors \
       -o /tmp/nvim.appimage "$url"; then
    echo "❌ Failed to download appimage"
    return 1
  fi

  # Validate file size (must be > 1MB, otherwise it's likely an error page)
  local filesize
  filesize=$(stat -c%s /tmp/nvim.appimage 2>/dev/null || stat -f%z /tmp/nvim.appimage 2>/dev/null || echo 0)
  if [ "$filesize" -lt 1000000 ]; then
    echo "❌ Download failed (file too small: ${filesize} bytes)"
    rm -f /tmp/nvim.appimage
    return 1
  fi

  chmod u+x /tmp/nvim.appimage

  # Try to extract appimage (works without FUSE)
  cd /tmp
  ./nvim.appimage --appimage-extract >/dev/null 2>&1 || true

  # Determine install location based on privileges
  local nvim_dir nvim_bin
  if [ "$(id -u)" -eq 0 ] || [ -n "$SUDO" ]; then
    nvim_dir="/opt/nvim"
    nvim_bin="/usr/local/bin/nvim"
  else
    nvim_dir="$HOME/.local/opt/nvim"
    nvim_bin="$HOME/.local/bin/nvim"
    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  fi

  if [ -d "/tmp/squashfs-root" ]; then
    # Extracted successfully - install extracted version
    $SUDO rm -rf "$nvim_dir"
    $SUDO mv /tmp/squashfs-root "$nvim_dir"
    $SUDO ln -sf "$nvim_dir/AppRun" "$nvim_bin"
    echo "✅ Neovim installed (extracted appimage) → $nvim_bin"
  else
    # Extraction failed - try direct appimage (requires FUSE)
    $SUDO mv /tmp/nvim.appimage "$nvim_bin"
    echo "✅ Neovim installed (appimage) → $nvim_bin"
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
  # Set CURL with retry for Neovim's dependency downloads
  export CURL="curl -fL --retry 6 --retry-delay 2 --retry-all-errors"
  tmpdir="$(mktemp -d)"
  git clone https://github.com/neovim/neovim.git "$tmpdir/neovim"
  (cd "$tmpdir/neovim" && make CMAKE_BUILD_TYPE=Release && $SUDO make install)
  rm -rf "$tmpdir"
elif [[ "$MODE" == "appimage" ]]; then
  install_appimage
fi

# Link Neovim config (remove existing dir/file first to avoid nested symlink)
mkdir -p "$HOME/.config"
rm -rf "$HOME/.config/nvim"
ln -snf "$HOME/.dotfiles/.config/nvim" "$HOME/.config/nvim"

# Bootstrap Lazy.nvim
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZY_DIR" ]; then
  git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$LAZY_DIR"
fi

# Install fd (for Telescope file search)
install_fd_binary() {
  echo "📦 Installing fd from GitHub release..."
  local arch fd_url
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) fd_url="https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-unknown-linux-musl.tar.gz" ;;
    aarch64|arm64) fd_url="https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-aarch64-unknown-linux-musl.tar.gz" ;;
    *) echo "❌ Unsupported architecture for fd: $arch"; return 1 ;;
  esac
  curl -fL "$fd_url" | tar xz -C /tmp
  mkdir -p "$HOME/.local/bin"
  mv /tmp/fd-*/fd "$HOME/.local/bin/"
  rm -rf /tmp/fd-v*/
  echo "✅ fd installed to ~/.local/bin/fd"
}

echo "📦 Installing fd (fast file finder for Telescope)..."
if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
  echo "✅ fd already installed"
else
  fd_installed=false
  case "$PKG_MANAGER" in
    brew)
      brew install fd && fd_installed=true ;;
    apt-get)
      if $SUDO apt-get install -y fd-find 2>/dev/null; then
        fd_installed=true
        # Debian/Ubuntu installs as 'fdfind', create alias
        if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
          mkdir -p "$HOME/.local/bin"
          ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
          echo "✅ Created symlink: fd -> fdfind"
        fi
      fi ;;
    dnf)
      $SUDO dnf install -y fd-find 2>/dev/null && fd_installed=true ;;
    yum)
      $SUDO yum install -y fd-find 2>/dev/null && fd_installed=true ;;
    pacman)
      $SUDO pacman -S --noconfirm fd 2>/dev/null && fd_installed=true ;;
  esac

  # Fallback to binary if package install failed
  if [ "$fd_installed" = false ]; then
    echo "⚠️ Package install failed, falling back to binary..."
    install_fd_binary
  fi
fi

echo "✅ Done."
command -v nvim >/dev/null 2>&1 && nvim --version | head -n1 || echo "⚠️ nvim not found in PATH"
