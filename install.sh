#!/usr/bin/env bash
# Installation script for Vim/Neovim AI assistant editor configs.
# Requires devenv-ai-helper from PATH, RPM, DEVENV_AI_HELPER_DIR / VIM_AI_HELPER_DIR,
# or sibling ../devenv-ai-helper (fallback ../vim-ai-helper).

set -euo pipefail

echo "================================================"
echo "Installing devenv-ai-assistant"
echo "================================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

resolve_helper() {
    local dir="${DEVENV_AI_HELPER_DIR:-${VIM_AI_HELPER_DIR:-}}"
    local helper=""

    if [ -n "$dir" ]; then
        if [ -f "$dir/devenv-ai-helper" ]; then
            helper="$(cd "$dir" && pwd)/devenv-ai-helper"
        elif [ -f "$dir/vim-ai-helper" ]; then
            helper="$(cd "$dir" && pwd)/vim-ai-helper"
        elif [ -f "$dir" ]; then
            helper="$dir"
        fi
    fi

    if [ -z "$helper" ]; then
        for candidate in \
            "$SCRIPT_DIR/../devenv-ai-helper/devenv-ai-helper" \
            "$SCRIPT_DIR/../vim-ai-helper/devenv-ai-helper" \
            "$SCRIPT_DIR/../vim-ai-helper/vim-ai-helper" \
            "$HOME/devenv-ai-helper/devenv-ai-helper" \
            "$HOME/vim-ai-helper/vim-ai-helper"; do
            if [ -f "$candidate" ]; then
                helper="$(cd "$(dirname "$candidate")" && pwd)/$(basename "$candidate")"
                break
            fi
        done
    fi

    if [ -z "$helper" ] && command -v devenv-ai-helper >/dev/null 2>&1; then
        helper="$(command -v devenv-ai-helper)"
    fi
    if [ -z "$helper" ] && command -v vim-ai-helper >/dev/null 2>&1; then
        helper="$(command -v vim-ai-helper)"
    fi

    if [ -z "$helper" ] || [ ! -f "$helper" ]; then
        echo "Error: devenv-ai-helper not found."
        echo "  Install the Fedora RPM, or"
        echo "  clone https://github.com/dsedgmen/devenv-ai-helper as a sibling, or"
        echo "  set DEVENV_AI_HELPER_DIR to the helper repo (or binary path)."
        exit 1
    fi
    echo "$helper"
}

HELPER_SRC="$(resolve_helper)"

echo "Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.config/nvim/lua

if command -v rpm >/dev/null 2>&1 && rpm -q devenv-ai-helper >/dev/null 2>&1; then
    echo "devenv-ai-helper RPM already installed ($(command -v devenv-ai-helper)); skipping ~/.local/bin copy"
elif command -v rpm >/dev/null 2>&1 && rpm -q vim-ai-helper >/dev/null 2>&1; then
    echo "vim-ai-helper RPM already installed ($(command -v vim-ai-helper)); skipping ~/.local/bin copy"
elif [ -x /usr/bin/devenv-ai-helper ]; then
    echo "Using system /usr/bin/devenv-ai-helper"
elif [ -x /usr/bin/vim-ai-helper ]; then
    echo "Using system /usr/bin/vim-ai-helper"
elif [ "$(command -v devenv-ai-helper 2>/dev/null || true)" = "$HELPER_SRC" ] && [ -x "$HELPER_SRC" ]; then
    echo "Using PATH devenv-ai-helper at $HELPER_SRC"
elif [ "$(command -v vim-ai-helper 2>/dev/null || true)" = "$HELPER_SRC" ] && [ -x "$HELPER_SRC" ]; then
    echo "Using PATH vim-ai-helper at $HELPER_SRC"
else
    echo "Installing devenv-ai-helper to ~/.local/bin/ (from $HELPER_SRC)"
    cp "$HELPER_SRC" ~/.local/bin/devenv-ai-helper
    chmod +x ~/.local/bin/devenv-ai-helper
    ln -sfn ~/.local/bin/devenv-ai-helper ~/.local/bin/vim-ai-helper
fi

if [ -f ~/.config/nvim/init.lua ]; then
    echo "Backing up existing ~/.config/nvim/init.lua to ~/.config/nvim/init.lua.backup"
    cp ~/.config/nvim/init.lua ~/.config/nvim/init.lua.backup
fi
echo "Installing neovim config to ~/.config/nvim/init.lua"
cp "$SCRIPT_DIR/nvim-init.lua" ~/.config/nvim/init.lua

if [ -f ~/.vimrc ]; then
    echo "Backing up existing ~/.vimrc to ~/.vimrc.backup"
    cp ~/.vimrc ~/.vimrc.backup
fi
echo "Installing vim config to ~/.vimrc"
cp "$SCRIPT_DIR/vimrc" ~/.vimrc

echo "Copying documentation to ~/.config/"
cp "$SCRIPT_DIR/README.md" ~/.config/devenv-ai-README.md
cp "$SCRIPT_DIR/QUICKREF.txt" ~/.config/devenv-ai-quickref.txt
cp "$SCRIPT_DIR/devenv-ai-setup.sh" ~/.config/devenv-ai-setup.sh
chmod +x ~/.config/devenv-ai-setup.sh

echo ""
echo "Installed:"
echo "  - devenv-ai-helper (PATH or ~/.local/bin)"
echo "  - ~/.config/nvim/init.lua"
echo "  - ~/.vimrc"
echo "  - ~/.config/devenv-ai-{README.md,quickref.txt,setup.sh}"
echo ""
echo "Next:"
echo "  ~/.config/devenv-ai-setup.sh"
echo "  LSP/plugins: https://github.com/dsedgmen/devenv-lsp-setup"
echo ""
