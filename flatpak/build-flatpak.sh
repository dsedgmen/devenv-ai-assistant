#!/bin/bash
# Build Flatpak packages for Vim and Neovim
# Uses Fedora source RPMs

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Flatpak Builder for Vim AI Assistant"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check dependencies
if ! command -v flatpak-builder &> /dev/null; then
    echo "❌ flatpak-builder not found"
    echo "Install with: sudo dnf install flatpak-builder"
    exit 1
fi

# Add Flathub if not already added
if ! flatpak remotes | grep -q flathub; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install required runtimes
echo "Installing Flatpak runtimes..."
flatpak install -y flathub org.freedesktop.Platform//23.08 org.freedesktop.Sdk//23.08

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Building Neovim Flatpak"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Build Neovim
flatpak-builder --force-clean --repo=repo build-neovim org.neovim.Neovim.yaml

echo ""
echo "✅ Neovim Flatpak built!"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "  Building Vim Flatpak"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Build Vim
flatpak-builder --force-clean --repo=repo build-vim org.vim.Vim.yaml

echo ""
echo "✅ Vim Flatpak built!"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "  Building Extensions (LSP & Tree-sitter)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Build Python LSP extension
flatpak-builder --force-clean --repo=repo build-ext-pylsp extensions/org.neovim.Neovim.LSP.Python.yaml

# Build Tree-sitter Python extension
flatpak-builder --force-clean --repo=repo build-ext-ts-python extensions/org.neovim.Neovim.TreeSitter.Python.yaml

echo ""
echo "✅ Extensions built!"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "  Installation"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "Install locally:"
echo "  flatpak --user remote-add --no-gpg-verify vim-ai-repo repo"
echo "  flatpak --user install vim-ai-repo org.neovim.Neovim"
echo "  flatpak --user install vim-ai-repo org.vim.Vim"
echo ""
echo "Install extensions:"
echo "  flatpak --user install vim-ai-repo org.neovim.Neovim.LSP.Python"
echo "  flatpak --user install vim-ai-repo org.neovim.Neovim.TreeSitter.Python"
echo ""
echo "Run:"
echo "  flatpak run org.neovim.Neovim"
echo "  flatpak run org.vim.Vim"
echo ""
echo "Flatpaks built successfully! 📦"
echo ""
