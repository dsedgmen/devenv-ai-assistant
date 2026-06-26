# CI/CD Documentation

Complete CI/CD pipelines for automated building and testing.

## Overview

Automated workflows for:
- ✅ **Container builds** - LSP servers, vim, neovim
- ✅ **Flatpak builds** - Base apps + extensions
- ✅ **Testing** - Linting, syntax checks, build tests
- ✅ **Releases** - Automated release creation
- ✅ **Dependency updates** - Automated via Dependabot

---

## GitHub Actions Workflows

### 1. Build Containers (`.github/workflows/build-containers.yml`)

**Triggers:**
- Push to `main` (when container files change)
- Pull requests
- New releases
- Manual dispatch

**Jobs:**
```
build-lsp-servers  → Test LSP container
build-vim          → Test Vim container  
build-neovim       → Test Neovim container
test-containers    → Integration tests
```

**Container Registry:**
- Published to: `ghcr.io/<username>/vim-ai-assistant/<image>`
- Tags: `main`, `pr-<number>`, `sha-<hash>`, `v<version>`

**Pull Images:**
```bash
# Latest from main
podman pull ghcr.io/dsedgmen/vim-ai-assistant/neovim:main

# Specific version
podman pull ghcr.io/dsedgmen/vim-ai-assistant/neovim:v1.0.0

# Latest stable
podman pull ghcr.io/dsedgmen/vim-ai-assistant/neovim:latest
```

---

### 2. Build Flatpak (`.github/workflows/build-flatpak.yml`)

**Triggers:**
- Push to `main` (when flatpak files change)
- Pull requests
- New releases
- Manual dispatch

**Jobs:**
```
build-neovim-flatpak     → Neovim base app
build-vim-flatpak        → Vim base app
build-extensions         → LSP & tree-sitter extensions
release                  → Upload to GitHub Releases
```

**Artifacts:**
- `neovim-ai.flatpak` - Neovim base app
- `vim-ai.flatpak` - Vim base app
- `python-lsp.flatpak` - Python LSP extension
- `python-treesitter.flatpak` - Python tree-sitter extension

**Download:**
```bash
# From GitHub Releases
wget https://github.com/dsedgmen/vim-ai-assistant/releases/latest/download/neovim-ai.flatpak

# Install
flatpak install neovim-ai.flatpak
```

---

### 3. Test (`.github/workflows/test.yml`)

**Triggers:**
- Every push
- Every pull request
- Manual dispatch

**Jobs:**
```
lint               → ShellCheck + Python syntax
test-installation  → Verify install scripts work
test-configs       → Check Lua/Vim syntax
test-container-builds → Build containers without pushing
```

**Checks:**
- Shell script linting (shellcheck)
- Python syntax validation
- Lua configuration syntax
- Vim configuration syntax
- Container build verification

---

### 4. Release (`.github/workflows/release.yml`)

**Triggers:**
- New GitHub release published
- Manual dispatch with version input

**Jobs:**
```
prepare-release     → Create tarballs, checksums
publish-containers  → Tag and push versioned containers
update-readme       → Update documentation
```

**Release Assets:**
- `vim-ai-assistant-v1.0.0.tar.gz` - Full source
- `vim-ai-assistant-install-v1.0.0.tar.gz` - Installation bundle
- `checksums.txt` - SHA256 checksums
- Container tags: `v1.0.0`, `v1`, `v1.0`, `latest`

---

### 5. Dependabot (`.github/dependabot.yml`)

**Updates:**
- GitHub Actions weekly
- Docker base images weekly

**Auto-creates PRs for:**
- Action version updates
- Base image updates (Fedora 44 → 45, etc.)

---

## GitLab CI Configuration (`.gitlab-ci.yml`)

Alternative CI for GitLab users.

**Stages:**
```
build   → Containers + Flatpaks
test    → Run container tests
release → Tag latest, create releases
```

**Container Registry:**
- Published to: `$CI_REGISTRY_IMAGE/<image>`
- Tags: `$CI_COMMIT_REF_SLUG`, `latest` (on main)

**Flatpak Artifacts:**
- Available for 7 days
- Attached to releases on tags

---

## Triggering Builds

### GitHub Actions

**On Push:**
```bash
git push origin main
# Triggers: build-containers, build-flatpak, test
```

