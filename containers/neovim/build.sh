#!/bin/bash
# Build Neovim Container

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Building Neovim Container"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Get host UID/GID
USER_UID=$(id -u)
USER_GID=$(id -g)
USERNAME=$(whoami)

# Prepare build context
echo "Preparing build context..."
mkdir -p config
cp -r ~/.config/nvim config/
cp ~/.local/bin/vim-ai-helper .

# Build container
echo "Building container image..."
podman build \
    --build-arg USER_UID=${USER_UID} \
    --build-arg USER_GID=${USER_GID} \
    --build-arg USERNAME=${USERNAME} \
    -t neovim-ai:latest \
    -f Containerfile \
    .

# Cleanup
rm -rf config vim-ai-helper

echo ""
echo "✅ Neovim container built successfully!"
echo ""
echo "Test it:"
echo "  podman run --rm -it neovim-ai:latest"
echo ""
echo "Use it:"
echo "  podman run --rm -it -v \$(pwd):/workspace:z neovim-ai:latest myfile.py"
echo ""
