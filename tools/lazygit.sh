#!/bin/bash
set -e

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    LG_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ]; then
    LG_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm -rf lazygit.tar.gz lazygit
