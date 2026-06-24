#!/bin/bash
# Installation script for vim/neovim AI assistant

set -e

echo "================================================"
echo "Installing Vim/Neovim AI Assistant"
echo "================================================"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if files exist
if [ ! -f "$SCRIPT_DIR/vim-ai-helper" ]; then
    echo "Error: vim-ai-helper not found in $SCRIPT_DIR"
    exit 1
fi

# Create directories
echo "Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.config/nvim

# Install helper script
echo "Installing vim-ai-helper to ~/.local/bin/"
cp "$SCRIPT_DIR/vim-ai-helper" ~/.local/bin/
chmod +x ~/.local/bin/vim-ai-helper

# Install neovim config
if [ -f ~/.config/nvim/init.lua ]; then
    echo "Backing up existing ~/.config/nvim/init.lua to ~/.config/nvim/init.lua.backup"
    cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup
fi
echo "Installing neovim config to ~/.config/nvim/init.lua"
cp "$SCRIPT_DIR/nvim-init.lua" ~/.config/nvim/init.lua

# Install vim config
if [ -f ~/.vimrc ]; then
    echo "Backing up existing ~/.vimrc to ~/.vimrc.backup"
    cp ~/.vimrc ~/.vimrc.backup
fi
echo "Installing vim config to ~/.vimrc"
cp "$SCRIPT_DIR/vimrc" ~/.vimrc

# Copy docs
echo "Copying documentation to ~/.config/"
cp "$SCRIPT_DIR/README.md" ~/.config/vim-ai-README.md
cp "$SCRIPT_DIR/QUICKREF.txt" ~/.config/vim-ai-quickref.txt
cp "$SCRIPT_DIR/vim-ai-setup.sh" ~/.config/vim-ai-setup.sh
chmod +x ~/.config/vim-ai-setup.sh

echo ""
echo "✓ Files installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Install packages: sudo dnf install -y ollama python3-ollama python3-openai"
echo "  2. Or run full setup: ~/.config/vim-ai-setup.sh"
echo ""
echo "Configuration installed:"
echo "  - ~/.local/bin/vim-ai-helper"
echo "  - ~/.config/nvim/init.lua"
echo "  - ~/.vimrc"
echo "  - ~/.config/vim-ai-README.md"
echo "  - ~/.config/vim-ai-quickref.txt"
echo ""
echo "View docs: cat ~/.config/vim-ai-README.md"
echo "Quick ref: cat ~/.config/vim-ai-quickref.txt"
echo ""
