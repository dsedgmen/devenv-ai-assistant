#!/bin/bash
# Install LSP and Tree-sitter from Fedora repos ONLY

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Installing LSP and Tree-sitter from Fedora Repos"
echo "═══════════════════════════════════════════════════════════"
echo ""

# LSP Servers available in Fedora repos
LSP_SERVERS=(
    "python3-lsp-server"           # Python LSP
    "python3-lsp-ruff"             # Python linter
    "python3-lsp-black"            # Python formatter
    "gopls"                        # Go LSP
    "nodejs-bash-language-server"  # Bash LSP
)

# Tree-sitter core and CLI
TREESITTER_CORE=(
    "libtree-sitter"
    "tree-sitter-cli"
)

# Tree-sitter grammars (system libraries)
TREESITTER_GRAMMARS=(
    "libtree-sitter-python"
    "libtree-sitter-bash"
    "libtree-sitter-c"
    "libtree-sitter-cpp"
    "libtree-sitter-go"
    "libtree-sitter-javascript"
    "libtree-sitter-typescript"
    "libtree-sitter-json"
    "libtree-sitter-yaml"
    "libtree-sitter-html"
    "libtree-sitter-css"
    "libtree-sitter-lua"
    "libtree-sitter-rust"
    "libtree-sitter-java"
    "libtree-sitter-ruby"
)

echo "Step 1: Installing LSP servers..."
echo "-----------------------------------"
for pkg in "${LSP_SERVERS[@]}"; do
    echo "  Installing $pkg..."
done
sudo dnf install -y "${LSP_SERVERS[@]}"

echo ""
echo "Step 2: Installing Tree-sitter core..."
echo "----------------------------------------"
sudo dnf install -y "${TREESITTER_CORE[@]}"

echo ""
echo "Step 3: Installing Tree-sitter grammars..."
echo "-------------------------------------------"
for pkg in "${TREESITTER_GRAMMARS[@]}"; do
    echo "  Installing $pkg..."
done
sudo dnf install -y "${TREESITTER_GRAMMARS[@]}"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "Installed LSP Servers:"
echo "  ✓ python3-lsp-server (Python)"
echo "  ✓ gopls (Go)"
echo "  ✓ bash-language-server (Bash)"
echo ""

echo "Installed Tree-sitter:"
echo "  ✓ Core library: libtree-sitter"
echo "  ✓ CLI tool: tree-sitter"
echo "  ✓ ${#TREESITTER_GRAMMARS[@]} language grammars"
echo ""

echo "Verify installations:"
echo "  pylsp --help"
echo "  gopls version"
echo "  bash-language-server --version"
echo "  tree-sitter --version"
echo ""

echo "Next steps:"
echo "  1. Neovim LSP config will be added to ~/.config/nvim/init.lua"
echo "  2. Tree-sitter will use system libraries"
echo "  3. No external downloads needed!"
echo ""
