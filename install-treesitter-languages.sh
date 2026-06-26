#!/bin/bash
# Add more languages to Tree-sitter (Neovim only)
# All from Fedora repos - no external downloads

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Tree-sitter Language Support Installer"
echo "═══════════════════════════════════════════════════════════"
echo ""

echo "Available tree-sitter parsers in Fedora repos:"
echo ""

# Show what's available
echo "Core Languages (already installed):"
echo "  ✓ Python, Bash, C, C++, Go"
echo "  ✓ JavaScript, TypeScript, JSON, YAML"
echo "  ✓ HTML, CSS, Lua, Rust, Java, Ruby"
echo ""

echo "Additional Languages Available:"
echo "  • C# (tree-sitter-c-sharp)"
echo "  • Elixir (tree-sitter-elixir)"
echo "  • Elixir HEEx templates (tree-sitter-heex)"
echo "  • PHP (tree-sitter-php)"
echo "  • PHP Doc (tree-sitter-phpdoc)"
echo "  • JSDom (tree-sitter-jsdoc)"
echo "  • CMake (tree-sitter-cmake)"
echo "  • TOML (tree-sitter-toml)"
echo ""

# Interactive selection
echo "═══════════════════════════════════════════════════════════"
echo "  Installation Options"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1) Install ALL additional languages"
echo "2) Install specific languages (interactive)"
echo "3) Show currently installed parsers"
echo "4) Exit"
echo ""
read -p "Choose option [1-4]: " choice

case $choice in
    1)
        echo ""
        echo "Installing ALL tree-sitter languages..."
        echo ""
        sudo dnf install -y \
            tree-sitter-bash \
            tree-sitter-c \
            tree-sitter-cmake \
            tree-sitter-cpp \
            tree-sitter-c-sharp \
            tree-sitter-css \
            tree-sitter-elixir \
            tree-sitter-go \
            tree-sitter-heex \
            tree-sitter-html \
            tree-sitter-java \
            tree-sitter-javascript \
            tree-sitter-jsdoc \
            tree-sitter-json \
            tree-sitter-lua \
            tree-sitter-php \
            tree-sitter-phpdoc \
            tree-sitter-python \
            tree-sitter-ruby \
            tree-sitter-rust \
            tree-sitter-toml \
            tree-sitter-typescript \
            tree-sitter-yaml

        INSTALLED_LANGS="bash c cmake cpp c-sharp css elixir heex go html java javascript jsdoc json lua php phpdoc python ruby rust toml typescript yaml"
        ;;

    2)
        echo ""
        echo "Select languages to install (space-separated numbers):"
        echo ""
        echo "1) C#"
        echo "2) Elixir + HEEx"
        echo "3) PHP + PHPDoc"
        echo "4) JSDom"
        echo "5) CMake"
        echo "6) TOML"
        echo ""
        read -p "Enter numbers (e.g., 1 3 5): " selections

        PACKAGES=""
        INSTALLED_LANGS=""

        for num in $selections; do
            case $num in
                1)
                    PACKAGES="$PACKAGES tree-sitter-c-sharp"
                    INSTALLED_LANGS="$INSTALLED_LANGS c-sharp"
                    ;;
                2)
                    PACKAGES="$PACKAGES tree-sitter-elixir tree-sitter-heex"
                    INSTALLED_LANGS="$INSTALLED_LANGS elixir heex"
                    ;;
                3)
                    PACKAGES="$PACKAGES tree-sitter-php tree-sitter-phpdoc"
                    INSTALLED_LANGS="$INSTALLED_LANGS php phpdoc"
                    ;;
                4)
                    PACKAGES="$PACKAGES tree-sitter-jsdoc"
                    INSTALLED_LANGS="$INSTALLED_LANGS jsdoc"
                    ;;
                5)
                    PACKAGES="$PACKAGES tree-sitter-cmake"
                    INSTALLED_LANGS="$INSTALLED_LANGS cmake"
                    ;;
                6)
                    PACKAGES="$PACKAGES tree-sitter-toml"
                    INSTALLED_LANGS="$INSTALLED_LANGS toml"
                    ;;
            esac
        done

        if [ -n "$PACKAGES" ]; then
            echo ""
            echo "Installing: $PACKAGES"
            echo ""
            sudo dnf install -y $PACKAGES
        else
            echo "No packages selected."
            exit 0
        fi
        ;;

    3)
        echo ""
        echo "Currently installed tree-sitter parsers:"
        echo ""
        rpm -qa | grep "^tree-sitter-" | grep -v "cli\|macros" | sort | sed 's/^/  ✓ /'
        echo ""
        exit 0
        ;;

    4)
        echo "Exiting."
        exit 0
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo ""
echo "✅ Tree-sitter parsers installed!"
echo ""

