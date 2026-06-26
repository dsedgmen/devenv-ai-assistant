# Containers & Flatpak Guide

Complete guide to containerized and Flatpak distributions of Vim AI Assistant.

## Overview

Three deployment options:
1. **Native** - Install directly on host (fastest)
2. **Containers** - Podman/Docker images (portable, isolated)
3. **Flatpak** - Cross-distro packages (sandboxed, modular)

---

## Option 1: Containerized LSP Servers

Run LSP servers in isolation while using native vim/neovim.

### Build

```bash
cd ~/vim-ai-assistant/containers/lsp-servers
./build.sh
```

### Use

```bash
# Export to use containerized LSP
export VIM_LSP_MODE=container

nvim test.py  # LSP runs in container
```

**Benefits:**
- ✅ LSP isolated from host
- ✅ Can't modify system files
- ✅ Easy version switching
- ✅ Native editor speed

**Docs:** `containers/lsp-servers/README.md`

---

## Option 2: Containerized Vim/Neovim

Complete editor environment in containers.

### Build

```bash
cd ~/vim-ai-assistant/containers

# Build both
./vim/build.sh
./neovim/build.sh
```

### Use

```bash
# Via wrapper scripts
./vim/vim-container.sh test.py
./neovim/nvim-container.sh test.py

# Or directly
podman run --rm -it -v $(pwd):/workspace:z vim-ai:latest test.py
podman run --rm -it -v $(pwd):/workspace:z neovim-ai:latest test.py
```

**What's Included:**
- Complete editor (vim or neovim)
- All configs and plugins
- AI assistant
- LSP servers
- Tree-sitter (neovim)
- Git integration

**Benefits:**
- ✅ Portable (same env everywhere)
- ✅ Reproducible builds
- ✅ Isolated from host
- ✅ Easy to share

**Docs:** `containers/README.md`

---

## Option 3: Flatpak Packages

Cross-distribution packages with modular extensions.

### Build

```bash
cd ~/vim-ai-assistant/flatpak
./build-flatpak.sh
```

### Install

```bash
# Add local repo
flatpak --user remote-add --no-gpg-verify vim-ai-repo repo

# Install apps
flatpak install vim-ai-repo org.neovim.Neovim
flatpak install vim-ai-repo org.vim.Vim

# Install extensions (optional)
flatpak install vim-ai-repo org.neovim.Neovim.LSP.Python
flatpak install vim-ai-repo org.neovim.Neovim.TreeSitter.Python
```

### Use

```bash
flatpak run org.neovim.Neovim test.py
flatpak run org.vim.Vim test.py
```

**Architecture:**

```
Base App: org.neovim.Neovim (~400MB)
  └─ Extensions (install as needed):
      ├─ LSP.Python (~100MB)
      ├─ LSP.Go (~50MB)
      ├─ TreeSitter.Python (~5MB)
      └─ TreeSitter.JavaScript (~5MB)
```

**Benefits:**
- ✅ Cross-distro (works on Ubuntu, Arch, etc.)
- ✅ Sandboxed (Flatpak security)
- ✅ Modular (add languages as needed)
- ✅ Auto-updates via Flathub
- ✅ Desktop integration

**Docs:** `flatpak/README.md`

---

## Comparison Matrix

| Feature | Native | LSP Container | Full Container | Flatpak |
|---------|--------|---------------|----------------|---------|
| **Startup** | ⚡ Fast | ⚡ Fast | 🐢 Slow (~1s) | 🚀 Medium (~500ms) |
| **Editor Isolation** | ❌ None | ❌ None | ✅ Full | ✅ Sandboxed |
| **LSP Isolation** | ❌ None | ✅ Full | ✅ Full | ✅ Full |
| **Portability** | ❌ Fedora only | ✅ Any + podman | ✅ Any + podman | ✅ Cross-distro |
| **Size** | 📦 Minimal | 📦 ~600MB | 📦 ~900MB | 📦 ~600MB |
| **Updates** | `dnf update` | Rebuild | Rebuild | `flatpak update` |
| **GUI Apps** | ✅ Native | ✅ Native | ⚠️ Via X11 | ✅ Native |
| **Extensions** | ❌ N/A | ❌ N/A | ❌ N/A | ✅ Modular |
| **Distribution** | Host-only | Need podman | Need podman | Single .flatpak |

---

## Use Cases

### Development Machine (Laptop)
**Recommendation:** Native

```bash
# Fastest startup, full features
nvim test.py
```

**Why:**
- Best performance
- Battery friendly
- Direct system integration
- No overhead

---

### Shared Server (Multi-user)
**Recommendation:** LSP Container or Full Container

```bash
# Isolated per-user environments
export VIM_LSP_MODE=container
nvim test.py

# Or full isolation
./neovim/nvim-container.sh test.py
```

**Why:**
- User isolation
- Can't interfere with others
- Security boundaries
- Resource limits possible

---

### CI/CD Pipeline
**Recommendation:** Full Container

```bash
# Reproducible test environment
podman run --rm -v $(pwd):/workspace:z \
    neovim-ai:latest +checkhealth +qall
```

**Why:**
- Reproducible builds
- Same env across pipeline
- Easy to version
- Disposable

---

### End-user Distribution
**Recommendation:** Flatpak

