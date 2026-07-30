#!/bin/bash

set -e

INSTALL_DIR="$HOME/.local/bin"

echo "Creating install directory..."
mkdir -p "$INSTALL_DIR"

echo "Installing unzip..."
sudo apt update
sudo apt install -y unzip curl

cd /tmp

echo "Downloading Rokit..."
curl -LO https://github.com/rojo-rbx/rokit/releases/download/v1.2.0/rokit-1.2.0-linux-x86_64.zip

echo "Downloading Wally..."
curl -LO https://github.com/UpliftGames/wally/releases/download/v0.3.2/wally-v0.3.2-linux.zip

echo "Extracting files..."
unzip -o rokit-1.2.0-linux-x86_64.zip
unzip -o wally-v0.3.2-linux.zip

echo "Installing binaries..."

chmod +x rokit
chmod +x wally

mv rokit "$INSTALL_DIR/"
mv wally "$INSTALL_DIR/"

echo "Adding ~/.local/bin to PATH..."

if ! grep -q '.local/bin' "$HOME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "Installed:"
rokit --version || true
wally --version || true

echo ""
echo "Restart your Codespace terminal or run:"
echo "source ~/.bashrc"