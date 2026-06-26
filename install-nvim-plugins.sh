#!/bin/bash
# Install Neovim plugins from Fedora repos
# Most vim plugins work in neovim too!

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Installing Neovim Plugins from Fedora Repos"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "Good news! Most vim plugins work in neovim natively."
echo ""

# Essential plugins (same as vim)
echo "Step 1: Installing plugins (work in both vim & neovim)..."
echo ""
sudo dnf install -y \
    vim-fugitive \
    vim-gitgutter \
    vim-nerdtree \
    vim-ctrlp \
    vim-commentary \
    vim-rhubarb \
    vim-trailing-whitespace \
    vim-powerline

echo ""
echo "✅ Plugins installed!"
echo ""

# Step 2: Configure for neovim
echo "Step 2: Creating neovim plugin configuration..."
echo ""

# Create lua config file for plugins
cat > ~/.config/nvim/lua/plugins-config.lua << 'EOF'
-- ═══════════════════════════════════════════════════════════
-- Plugin Configuration for Neovim
-- ═══════════════════════════════════════════════════════════
-- Using vim plugins that work in neovim

-- NERDTree - File Explorer
vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>', {desc = 'Toggle NERDTree'})
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeIgnore = {'\\.pyc$', '\\~$', '\\.swp$', '\\.git$'}

-- CtrlP - Fuzzy File Finder
vim.g.ctrlp_map = '<C-p>'
vim.g.ctrlp_cmd = 'CtrlP'
vim.g.ctrlp_show_hidden = 1
vim.g.ctrlp_custom_ignore = {
    dir = '\\v[\\/](\\.(git|hg|svn)|node_modules|__pycache__)$',
    file = '\\v\\.(exe|so|dll|pyc)$',
}

-- GitGutter - Show git changes in gutter
vim.g.gitgutter_enabled = 1
vim.g.gitgutter_sign_added = '+'
vim.g.gitgutter_sign_modified = '~'
vim.g.gitgutter_sign_removed = '-'

-- Git navigation keybindings
vim.keymap.set('n', ']c', '<Plug>(GitGutterNextHunk)', {desc = 'Next git change'})
vim.keymap.set('n', '[c', '<Plug>(GitGutterPrevHunk)', {desc = 'Previous git change'})
vim.keymap.set('n', '<leader>hp', '<Plug>(GitGutterPreviewHunk)', {desc = 'Preview hunk'})
vim.keymap.set('n', '<leader>hs', '<Plug>(GitGutterStageHunk)', {desc = 'Stage hunk'})
vim.keymap.set('n', '<leader>hu', '<Plug>(GitGutterUndoHunk)', {desc = 'Undo hunk'})

-- Fugitive - Git commands in neovim
vim.keymap.set('n', '<leader>gs', ':Git status<CR>', {desc = 'Git status'})
vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', {desc = 'Git commit'})
vim.keymap.set('n', '<leader>gp', ':Git push<CR>', {desc = 'Git push'})
vim.keymap.set('n', '<leader>gl', ':Git log<CR>', {desc = 'Git log'})
vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', {desc = 'Git blame'})
vim.keymap.set('n', '<leader>gd', ':Git diff<CR>', {desc = 'Git diff'})

-- Commentary - Quick commenting
-- Works automatically: gcc (line), gc (visual mode)

-- Trailing Whitespace - Auto-fix on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    command = "FixWhitespace",
})

-- Powerline - Enhanced status bar
vim.opt.laststatus = 2
vim.g.Powerline_symbols = 'unicode'

print("✅ Neovim plugins loaded!")
EOF

echo "  ✅ Created ~/.config/nvim/lua/plugins-config.lua"
echo ""

# Add to init.lua if not already present
if ! grep -q "plugins-config" ~/.config/nvim/init.lua 2>/dev/null; then
    # Find where to insert (before the final print statements)
    echo "  Adding plugin loader to init.lua..."

    # Add at the end but before existing print statements
    sed -i '/^print("✅ AI Coding Assistant loaded!")/i \
-- Load plugin configurations\
require("plugins-config")\
' ~/.config/nvim/init.lua

    echo "  ✅ Updated init.lua"
else
    echo "  plugins-config already loaded in init.lua"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Installed Plugins (work in vim & neovim):"
echo ""
echo "  ✅ vim-fugitive       - Git integration"
echo "  ✅ vim-gitgutter      - Git diff in gutter"
echo "  ✅ vim-nerdtree       - File explorer"
echo "  ✅ vim-ctrlp          - Fuzzy file finder"
echo "  ✅ vim-commentary     - Quick commenting"
echo "  ✅ vim-rhubarb        - GitHub integration"
echo "  ✅ vim-trailing-whitespace - Auto-fix whitespace"
echo "  ✅ vim-powerline      - Enhanced status bar"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Quick Reference (Neovim)"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "File Navigation:"
echo "  Ctrl-N         - Toggle NERDTree file explorer"
echo "  Ctrl-P         - Fuzzy file search"
echo ""
echo "Git Operations:"
echo "  <Space>gs      - Git status"
echo "  <Space>gc      - Git commit"
echo "  <Space>gp      - Git push"
echo "  <Space>gl      - Git log"
echo "  <Space>gb      - Git blame"
echo "  <Space>gd      - Git diff"
echo ""
echo "Git Gutter:"
echo "  ]c             - Next change"
echo "  [c             - Previous change"
echo "  <Space>hp      - Preview hunk"
echo "  <Space>hs      - Stage hunk"
echo "  <Space>hu      - Undo hunk"
echo ""
echo "Code Commenting:"
echo "  gcc            - Comment/uncomment line"
echo "  gc (visual)    - Comment selection"
echo ""
echo "Combined with existing features:"
echo "  ✅ LSP (gd, K, gr)"
echo "  ✅ AI (Ollama/Claude/Gemini)"
echo "  ✅ Tree-sitter syntax"
echo "  ✅ Activity monitoring"
echo "  ✅ Git integration (NEW!)"
echo "  ✅ File navigation (NEW!)"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Test It Now!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "  nvim ~/vim-ai-assistant"
echo "  (Press Ctrl-P and type 'install' → fuzzy finds files)"
echo "  (Press Ctrl-N → opens file tree)"
echo "  (Press <Space>gs → git status)"
echo ""
echo "Neovim is now a complete IDE! 🚀"
echo ""
