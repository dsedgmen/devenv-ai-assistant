# Vim AI Assistant - Complete Deployment Guide

Choose the deployment option that best fits your use case.

---

## 🚀 Quick Decision Matrix

| I want to... | Use | Command |
|-------------|-----|---------|
| **Fastest setup** | Native | `./install.sh` |
| **Best performance** | Native | `nvim test.py` |
| **Isolated LSP only** | LSP Container | `export VIM_LSP_MODE=container` |
| **Portable environment** | Full Container | `./nvim-container.sh test.py` |
| **Share with team** | Flatpak bundle | `flatpak build-bundle ...` |
| **Maximum security** | Flatpak (strict) | `flatpak run --unshare=network ...` |
| **Works on any distro** | Flatpak | `flatpak install org.neovim.Neovim` |
| **CI/CD testing** | Full Container | `podman run neovim-ai:latest` |

---

## Option 1: Native Installation ⚡

**Best for:** Development machines, laptops, best performance

### Install

```bash
cd ~/vim-ai-assistant
./install.sh                    # Base vim/neovim + AI
./install-lsp-treesitter.sh     # LSP + tree-sitter
./install-vim-plugins.sh        # Productivity plugins
./install-treesitter-languages.sh # Extra languages
```

### Features

✅ **Complete IDE:**
- AI (Ollama/Claude/Gemini)
- LSP (Python, Go, Bash, Rust)
- Tree-sitter (23 languages)
- Git integration (fugitive, gitgutter)
- File navigation (CtrlP, NERDTree)
- All plugins

✅ **Performance:**
- Instant startup (<10ms)
- Native speed
- Battery friendly

✅ **From Fedora Repos:**
- All packages via `dnf`
- No pip/npm/cargo
- Maintains security constraint

### Usage

```bash
# Just use vim/neovim normally
nvim test.py
vim test.py

# All features work immediately
<Space>ac    # AI completion
gd           # Go to definition
Ctrl-P       # Fuzzy file finder
<Space>gs    # Git status
```

### Pros
- ⚡ Fastest startup
- 🔋 Best battery life
- 💾 Smallest disk usage
- 🎯 Direct system integration

### Cons
- 🔒 No isolation
- 📦 Fedora only
- 🚫 Can't easily share exact environment

---

## Option 2: Containerized LSP Servers 🔐

**Best for:** Security-conscious users, shared servers

### Build

```bash
cd ~/vim-ai-assistant/containers/lsp-servers
./build.sh
```

### Configure

```bash
# Enable container mode
export VIM_LSP_MODE=container

# Make permanent
echo 'export VIM_LSP_MODE=container' >> ~/.bashrc
```

### Features

✅ **Hybrid Approach:**
- Native vim/neovim (fast startup)
- Containerized LSP (isolated)
- Best of both worlds

✅ **Security:**
- LSP can't modify system files
- Limited filesystem access
- Sandboxed execution

✅ **Flexibility:**
- Toggle container/host mode
- Test different LSP versions
- Multiple versions simultaneously

### Usage

```bash
# Use exactly like native
nvim test.py

# LSP runs in container transparently
# You won't notice any difference except:
# - First LSP request: ~100ms slower
# - Subsequent: same speed as native
```

### Pros
- ⚡ Fast editor startup (native)
- 🔒 LSP isolated
- 🔄 Easy version switching
- 🎯 Transparent to user

### Cons
- 📦 Requires podman
- 🐢 Slight LSP startup delay (~100ms)
- 💾 ~600MB container image

### Docs
`containers/lsp-servers/README.md`

---

## Option 3: Containerized Vim/Neovim 🐳

**Best for:** CI/CD, reproducible builds, portable environments

### Build

```bash
cd ~/vim-ai-assistant/containers

# Build both
./vim/build.sh
./neovim/build.sh
```

### Features

✅ **Complete Environment:**
- Everything in one container
- All configs included
- AI helper pre-installed
- LSP, plugins, tree-sitter

✅ **Portable:**
- Works anywhere with podman
- Same environment everywhere
- Version locked (Fedora 44)

✅ **Reproducible:**
- Dockerfile = documentation
- Easy to share
- No "works on my machine"

### Usage

```bash
# Via wrapper scripts
./containers/neovim/nvim-container.sh test.py
./containers/vim/vim-container.sh test.py

# Or create aliases
alias nvim='~/vim-ai-assistant/containers/neovim/nvim-container.sh'
alias vim='~/vim-ai-assistant/containers/vim/vim-container.sh'

# Then use normally
nvim test.py
```

### Advanced Usage

