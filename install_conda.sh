#!/bin/bash

echo "🌍 Installing Miniconda..."

CONDA_DIR="$HOME/miniconda"

if [[ "$OSTYPE" == "darwin"* ]]; then
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
else
    echo "❌ Miniconda installation is not supported on this OS."
    exit 1
fi

# Download and install Miniconda
curl -o miniconda.sh "$CONDA_URL"
bash miniconda.sh -b -p "$CONDA_DIR"
rm miniconda.sh

echo "✅ Miniconda installation complete!"