**Manual Dispatch:**
```bash
# Via GitHub UI:
# Actions → Select workflow → Run workflow

# Via GitHub CLI:
gh workflow run build-containers.yml
gh workflow run build-flatpak.yml
```

**On Release:**
```bash
# Create release
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes"

# Automatically triggers:
# - build-containers (with v1.0.0 tag)
# - build-flatpak (uploads to release)
# - release (creates bundles)
```

**On Pull Request:**
```bash
# Create PR
gh pr create --title "Feature" --body "Description"

# Automatically tests:
# - Container builds (no push)
# - Flatpak builds (artifacts only)
# - Linting and syntax checks
```

---

### GitLab CI

**On Push:**
```bash
git push gitlab main
# Triggers all jobs
```

**Manual Pipeline:**
```bash
# Via GitLab UI:
# CI/CD → Pipelines → Run pipeline

# Via GitLab CLI:
glab ci run
```

**On Tag:**
```bash
git tag v1.0.0
git push gitlab v1.0.0
# Triggers release job
```

---

## Environment Variables / Secrets

### GitHub Actions

Required secrets (Settings → Secrets):
```
GITHUB_TOKEN  # Auto-provided
```

Optional secrets:
```
DOCKERHUB_USERNAME  # For Docker Hub publishing
DOCKERHUB_TOKEN
```

### GitLab CI

Built-in variables (auto-provided):
```
CI_REGISTRY          # GitLab Container Registry
CI_REGISTRY_USER     # Auto-auth user
CI_REGISTRY_PASSWORD # Auto-auth token
```

---

## Testing Locally

### Test Container Build

```bash
# GitHub Actions (act)
act -j build-neovim

# Or manually
cd containers/neovim
podman build -t test:local -f Containerfile .
```

### Test Flatpak Build

```bash
# Manual build
cd flatpak
flatpak-builder --force-clean build org.neovim.Neovim.yaml
```

### Test Install Scripts

```bash
# Dry run
bash -n install.sh

# In container
podman run --rm -it -v $(pwd):/workspace registry.fedoraproject.org/fedora:44
cd /workspace
./install.sh
```

---

## CI/CD Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│  Developer pushes code                                   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  GitHub Actions Triggered                                │
│  - test.yml                                              │
│    ├─ Lint shell scripts                                │
│    ├─ Check Python syntax                               │
│    ├─ Validate Lua configs                              │
│    └─ Test container builds                             │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
         ┌───────┴────────┐
         │                │
         ▼                ▼
┌────────────────┐  ┌────────────────┐
│ Container      │  │ Flatpak        │
│ Builds         │  │ Builds         │
├────────────────┤  ├────────────────┤
│ • LSP servers  │  │ • Neovim app   │
│ • Vim          │  │ • Vim app      │
│ • Neovim       │  │ • Extensions   │
└────────┬───────┘  └────────┬───────┘
         │                   │
         ▼                   ▼
┌────────────────┐  ┌────────────────┐
│ Push to GHCR   │  │ Upload         │
│ ghcr.io/.../   │  │ Artifacts      │
│ - :main        │  │ *.flatpak      │
│ - :sha-abc123  │  │ (7 days)       │
└────────┬───────┘  └────────┬───────┘
         │                   │
         └───────┬───────────┘
                 │
                 ▼
         ┌───────────────────┐
         │ Tests Run          │
         │ - Pull images      │
         │ - Run --version    │
         │ - Basic checks     │
         └───────┬───────────┘
                 │
                 ▼
         ┌───────────────────┐
         │ ✅ Success / ❌ Fail │
         └───────────────────┘
```

**On Release Tag:**

```
┌─────────────────────────────────────────────────────────┐
│  Git tag v1.0.0 pushed                                   │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  release.yml Triggered                                   │
│  1. Create source tarballs                               │
│  2. Create install bundle                                │
│  3. Generate checksums                                   │
│  4. Tag containers: v1.0.0, v1, latest                   │
│  5. Upload Flatpaks to release                           │
│  6. Update documentation                                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│  GitHub Release Created                                  │
│  Assets:                                                 │
│  • vim-ai-assistant-v1.0.0.tar.gz                        │
│  • vim-ai-assistant-install-v1.0.0.tar.gz                │
│  • neovim-ai.flatpak                                     │
│  • vim-ai.flatpak                                        │
│  • checksums.txt                                         │
│                                                          │
│  Containers tagged:                                      │
│  • ghcr.io/.../neovim:v1.0.0                             │
│  • ghcr.io/.../neovim:v1                                 │
│  • ghcr.io/.../neovim:latest                             │
└──────────────────────────────────────────────────────────┘
```

---

## Monitoring Builds

### GitHub Actions

**View Status:**
```bash
# Via web
# https://github.com/<username>/vim-ai-assistant/actions

