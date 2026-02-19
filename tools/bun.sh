#!/bin/bash
set -e
export BUN_INSTALL=/opt/bun
curl -fsSL https://bun.sh/install | bash
echo "export BUN_INSTALL=\"$BUN_INSTALL\"" | sudo tee /etc/profile.d/bun.sh
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' | sudo tee -a /etc/profile.d/bun.sh
