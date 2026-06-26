#!/bin/bash
# Build LSP Servers Container

set -e

echo "Building LSP Servers Container..."
echo ""

# Get host UID/GID to match permissions
USER_UID=$(id -u)
USER_GID=$(id -g)

# Build container
podman build \
    --build-arg USER_UID=${USER_UID} \
    --build-arg USER_GID=${USER_GID} \
    -t lsp-servers:latest \
    -f Containerfile \
    .

echo ""
echo "✅ LSP Servers container built!"
echo ""
echo "Test it:"
echo "  podman run --rm lsp-servers:latest python"
echo "  podman run --rm lsp-servers:latest go"
echo "  podman run --rm lsp-servers:latest bash"
echo "  podman run --rm lsp-servers:latest rust"
echo ""
