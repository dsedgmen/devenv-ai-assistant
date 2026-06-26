#!/bin/bash
# Install useful Vim plugins from Fedora repos
# All plugins are optional but highly recommended for productivity

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Installing Vim Plugins from Fedora Repos"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Essential plugins
echo "Step 1: Installing ESSENTIAL plugins..."
echo ""
sudo dnf install -y \
    vim-fugitive \
    vim-gitgutter \
    vim-nerdtree \
    vim-ctrlp \
    vim-commentary

echo ""
echo "✅ Essential plugins installed!"
echo ""

# Optional plugins
echo "Step 2: Installing OPTIONAL plugins (git integration + status bar)..."
echo ""
sudo dnf install -y \
    vim-rhubarb \
    vim-trailing-whitespace \
    vim-powerline

echo ""
echo "✅ Optional plugins installed!"
echo ""

# Step 3: Configure plugins in .vimrc
echo "Step 3: Adding plugin configuration to ~/.vimrc..."
echo ""

# Backup existing .vimrc
if [ -f ~/.vimrc ]; then
    cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "  Backed up existing ~/.vimrc"
fi

# Add plugin configuration section if not already present
if ! grep -q "Plugin Configuration" ~/.vimrc 2>/dev/null; then
    cat >> ~/.vimrc << 'EOF'

" ═══════════════════════════════════════════════════════════
" Plugin Configuration
" ═══════════════════════════════════════════════════════════

" NERDTree - File Explorer
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.pyc$', '\~$', '\.swp$', '\.git$']

" CtrlP - Fuzzy File Finder
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|node_modules|__pycache__)$',
  \ 'file': '\v\.(exe|so|dll|pyc)$',
  \ }

" GitGutter - Show git changes in gutter
let g:gitgutter_enabled = 1
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
nmap <leader>hp <Plug>(GitGutterPreviewHunk)
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)

" Fugitive - Git commands in vim
nnoremap <leader>gs :Git status<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git log<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gd :Git diff<CR>

" Commentary - Quick commenting
" Use: gcc (comment line), gc in visual mode (comment selection)
" Works automatically for all file types

" Trailing Whitespace - Highlight it
" Use: :FixWhitespace to remove all trailing whitespace
autocmd BufWritePre * :FixWhitespace

" Powerline - Enhanced status bar
set laststatus=2
let g:Powerline_symbols = 'unicode'

EOF
    echo "  ✅ Added plugin configuration to ~/.vimrc"
else
    echo "  Plugin configuration already exists in ~/.vimrc"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Installed Plugins:"
echo ""
echo "ESSENTIAL:"
echo "  ✅ vim-fugitive       - Git integration"
echo "  ✅ vim-gitgutter      - Git diff in gutter"
echo "  ✅ vim-nerdtree       - File explorer"
echo "  ✅ vim-ctrlp          - Fuzzy file finder"
echo "  ✅ vim-commentary     - Quick commenting"
echo ""
echo "OPTIONAL:"
echo "  ✅ vim-rhubarb        - GitHub integration"
echo "  ✅ vim-trailing-whitespace - Highlight trailing spaces"
echo "  ✅ vim-powerline      - Enhanced status bar"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Quick Reference"
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
echo "Git Gutter (changed lines):"
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
echo "Whitespace:"
echo "  :FixWhitespace - Remove trailing whitespace"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Test It Now!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Try these commands:"
echo ""
echo "  vim ~/vim-ai-assistant"
echo "  (Press Ctrl-P and type 'install' → fuzzy finds files)"
echo "  (Press Ctrl-N → opens file tree)"
echo "  (Press <Space>gs → git status)"
echo ""
echo "Your vim is now supercharged! 🚀"
echo ""
