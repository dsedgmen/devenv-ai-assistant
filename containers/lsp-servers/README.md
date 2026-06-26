# Containerized LSP Servers

Run LSP servers in isolated containers for security and portability.

## Why Containerized LSP?

**Security:**
- LSP servers run in isolated containers
- Limited access to host filesystem
- Can't modify system files

**Portability:**
- Same LSP environment everywhere
- Version pinned (Fedora 44)
- No conflicts with host packages

**Flexibility:**
- Easy to add/remove languages
- Test different LSP versions
- Multiple versions side-by-side

## Build

```bash
cd ~/vim-ai-assistant/containers/lsp-servers
./build.sh
```

This creates `lsp-servers:latest` container with:
- pylsp (Python)
- gopls (Go)
- bash-language-server
- rust-analyzer

All from Fedora 44 repos.

## Usage

### Test LSP Servers

```bash
# Test Python LSP
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | \
    podman run --rm -i lsp-servers:latest python

# Test Go LSP
podman run --rm -i lsp-servers:latest go

# Test Bash LSP
podman run --rm -i lsp-servers:latest bash

# Test Rust LSP
podman run --rm -i lsp-servers:latest rust
```

### Use with Neovim

**Option 1: Replace lsp-config.lua**

```bash
cd ~/.config/nvim/lua
mv lsp-config.lua lsp-config-host.lua
cp ~/vim-ai-assistant/containers/lsp-servers/neovim-container-lsp.lua lsp-config.lua
```

**Option 2: Toggle between host and container**

Add to `~/.config/nvim/init.lua`:

```lua
-- Set environment variable to choose LSP mode
-- export VIM_LSP_MODE=container   # Use containers
-- export VIM_LSP_MODE=host        # Use host (default)

local lsp_mode = os.getenv("VIM_LSP_MODE") or "host"

if lsp_mode == "container" then
    require("neovim-container-lsp")
else
    require("lsp-config")
end
```

Then switch modes:
```bash
export VIM_LSP_MODE=container
nvim test.py  # Uses containerized LSP

export VIM_LSP_MODE=host
nvim test.py  # Uses host LSP
```

### Use with Vim (ALE)

Add to `~/.vimrc`:

```vim
" Use containerized LSP servers with ALE
let g:ale_linters = {
\   'python': ['pylsp'],
\   'go': ['gopls'],
\   'sh': ['bashls'],
\   'rust': ['analyzer'],
\}

" Point to containerized LSP executables
let g:ale_python_pylsp_executable = expand('~/vim-ai-assistant/containers/lsp-servers/lsp-wrapper.sh')
let g:ale_python_pylsp_options = 'python'

let g:ale_go_gopls_executable = expand('~/vim-ai-assistant/containers/lsp-servers/lsp-wrapper.sh')
let g:ale_go_gopls_options = 'go'

let g:ale_sh_bashls_executable = expand('~/vim-ai-assistant/containers/lsp-servers/lsp-wrapper.sh')
let g:ale_sh_bashls_options = 'bash'
```

## How It Works

```
┌─────────────┐
│  Neovim     │
│  or Vim     │
└──────┬──────┘
       │ stdio
       ▼
┌─────────────────┐
│  lsp-wrapper.sh │  ← Transparent wrapper
└──────┬──────────┘
       │
       ▼
┌───────────────────────┐
│  Podman Container     │
│  ┌─────────────────┐  │
│  │ LSP Server      │  │
│  │ (pylsp/gopls)   │  │
│  └─────────────────┘  │
│  Isolated env         │
│  Limited access       │
└───────────────────────┘
```

## Container Details

**Base Image:** `registry.fedoraproject.org/fedora:44`

**Installed Packages:**
- python3-lsp-server
- gopls
- nodejs-bash-language-server
- rust-analyzer

**User:** Non-root user matching host UID/GID

**Mounts:** Current directory as `/workspace`

**Network:** None (not needed for LSP)

## Security

Containers run with:
- `--userns=keep-id` - User namespace isolation
- `--security-opt label=disable` - SELinux compatibility
- `-v $(pwd):/workspace:z` - Only mount current directory
- No network access
- No privileged capabilities

LSP servers can only:
- Read/write files in current directory
- Cannot modify system files
- Cannot access network
- Cannot install packages

## Performance

**Overhead:**
- Container startup: ~100-200ms (first time)
- Subsequent: ~50ms (cached)
- LSP operations: Same speed as host

**Trade-off:**
- Slightly slower startup
- Better security and isolation

## Troubleshooting

### Container build fails

```bash
# Check podman is installed
podman --version

# Install if missing
sudo dnf install podman
```

### LSP not starting

```bash
# Check container exists
podman images | grep lsp-servers

# Rebuild
cd ~/vim-ai-assistant/containers/lsp-servers
./build.sh

# Test manually
podman run --rm -i lsp-servers:latest python
```

### Permission errors

```bash
# Check wrapper is executable
chmod +x ~/vim-ai-assistant/containers/lsp-servers/lsp-wrapper.sh

# Check SELinux context
ls -Z lsp-wrapper.sh
```

### Slow performance

First run is slower (image pull + start). Subsequent runs are faster.

Consider using host LSP for laptop/battery:
```bash
export VIM_LSP_MODE=host
```

## Customization

### Add More LSP Servers

Edit `Containerfile`:

```dockerfile
RUN dnf install -y \
    python3-lsp-server \
    gopls \
    nodejs-bash-language-server \
    rust-analyzer \
    clangd \              # Add C/C++ LSP
    texlab \              # Add LaTeX LSP
    && dnf clean all
```

Edit `lsp-entrypoint.sh`:

```bash
    c|clangd)
        exec clangd
        ;;
    latex|texlab)
        exec texlab
        ;;
```

Rebuild:
```bash
./build.sh
```

### Different Base Image

Change Fedora version:

```dockerfile
FROM registry.fedoraproject.org/fedora:43
```

Or use different distro (must have repos constraint packages):

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi:latest
```

### Pinned Versions

For reproducible builds, specify versions:

```dockerfile
RUN dnf install -y \
    python3-lsp-server-1.7.4 \
    gopls-0.14.2 \
    && dnf clean all
```

## Comparison

| Feature | Host LSP | Container LSP |
|---------|----------|---------------|
| **Startup** | Fast (~10ms) | Slower (~50-200ms) |
| **Security** | Same as user | Isolated |
| **Portability** | Host-dependent | Portable |
| **Updates** | `dnf update` | Rebuild container |
| **Isolation** | None | Full |
| **Disk Space** | Minimal | ~500MB container |

## When to Use

**Use Containerized LSP when:**
- Security is important (untrusted code)
- Need reproducible environment
- Testing different LSP versions
- Working on shared/multi-user systems

**Use Host LSP when:**
- On laptop (battery life)
- Need fastest startup
- Trust your codebase
- Minimal disk space

## All From Fedora Repos

Container uses **only** Fedora packages:
- ✅ python3-lsp-server
- ✅ gopls
- ✅ nodejs-bash-language-server
- ✅ rust-analyzer

No pip, npm, or external downloads!

Maintains your security constraint even in containers! 🔒