```bash
# Pass environment variables
ANTHROPIC_API_KEY=sk-ant-... ./nvim-container.sh test.py

# Mount additional directories
podman run --rm -it \
    -v $(pwd):/workspace:z \
    -v $HOME/.ssh:/home/$(whoami)/.ssh:ro \
    neovim-ai:latest test.py

# Disable network
podman run --rm -it \
    --network=none \
    -v $(pwd):/workspace:z \
    neovim-ai:latest test.py
```

### Pros
- 🌍 Portable (works anywhere)
- 🔒 Full isolation
- 📝 Self-documenting (Dockerfile)
- 🔄 Easy to distribute

### Cons
- 🐢 Slower startup (~1 second)
- 💾 Large images (~900MB)
- 📦 Requires podman/docker

### Docs
`containers/README.md`

---

## Option 4: Flatpak Packages 📦

**Best for:** End-user distribution, cross-distro, sandboxed security

### Build

```bash
cd ~/vim-ai-assistant/flatpak
./build-flatpak.sh
```

### Install

```bash
# Add local repository
flatpak --user remote-add --no-gpg-verify vim-ai-repo repo

# Install base apps
flatpak install vim-ai-repo org.neovim.Neovim
flatpak install vim-ai-repo org.vim.Vim

# Install extensions (optional, modular)
flatpak install vim-ai-repo org.neovim.Neovim.LSP.Python
flatpak install vim-ai-repo org.neovim.Neovim.TreeSitter.Python
flatpak install vim-ai-repo org.neovim.Neovim.LSP.Go
flatpak install vim-ai-repo org.neovim.Neovim.TreeSitter.Go
```

### Features

✅ **Modular Architecture:**
```
Base App (org.neovim.Neovim) ~400MB
  ├─ Editor + configs + AI + plugins
  └─ Extensions (install as needed):
      ├─ LSP.Python (~100MB)
      ├─ LSP.Go (~50MB)
      ├─ LSP.Rust (~80MB)
      ├─ TreeSitter.Python (~5MB)
      ├─ TreeSitter.JavaScript (~5MB)
      └─ TreeSitter.Rust (~5MB)
```

Only install languages you actually use!

✅ **Cross-Distribution:**
- Works on Fedora, Ubuntu, Arch, Debian, etc.
- Same package for all distros
- No distro-specific builds needed

✅ **Sandboxed:**
- Flatpak security model
- Limited permissions by default
- Can restrict further

✅ **Desktop Integration:**
- Appears in application menu
- File associations work
- MIME type handling

### Usage

```bash
# Run directly
flatpak run org.neovim.Neovim test.py
flatpak run org.vim.Vim test.py

# With environment variables
flatpak run --env=VIM_AI_BACKEND=claude \
            --env=ANTHROPIC_API_KEY=sk-ant-... \
            org.neovim.Neovim test.py

# Restrict permissions (maximum security)
flatpak run --unshare=network \
            --nofilesystem=host \
            --filesystem=$(pwd):ro \
            org.neovim.Neovim untrusted.py
```

### Distribution

```bash
# Create single-file bundle
flatpak build-bundle repo neovim-ai.flatpak org.neovim.Neovim

# Share neovim-ai.flatpak file
# Others install:
flatpak install neovim-ai.flatpak
```

### Pros
- 🌍 Cross-distro (Ubuntu, Arch, etc.)
- 🔒 Sandboxed by default
- 🧩 Modular (add languages as needed)
- 📦 Single file distribution
- 🔄 Auto-updates (via Flathub)
- 🖥️ Desktop integration

### Cons
- 🐢 Slower startup (~500ms)
- 💾 Larger than native (~600MB+)
- 🔧 Flatpak runtime required

### Docs
`flatpak/README.md`

---

## Comparison Table

| Feature | Native | LSP Container | Full Container | Flatpak |
|---------|:------:|:-------------:|:--------------:|:-------:|
| **Startup Speed** | ⚡⚡⚡ | ⚡⚡⚡ | 🐢 (~1s) | ⚡⚡ (~500ms) |
| **Editor Isolation** | ❌ | ❌ | ✅ | ✅ |
| **LSP Isolation** | ❌ | ✅ | ✅ | ✅ |
| **Disk Usage** | 📦 ~100MB | 📦 ~700MB | 📦 ~1GB | 📦 ~600MB |
| **Portability** | Fedora only | Any+podman | Any+podman | Cross-distro |
| **Updates** | `dnf update` | Rebuild | Rebuild | `flatpak update` |
| **Distribution** | Manual | Docker registry | Docker registry | .flatpak file |
| **Modularity** | ❌ | ❌ | ❌ | ✅ Extensions |
| **GUI Integration** | ✅ Native | ✅ Native | ⚠️ X11 forward | ✅ Native |
| **Battery Impact** | ⚡ None | ⚡ None | 🔋 Slight | 🔋 Slight |

---

## Real-World Use Cases

### Scenario 1: Solo Developer (Laptop)

