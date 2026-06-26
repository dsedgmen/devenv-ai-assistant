# Containerized Vim and Neovim

Complete vim/neovim environments in containers with all features.

## What's Included

Each container has:
- ✅ Full editor (vim or neovim)
- ✅ AI assistant (Ollama/Claude/Gemini support)
- ✅ LSP servers (Python, Go, Bash, Rust)
- ✅ Tree-sitter (neovim only - 15+ languages)
- ✅ Git integration (fugitive, gitgutter)
- ✅ File navigation (NERDTree, CtrlP)
- ✅ All plugins configured
- ✅ All from Fedora repos

## Directory Structure

```
containers/
├── lsp-servers/        # Containerized LSP servers only
│   ├── Containerfile
│   ├── build.sh
│   └── lsp-wrapper.sh
├── vim/                # Containerized vim
│   ├── Containerfile
│   ├── build.sh
│   └── vim-container.sh
└── neovim/             # Containerized neovim
    ├── Containerfile
    ├── build.sh
    └── nvim-container.sh
```

## Build Containers

```bash
cd ~/vim-ai-assistant/containers

# Build all three
./lsp-servers/build.sh    # LSP servers only
./vim/build.sh            # Vim with everything
./neovim/build.sh         # Neovim with everything
```

## Usage

### Option 1: Quick Test

```bash
# Run neovim container
podman run --rm -it -v $(pwd):/workspace:z neovim-ai:latest test.py

# Run vim container
podman run --rm -it -v $(pwd):/workspace:z vim-ai:latest test.py
```

### Option 2: Use Wrapper Scripts (Recommended)

```bash
# Install wrappers
sudo cp containers/neovim/nvim-container.sh /usr/local/bin/nvim-container
sudo cp containers/vim/vim-container.sh /usr/local/bin/vim-container

# Use like native vim/neovim
nvim-container test.py
vim-container test.py
```

### Option 3: Alias to Replace Native

```bash
# Add to ~/.bashrc
alias nvim='~/vim-ai-assistant/containers/neovim/nvim-container.sh'
alias vim='~/vim-ai-assistant/containers/vim/vim-container.sh'

# Now these use containers:
nvim test.py
vim test.py
```

## Features

All features work in containers:

### AI Assistant
```bash
# Set backend before starting
export VIM_AI_BACKEND=claude
export ANTHROPIC_API_KEY=sk-ant-...

nvim-container test.py
# Inside: <Space>ac for completion, <Space>aq for chat
```

### LSP
```vim
" Works automatically
gd        " Go to definition
K         " Hover documentation
gr        " Find references
```

### Git Integration
```vim
" Fugitive commands work
<Space>gs    " Git status
<Space>gc    " Git commit
<Space>gp    " Git push

" GitGutter shows changes
]c / [c      " Navigate changes
```

### File Navigation
```vim
Ctrl-P       " Fuzzy finder
Ctrl-N       " File tree
```

## Why Use Containers?

### Portability
- Same environment on any machine
- Includes all dependencies
- Version locked (Fedora 44)

### Isolation
- Can't modify host system
- Limited filesystem access
- Secure for untrusted code

### Reproducibility
- Same setup for whole team
- Easy to share
- No "works on my machine"

### Easy Distribution
- Single container = complete setup
- No installation steps
- Works anywhere with podman

## Environment Variables

Containers support:

```bash
# AI backends
export VIM_AI_BACKEND=ollama|claude|gemini
export ANTHROPIC_API_KEY=sk-ant-...
export GEMINI_API_KEY=...
export VIM_AI_OLLAMA_MODEL=granite-code:latest
export VIM_AI_GEMINI_MODEL=gemini-2.0-flash-exp

# LSP mode
export VIM_LSP_MODE=host|container
```

## Volumes Mounted

Containers automatically mount:

```bash
-v $(pwd):/workspace:z              # Current directory (read/write)
-v $HOME/.gitconfig:...gitconfig:ro # Git config (read-only)
```

Add more mounts:
```bash
podman run --rm -it \
    -v $(pwd):/workspace:z \
    -v $HOME/.ssh:/home/$(whoami)/.ssh:ro \
    neovim-ai:latest
```

## Network Access

Containers have `--network=host` for:
- Ollama (localhost:11434)
- Claude API (api.anthropic.com)
- Gemini API (generativelanguage.googleapis.com)

Disable network:
```bash
podman run --rm -it \
    --network=none \
    -v $(pwd):/workspace:z \
    vim-ai:latest test.py
```

(AI won't work without network)

## Size

Container sizes:
```
lsp-servers:latest   ~600 MB   (LSP servers only)
vim-ai:latest        ~800 MB   (Vim + LSP + plugins)
neovim-ai:latest     ~900 MB   (Neovim + LSP + tree-sitter + plugins)
```

## Customization

### Add More Plugins

Edit `Containerfile`:
```dockerfile
RUN dnf install -y \
    vim-fugitive \
    vim-gitgutter \
    vim-your-plugin \  # Add here
    && dnf clean all
```

Rebuild:
```bash
./build.sh
```

### Change Base Image

```dockerfile
FROM registry.fedoraproject.org/fedora:43  # Different version
FROM registry.access.redhat.com/ubi9/ubi   # RHEL-based
```

### Add Custom Scripts

```dockerfile
COPY my-script.sh /home/${USERNAME}/.local/bin/
RUN chmod +x /home/${USERNAME}/.local/bin/my-script.sh
```

## Comparison

| Feature | Native | Container |
|---------|--------|-----------|
| **Startup** | Fast | Slower (~1s) |
| **Portability** | Host-dependent | Portable |
| **Security** | User-level | Isolated |
| **Updates** | `dnf update` | Rebuild |
| **Size** | Minimal | ~900 MB |
| **Network** | Full access | Controlled |
| **Features** | All | All |

## Use Cases

### Development Machine
```bash
# Use native (faster startup)
nvim test.py
```

### Shared Server
```bash
# Use container (isolation)
nvim-container test.py
```

### CI/CD
```bash
# Reproducible environment
podman run --rm -v $(pwd):/workspace:z neovim-ai:latest +checkhealth
```

### Teaching/Demos
```bash
# Same setup for everyone
podman pull your-registry/neovim-ai:latest
nvim-container examples/demo.py
```

### Untrusted Code
```bash
# Isolated from host
podman run --rm --network=none -v $(pwd):/workspace:z vim-ai:latest untrusted.py
```

## All From Fedora Repos

Containers use **only** Fedora packages:
- ✅ vim-enhanced / neovim
- ✅ vim-ale (LSP for vim)
- ✅ python3-lsp-server, gopls, bash-language-server
- ✅ tree-sitter-* (15+ languages)
- ✅ vim-fugitive, vim-gitgutter, etc.
- ✅ python3-google-genai

No pip, npm, cargo, or external downloads!

Container = Portable + Secure + Reproducible! 🐳
