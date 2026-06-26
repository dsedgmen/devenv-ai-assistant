#!/bin/bash
# LSP Server Container Entrypoint
# Routes to correct LSP server based on argument

case "$1" in
    python|pylsp)
        exec pylsp
        ;;
    go|gopls)
        exec gopls
        ;;
    bash|bashls)
        exec bash-language-server start
        ;;
    rust|rust-analyzer)
        exec rust-analyzer
        ;;
    *)
        echo "Usage: $0 {python|go|bash|rust}"
        echo "Available LSP servers:"
        echo "  python  - Python Language Server (pylsp)"
        echo "  go      - Go Language Server (gopls)"
        echo "  bash    - Bash Language Server"
        echo "  rust    - Rust Analyzer"
        exit 1
        ;;
esac
