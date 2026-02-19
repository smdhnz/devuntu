#!/bin/bash
set -e

# PATH の設定
export PATH="/opt/volta/bin:/opt/bun/bin:/opt/uv:/opt/nvim/bin:$PATH"

# Docker ソケットの権限変更
if [ -e /var/run/docker.sock ]; then
    sudo chmod 666 /var/run/docker.sock
fi

# .bashrc への追記処理
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "/opt/volta/bin" "$HOME/.bashrc"; then
        echo 'export PATH="/opt/volta/bin:/opt/bun/bin:/opt/uv:/opt/nvim/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    if ! grep -q "source ~/.bash_functions" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Load custom functions" >> "$HOME/.bashrc"
        echo "if [ -f ~/.bash_functions ]; then" >> "$HOME/.bashrc"
        echo "    source ~/.bash_functions" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
    fi
fi

exec "$@"
