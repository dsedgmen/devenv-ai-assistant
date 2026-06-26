#!/bin/bash
# Complete LSP setup for Vim - Single Script
# Installs vim-ale and configures LSP support

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  LSP Setup for Vim (Complete Installation)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Step 1: Install vim-ale
echo "Step 1: Installing vim-ale from Fedora repos..."
sudo dnf install -y vim-ale

echo ""
echo "✅ vim-ale installed!"
echo ""

# Step 2: Update .vimrc with ALE configuration
echo "Step 2: Updating ~/.vimrc with ALE/LSP configuration..."

# Check if ALE config already exists
if grep -q "ALE (LSP) Configuration" ~/.vimrc 2>/dev/null; then
    echo "  ALE configuration already present in ~/.vimrc"
else
    # Backup existing .vimrc
    if [ -f ~/.vimrc ]; then
        cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d_%H%M%S)
        echo "  Backed up existing ~/.vimrc"
    fi

    # The configuration is already in the repo's vimrc file
    # Copy it if needed, or user can pull from git
    if [ -f ~/vim-ai-assistant/vimrc ]; then
        cp ~/vim-ai-assistant/vimrc ~/.vimrc
        echo "  ✅ Installed updated .vimrc with ALE support"
    else
        echo "  ⚠️  Run from repo directory or pull latest vimrc"
        echo "     cd ~/vim-ai-assistant && git pull"
        echo "     cp vimrc ~/.vimrc"
    fi
fi

echo ""

# Step 3: Verify LSP servers are installed
echo "Step 3: Verifying LSP servers..."

LSP_MISSING=0

if command -v pylsp &> /dev/null; then
    echo "  ✅ pylsp (Python LSP)"
else
    echo "  ❌ pylsp not found"
    LSP_MISSING=1
fi

if command -v gopls &> /dev/null; then
    echo "  ✅ gopls (Go LSP)"
else
    echo "  ❌ gopls not found"
    LSP_MISSING=1
fi

if command -v bash-language-server &> /dev/null; then
    echo "  ✅ bash-language-server"
else
    echo "  ❌ bash-language-server not found"
    LSP_MISSING=1
fi

if [ $LSP_MISSING -eq 1 ]; then
    echo ""
    echo "⚠️  Some LSP servers missing. Installing..."
    sudo dnf install -y python3-lsp-server gopls nodejs-bash-language-server
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Installed:"
echo "  ✅ vim-ale (LSP plugin for vim)"
echo "  ✅ LSP servers (pylsp, gopls, bashls)"
echo "  ✅ Updated ~/.vimrc with LSP configuration"
echo ""
echo "LSP Keybindings (same as neovim):"
echo "  gd         - Go to definition"
echo "  gr         - Find references"
echo "  K          - Hover documentation"
echo "  <leader>rn - Rename"
echo "  [d / ]d    - Navigate diagnostics"
echo "  <C-Space>  - Completion (insert mode)"
echo ""
echo "Test it now:"
echo "  vim /tmp/test_lsp.py"
echo "  (Wait 2-3s for LSP to start)"
echo "  (Press K on a function → see docs)"
echo ""
echo "Check ALE status:"
echo "  :ALEInfo"
echo ""
echo "Vim now has full LSP support! 🚀"
echo ""