# Update treesitter-config.lua
echo "═══════════════════════════════════════════════════════════"
echo "  Updating Neovim Configuration"
echo "═══════════════════════════════════════════════════════════"
echo ""

TREESITTER_CONFIG="$HOME/.config/nvim/lua/treesitter-config.lua"

# Backup
if [ -f "$TREESITTER_CONFIG" ]; then
    cp "$TREESITTER_CONFIG" "${TREESITTER_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "  Backed up existing config"
fi

# Create updated config
cat > "$TREESITTER_CONFIG" << 'EOF'
-- Tree-sitter Configuration for Neovim
-- Uses ONLY system-installed tree-sitter grammars from Fedora repos

-- Neovim 0.9+ has built-in tree-sitter support
-- We configure it to use system libraries instead of downloading

-- Enable tree-sitter highlighting
vim.treesitter.start()

-- Configure tree-sitter to look for parsers in system paths
local parser_install_dir = "/usr/lib64"

-- Tell neovim where to find the system-installed parsers
vim.opt.runtimepath:append("/usr/share/nvim/site")

-- Language-specific tree-sitter setup
-- This list includes all parsers available from Fedora repos
local treesitter_langs = {
    -- Core languages
    "python",
    "bash",
    "c",
    "cpp",
    "go",
    "javascript",
    "typescript",
    "json",
    "yaml",
    "html",
    "css",
    "lua",
    "rust",
    "java",
    "ruby",

    -- Additional languages (install via tree-sitter-* packages)
    "c_sharp",      -- tree-sitter-c-sharp
    "elixir",       -- tree-sitter-elixir
    "heex",         -- tree-sitter-heex (Elixir templates)
    "php",          -- tree-sitter-php
    "phpdoc",       -- tree-sitter-phpdoc
    "jsdoc",        -- tree-sitter-jsdoc
    "cmake",        -- tree-sitter-cmake
    "toml",         -- tree-sitter-toml
}

-- Auto-enable tree-sitter highlighting for supported languages
for _, lang in ipairs(treesitter_langs) do
    vim.api.nvim_create_autocmd("FileType", {
        pattern = lang,
        callback = function()
            -- Enable tree-sitter for this buffer
            vim.treesitter.start()
        end,
    })
end

-- Tree-sitter based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false  -- Don't fold by default

-- Syntax highlighting with tree-sitter
vim.cmd([[
    if has('nvim-0.9')
        " Use tree-sitter for syntax highlighting
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
    endif
]])

print("Tree-sitter configuration loaded")
print("Supported languages: " .. table.concat(treesitter_langs, ", "))
EOF

echo "  ✅ Updated $TREESITTER_CONFIG"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "  Installation Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Installed tree-sitter parsers for: $INSTALLED_LANGS"
echo ""
echo "All languages now supported in Neovim:"
echo "  Core: Python, Bash, C, C++, Go, JavaScript, TypeScript"
echo "        JSON, YAML, HTML, CSS, Lua, Rust, Java, Ruby"
echo ""

if echo "$INSTALLED_LANGS" | grep -q "c-sharp\|elixir\|php\|cmake\|toml"; then
    echo "  Additional: $INSTALLED_LANGS"
    echo ""
fi

echo "Test it now:"
echo "  nvim test.py        # Python with tree-sitter"
echo "  nvim test.rs        # Rust with tree-sitter"
echo "  nvim test.php       # PHP with tree-sitter (if installed)"
echo ""
echo "Features enabled:"
echo "  ✓ Advanced syntax highlighting"
echo "  ✓ Code folding (za to toggle)"
echo "  ✓ Better text objects"
echo "  ✓ Semantic understanding"
echo ""
echo "View all installed parsers:"
echo "  rpm -qa | grep tree-sitter"
echo ""
echo "Tree-sitter languages expanded! 🌳"
echo ""
