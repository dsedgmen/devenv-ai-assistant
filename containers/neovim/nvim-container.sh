#!/bin/bash
# Neovim Container Wrapper
# Makes containerized neovim feel like native neovim

# Pass through API keys if set
ENV_ARGS=""
if [ -n "$ANTHROPIC_API_KEY" ]; then
    ENV_ARGS="$ENV_ARGS -e ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY"
fi
if [ -n "$GEMINI_API_KEY" ]; then
    ENV_ARGS="$ENV_ARGS -e GEMINI_API_KEY=$GEMINI_API_KEY"
fi
if [ -n "$VIM_AI_BACKEND" ]; then
    ENV_ARGS="$ENV_ARGS -e VIM_AI_BACKEND=$VIM_AI_BACKEND"
fi

# Run neovim in container
exec podman run --rm -it \
    --userns=keep-id \
    --security-opt label=disable \
    -v "$(pwd):/workspace:z" \
    -v "$HOME/.gitconfig:/home/$(whoami)/.gitconfig:ro" \
    --network=host \
    $ENV_ARGS \
    neovim-ai:latest \
    "$@"
