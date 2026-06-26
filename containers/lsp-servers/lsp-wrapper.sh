#!/bin/bash
# LSP Wrapper Script
# Allows vim/neovim to use containerized LSP servers transparently

LSP_LANG="$1"

# Run LSP server in container with stdio
exec podman run --rm -i \
    --userns=keep-id \
    --security-opt label=disable \
    -v "$(pwd):/workspace:z" \
    lsp-servers:latest \
    "${LSP_LANG}"
