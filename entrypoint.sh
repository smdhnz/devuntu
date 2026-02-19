#!/bin/bash
set -e

# /etc/profile.d/ 下の設定を読み込み（PATHなどを有効化）
if [ -d /etc/profile.d ]; then
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            . "$i"
        fi
    done
    unset i
fi

# Docker ソケットの権限変更
if [ -e /var/run/docker.sock ]; then
    sudo chmod 666 /var/run/docker.sock
fi

# .bashrc への関数読み込み設定
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "source ~/.bash_functions" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Load custom functions" >> "$HOME/.bashrc"
        echo "if [ -f ~/.bash_functions ]; then" >> "$HOME/.bashrc"
        echo "    source ~/.bash_functions" >> "$HOME/.bashrc"
        echo "fi" >> "$HOME/.bashrc"
    fi
fi

exec "$@"
