#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.config/nvim/lua

cp -r "$SCRIPT_DIR/v4/lua/"* ~/.config/nvim/lua/

echo "v4 settings copied to ~/.config/nvim/"
