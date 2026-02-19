#!/bin/bash
set -e
export VOLTA_HOME=/opt/volta
curl https://get.volta.sh | bash -s -- --skip-setup
echo "export VOLTA_HOME=\"$VOLTA_HOME\"" | sudo tee /etc/profile.d/volta.sh
echo 'export PATH="$VOLTA_HOME/bin:$PATH"' | sudo tee -a /etc/profile.d/volta.sh

# Add volta to current PATH for subsequent commands in this script
export PATH="$VOLTA_HOME/bin:$PATH"

volta install node
# Global npm packages
volta install @google/gemini-cli
volta install typescript
volta install @vtsls/language-server
volta install @vue/language-server
volta install @fsouza/prettierd
volta install @tailwindcss/language-server
