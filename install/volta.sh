#!/bin/bash
set -e
export VOLTA_HOME=/opt/volta
curl https://get.volta.sh | bash
export PATH="$VOLTA_HOME/bin:$PATH"
volta install node
# Global npm packages
volta install @google/gemini-cli
volta install typescript
volta install @vtsls/language-server
volta install @vue/language-server
volta install @fsouza/prettierd
volta install @tailwindcss/language-server
