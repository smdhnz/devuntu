#!/bin/bash
set -e
export UV_INSTALL_DIR=/opt/uv
curl -LsSf https://astral.sh/uv/install.sh | bash
echo "export UV_INSTALL_DIR=\"$UV_INSTALL_DIR\"" | sudo tee /etc/profile.d/uv.sh
echo 'export PATH="$UV_INSTALL_DIR:$PATH"' | sudo tee -a /etc/profile.d/uv.sh
