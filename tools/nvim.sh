#!/bin/bash
set -e

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    NVIM_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    NVIM_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
sudo mkdir -p /opt/nvim
sudo tar -C /opt/nvim --strip-components=1 -xzf "nvim-linux-${NVIM_ARCH}.tar.gz"
echo 'export PATH="/opt/nvim/bin:$PATH"' | sudo tee /etc/profile.d/nvim.sh
rm "nvim-linux-${NVIM_ARCH}.tar.gz"