# Via CLI
gh run list
gh run view <run-id>
gh run watch
```

**Re-run Failed:**
```bash
gh run rerun <run-id>
```

### GitLab CI

**View Pipelines:**
```bash
# Via web
# https://gitlab.com/<username>/vim-ai-assistant/-/pipelines

# Via CLI
glab ci list
glab ci view <pipeline-id>
```

---

## Build Artifacts

### Containers (from CI)

```bash
# Pull from GitHub Container Registry
podman pull ghcr.io/dsedgmen/vim-ai-assistant/neovim:main

# Pull from GitLab Container Registry
podman pull registry.gitlab.com/<username>/vim-ai-assistant/neovim:main

# Use in production
podman run --rm -it -v $(pwd):/workspace:z \
    ghcr.io/dsedgmen/vim-ai-assistant/neovim:latest \
    test.py
```

### Flatpaks (from CI)

```bash
# Download from GitHub Releases
wget https://github.com/dsedgmen/vim-ai-assistant/releases/latest/download/neovim-ai.flatpak

# Install
flatpak install --user neovim-ai.flatpak

# Run
flatpak run org.neovim.Neovim
```

### Source Tarballs (from Releases)

```bash
# Download
wget https://github.com/dsedgmen/vim-ai-assistant/releases/latest/download/vim-ai-assistant-v1.0.0.tar.gz

# Verify checksum
wget https://github.com/dsedgmen/vim-ai-assistant/releases/latest/download/checksums.txt
sha256sum -c checksums.txt

# Extract and install
tar xzf vim-ai-assistant-v1.0.0.tar.gz
cd vim-ai-assistant
./install.sh
```

---

## Troubleshooting CI

### Container Build Fails

**Check logs:**
```bash
gh run view <run-id> --log
```

**Common issues:**
- Base image unavailable: Check Fedora registry
- Build context missing: Verify Containerfile paths
- Out of disk space: GitHub runners have 14GB limit

**Solution:**
```bash
# Test locally first
cd containers/neovim
podman build -t test:local -f Containerfile .
```

### Flatpak Build Fails

**Common issues:**
- Missing dependencies in manifest
- Invalid source URLs
- SHA256 mismatch

**Solution:**
```bash
# Test locally
cd flatpak
flatpak-builder --force-clean build org.neovim.Neovim.yaml
```

### Test Failures

**Check specific job:**
```bash
gh run view <run-id> --log --job=<job-id>
```

**Common issues:**
- Shellcheck warnings: Fix script syntax
- Lua syntax errors: Check .lua files
- Missing test files: Ensure paths are correct

---

## CI Best Practices

### 1. Test Before Push

```bash
# Lint locally
shellcheck install.sh

# Test configs
nvim --headless -c "luafile .config/nvim/init.lua" -c "quit"

# Build containers locally
cd containers/neovim && podman build -t test:local .
```

### 2. Use Cache

Workflows already configured with:
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

Speeds up builds by caching layers.

### 3. Pin Dependencies

In Containerfiles:
```dockerfile
# Don't use
FROM fedora:latest

# Use
FROM registry.fedoraproject.org/fedora:44
```

### 4. Semantic Versioning

Tag releases properly:
```bash
git tag -a v1.2.3 -m "Release 1.2.3"
git push origin v1.2.3
```

CI automatically creates:
- `v1.2.3` - Exact version
- `v1.2` - Minor version
- `v1` - Major version
- `latest` - Latest stable

---

## Summary

**Automated:**
- ✅ Container builds on every push
- ✅ Flatpak builds on every push
- ✅ Testing on every PR
- ✅ Releases on git tags
- ✅ Dependency updates weekly

**Published:**
- 🐳 Containers: `ghcr.io/dsedgmen/vim-ai-assistant/*`
- 📦 Flatpaks: GitHub Releases
- 📄 Source: GitHub Releases

**Monitored:**
- GitHub Actions status badges
- Dependabot PRs
- Test results

CI/CD = Automated quality and distribution! 🚀
