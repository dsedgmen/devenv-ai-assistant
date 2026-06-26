#!/bin/bash
# Build Vim Container

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  Building Vim Container"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Get host UID/GID
USER_UID=$(id -u)
USER_GID=$(id -g)
USERNAME=$(whoami)

# Prepare build context
echo "Preparing build context..."
cp ~/.vimrc vimrc
cp ~/.local/bin/vim-ai-helper .

# Build container
echo "Building container image..."
podman build \
    --build-arg USER_UID=${USER_UID} \
    --build-arg USER_GID=${USER_GID} \
    --build-arg USERNAME=${USERNAME} \
    -t vim-ai:latest \
    -f Containerfile \
    .

# Cleanup
rm -f vimrc vim-ai-helper

echo ""
echo "✅ Vim container built successfully!"
echo ""
echo "Test it:"
echo "  podman run --rm -it vim-ai:latest"
echo ""
echo "Use it:"
echo "  podman run --rm -it -v \$(pwd):/workspace:z vim-ai:latest myfile.py"
echo ""