```bash
# User installs from Flathub
flatpak install flathub org.neovim.Neovim

# Runs sandboxed
flatpak run org.neovim.Neovim
```

**Why:**
- Cross-distro compatible
- User-friendly (app store)
- Auto-updates
- Sandboxed security
- Modular extensions

---

### Untrusted Code
**Recommendation:** Flatpak (strictest) or Full Container

```bash
# Maximum isolation
flatpak run --unshare=network \
    --filesystem=$(pwd):ro \
    org.neovim.Neovim untrusted.py
```

**Why:**
- Sandboxed
- Limited permissions
- Read-only possible
- Network can be disabled

---

### Teaching/Workshops
**Recommendation:** Flatpak

```bash
# Everyone installs same version
flatpak install vim-ai-bundle.flatpak

# Identical environment for all students
flatpak run org.neovim.Neovim
```

**Why:**
- Single file distribution
- Works on all distros
- No "works on my machine"
- Easy setup for students

---

## Quick Start Guide

### I Want: Fastest Performance
```bash
# Use native
./install.sh
nvim test.py
```

### I Want: Portable Environment
```bash
# Use containers
cd containers/neovim
./build.sh
./nvim-container.sh test.py
```

### I Want: Share with Others
```bash
# Use Flatpak
cd flatpak
./build-flatpak.sh
flatpak build-bundle repo neovim-ai.flatpak org.neovim.Neovim
# Share neovim-ai.flatpak
```

### I Want: Secure Isolation
```bash
# Use Flatpak with restrictions
flatpak run --unshare=network \
    --nofilesystem=host \
    --filesystem=$(pwd):ro \
    org.neovim.Neovim
```

### I Want: LSP Only Isolated
```bash
# Use LSP containers with native editor
cd containers/lsp-servers
./build.sh
export VIM_LSP_MODE=container
nvim test.py
```

---

## Migration Path

### From Native → LSP Container

```bash
# 1. Build LSP container
cd ~/vim-ai-assistant/containers/lsp-servers
./build.sh

# 2. Switch mode
export VIM_LSP_MODE=container

# 3. Test
nvim test.py
# LSP now runs in container, editor native

# 4. Make permanent
echo 'export VIM_LSP_MODE=container' >> ~/.bashrc
```

### From Native → Full Container

```bash
# 1. Build editor container
cd ~/vim-ai-assistant/containers/neovim
./build.sh

# 2. Create alias
echo 'alias nvim="~/vim-ai-assistant/containers/neovim/nvim-container.sh"' >> ~/.bashrc

# 3. Use normally
nvim test.py  # Now runs in container
```

### From Container → Flatpak

```bash
# 1. Build Flatpak
cd ~/vim-ai-assistant/flatpak
./build-flatpak.sh

# 2. Install
flatpak --user remote-add --no-gpg-verify vim-ai-repo repo
flatpak install vim-ai-repo org.neovim.Neovim

# 3. Use
flatpak run org.neovim.Neovim

# 4. Remove containers (optional)
podman rmi neovim-ai:latest
```

---

## All From Fedora Repos

All three options maintain the "repos only" constraint:

**Containers:**
```dockerfile
FROM registry.fedoraproject.org/fedora:44
RUN dnf install -y neovim python3-lsp-server ...
```

**Flatpak:**
```yaml
# Build from Fedora source RPMs
sources:
  - type: archive
    url: https://src.fedoraproject.org/rpms/neovim/...
```

No pip, npm, cargo, or external binaries! ✅

---

## Directory Structure

```
vim-ai-assistant/
├── containers/
│   ├── lsp-servers/       # Containerized LSP only
│   │   ├── Containerfile
│   │   ├── build.sh
│   │   ├── lsp-wrapper.sh
│   │   └── README.md
│   ├── vim/               # Containerized vim
│   │   ├── Containerfile
│   │   ├── build.sh
│   │   ├── vim-container.sh
│   │   └── README.md
│   ├── neovim/            # Containerized neovim
│   │   ├── Containerfile
│   │   ├── build.sh
│   │   ├── nvim-container.sh
│   │   └── README.md
│   └── README.md          # Containers overview
├── flatpak/
│   ├── org.vim.Vim.yaml
│   ├── org.neovim.Neovim.yaml
│   ├── extensions/
│   │   ├── org.neovim.Neovim.LSP.Python.yaml
│   │   ├── org.neovim.Neovim.TreeSitter.Python.yaml
│   │   └── ... (more extensions)
│   ├── build-flatpak.sh
│   └── README.md          # Flatpak overview
└── CONTAINERS_FLATPAK.md  # This file
```

---

## Summary

| Goal | Use | Command |
|------|-----|---------|
| **Best Performance** | Native | `nvim` |
| **Portable** | Container | `nvim-container.sh` |
| **Share/Distribute** | Flatpak | `flatpak run org.neovim.Neovim` |
| **Secure/Isolated** | Flatpak (strict) | `flatpak run --unshare=...` |
| **LSP Only Isolated** | LSP Container | `export VIM_LSP_MODE=container` |
| **CI/CD** | Container | `podman run neovim-ai:latest` |
| **Cross-distro** | Flatpak | Works on any Linux |

All options maintain security constraint (Fedora repos only)! 🚀🐳📦