**Recommendation:** Native

```bash
./install.sh
nvim myproject/
```

**Why:** Fastest, best battery, full features

---

### Scenario 2: Team of 5 Developers (Shared Server)

**Recommendation:** LSP Container or Full Container

```bash
# Each dev gets isolated environment
export VIM_LSP_MODE=container
nvim shared-code/
```

**Why:** Isolation prevents interference, can limit resources

---

### Scenario 3: Open Source Project (Contributors)

**Recommendation:** Flatpak

```bash
# README.md:
# Install editor:
#   flatpak install vim-ai-bundle.flatpak
# 
# Use:
#   flatpak run org.neovim.Neovim
```

**Why:** Works on Ubuntu/Arch/etc., one command setup, everyone has identical environment

---

### Scenario 4: CI/CD Pipeline

**Recommendation:** Full Container

```yaml
# .gitlab-ci.yml
test:
  image: neovim-ai:latest
  script:
    - nvim +checkhealth +qall
    - nvim -c "luafile tests/init_test.lua" +qall
```

**Why:** Reproducible, version locked, disposable

---

### Scenario 5: Security Research (Untrusted Code)

**Recommendation:** Flatpak (strict permissions)

```bash
flatpak run --unshare=network \
            --nofilesystem=host \
            --filesystem=/tmp/untrusted:ro \
            org.neovim.Neovim /tmp/untrusted/malware.py
```

**Why:** Maximum isolation, no network, read-only files

---

### Scenario 6: University Course (200 Students)

**Recommendation:** Flatpak

```bash
# Instructor distributes:
#   course-env.flatpak
# 
# Students install:
flatpak install course-env.flatpak

# Everyone has identical setup
```

**Why:** Works on any Linux distro, no support burden, reproducible

---

## Migration Between Options

### Native → LSP Container

```bash
cd containers/lsp-servers && ./build.sh
export VIM_LSP_MODE=container
# Editor stays native, LSP containerized
```

### Native → Full Container

```bash
cd containers/neovim && ./build.sh
alias nvim='./nvim-container.sh'
# Everything containerized
```

### Container → Flatpak

```bash
cd flatpak && ./build-flatpak.sh
flatpak install vim-ai-repo org.neovim.Neovim
# Now sandboxed + cross-distro
```

### Any → Native

```bash
./install.sh
# Back to maximum performance
```

---

## Summary: Which Should I Use?

### Use **Native** if:
- ✅ You're on Fedora/RHEL
- ✅ You want best performance
- ✅ You trust your code
- ✅ You're the only user

### Use **LSP Container** if:
- ✅ You want LSP isolated
- ✅ But want fast editor startup
- ✅ You're on shared server
- ✅ You need to test different LSP versions

### Use **Full Container** if:
- ✅ You need reproducible builds
- ✅ You're using CI/CD
- ✅ You want portable environment
- ✅ You have podman/docker

### Use **Flatpak** if:
- ✅ You want cross-distro support
- ✅ You're distributing to end-users
- ✅ You want sandboxed security
- ✅ You want modular extensions
- ✅ You need easy distribution (.flatpak file)

---

## All Options Maintain Security Constraint

Every deployment option uses **only Fedora repos sources**:

**Native:**
```bash
sudo dnf install neovim python3-lsp-server ...
```

**Containers:**
```dockerfile
FROM registry.fedoraproject.org/fedora:44
RUN dnf install -y neovim ...
```

**Flatpak:**
```yaml
sources:
  - type: archive
    url: https://src.fedoraproject.org/rpms/neovim/...
```

No pip, npm, cargo, or external downloads! ✅

---

## File Sizes

```
Native:           ~100 MB (packages only)
LSP Container:    ~600 MB (container + packages)
Full Container:   ~900 MB (vim) / ~1 GB (neovim)
Flatpak Base:     ~400 MB
Flatpak + LSPs:   ~600-800 MB (depends on languages)
```

---

## Quick Start Commands

```bash
# Native (fastest)
./install.sh && nvim test.py

# LSP Container (hybrid)
cd containers/lsp-servers && ./build.sh
export VIM_LSP_MODE=container && nvim test.py

# Full Container (portable)
cd containers/neovim && ./build.sh && ./nvim-container.sh test.py

# Flatpak (cross-distro)
cd flatpak && ./build-flatpak.sh
flatpak --user remote-add --no-gpg-verify vim-ai-repo repo
flatpak install vim-ai-repo org.neovim.Neovim
flatpak run org.neovim.Neovim test.py
```

---

**Choose the option that fits your workflow!** 🚀

All documentation:
- `README.md` - Native installation
- `containers/README.md` - Container details
- `flatpak/README.md` - Flatpak details
- `CONTAINERS_FLATPAK.md` - Overview of all options
