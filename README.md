# devenv-ai-assistant

[![Test](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/test.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/test.yml)
[![RPM](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/rpm.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/rpm.yml)
[![Security](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/security.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/security.yml)
[![Release](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/release.yml/badge.svg)](https://github.com/dsedgmen/devenv-ai-assistant/actions/workflows/release.yml)
[![COPR](https://copr.fedorainfracloud.org/coprs/dsedgmen/devenv/package/devenv-ai-assistant/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/dsedgmen/devenv/package/devenv-ai-assistant/)
[![GitHub release](https://img.shields.io/github/v/release/dsedgmen/devenv-ai-assistant?include_prereleases)](https://github.com/dsedgmen/devenv-ai-assistant/releases)

Vim/Neovim editor configs for AI-assisted coding (complete, explain, review,refactor, generate, chat). Calls the external
[devenv-ai-helper](https://github.com/dsedgmen/devenv-ai-helper) CLI.

LSP, Tree-sitter, and productivity plugins live in
[devenv-lsp-setup](https://github.com/dsedgmen/devenv-lsp-setup).
Offline call-graph flowcharts live in
[devenv-code-flowchart](https://github.com/dsedgmen/devenv-code-flowchart).
Container images and Flatpak live in
[devenv-packager](https://github.com/dsedgmen/devenv-packager).

## Features

- Code completion, explanation, review, refactor, generate, chat
- Backends via helper: Ollama, Claude, Gemini, OpenAI-compatible (internal APIs)
- Async AI in Neovim; apply preview for complete/refactor/generate
- Soft-loads optional LSP/Treesitter (devenv-lsp-setup) and flowchart (devenv-code-flowchart)

## Install (Fedora COPR)

Non-destructive RPMs — they load via Neovim packpath / Vim vimfiles and do
**not** overwrite `~/.config/nvim/init.lua` or `~/.vimrc`:

```bash
sudo dnf copr enable dsedgmen/devenv
sudo dnf install devenv-ai-helper
# Neovim and/or Vim AI configs:
sudo dnf install devenv-ai-assistant-neovim
sudo dnf install devenv-ai-assistant-vim
```

Shared configs land in `/usr/share/devenv-ai-assistant/`.

## Dependencies

1. **devenv-ai-helper** — Fedora COPR RPM, PATH install, or sibling clone  
   https://github.com/dsedgmen/devenv-ai-helper  
2. Optional: `ollama`, `python3-ollama`, `python3-openai` (Fedora repos)
3. Optional: [devenv-lsp-setup](https://github.com/dsedgmen/devenv-lsp-setup) for LSP/TS
4. Optional: [devenv-code-flowchart](https://github.com/dsedgmen/devenv-code-flowchart) for `<Space>mf` / `<Space>mF`

```bash
# Helper only (if not using the COPR block above)
git clone https://github.com/dsedgmen/devenv-ai-helper.git ../devenv-ai-helper
```

## Repo layout

```text
nvim-init.lua              Neovim AI maps/commands
vimrc                      Vim AI maps/commands
rpm/neovim-plugin.lua      RPM packpath loader
rpm/vim-plugin.vim         RPM vimfiles loader
devenv-ai-assistant.spec   Fedora RPM (neovim + vim subpackages)
install.sh                 User-home install + resolve helper
devenv-ai-setup.sh         Optional Ollama / Python clients
QUICKREF.txt               Keymap card
GEMINI_SETUP.md            Gemini notes
```

## Quick start (from git)

```bash
git clone https://github.com/dsedgmen/devenv-ai-assistant.git
cd devenv-ai-assistant
./install.sh
~/.config/devenv-ai-setup.sh   # optional: Ollama + Python clients + model

# Optional LSP / Treesitter / plugins
git clone https://github.com/dsedgmen/devenv-lsp-setup.git ../devenv-lsp-setup
(cd ../devenv-lsp-setup && ./install.sh && ./install-lsp-treesitter.sh)

# Optional offline flowchart
git clone https://github.com/dsedgmen/devenv-code-flowchart.git ../devenv-code-flowchart
(cd ../devenv-code-flowchart && ./install.sh)
```

`install.sh` resolves the helper from `DEVENV_AI_HELPER_DIR` (or `VIM_AI_HELPER_DIR`),
sibling `../devenv-ai-helper`, PATH / RPM, then `~/.local/bin` when needed.
Prefer the COPR packages above when you want system-wide configs without
touching your personal init files.

## Usage

Leader key: **Space**.

### Normal mode

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<Space>ac` | `:AIComplete` | Complete code from cursor |
| `<Space>ar` | `:AIReview` | Review entire file |
| `<Space>ag` | `:AIGenerate` | Generate code from description |
| `<Space>aq` | `:AIChat` | Ask AI a question |
| `<Space>ab` | `:AISwitchBackend` | Toggle backends |

### Visual mode

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<Space>ae` | `:AIExplain` | Explain selection |
| `<Space>ar` | `:AIReview` | Review selection |
| `<Space>af` | `:AIRefactor` | Refactor selection |
| `<Space>aq` | `:AIChat` | Ask about selection |

Flowchart maps (`<Space>mf` / `<Space>mF`) require
[devenv-code-flowchart](https://github.com/dsedgmen/devenv-code-flowchart)
(and Treesitter from devenv-lsp-setup).

See [QUICKREF.txt](QUICKREF.txt) for the full map.

## Configuration

Backends and routing are owned by **devenv-ai-helper**. Common env vars
(prefer `DEVENV_AI_*`; `VIM_AI_*` still accepted as fallback):

```bash
export DEVENV_AI_BACKEND=ollama                    # ollama | claude | gemini | openai
export DEVENV_AI_OLLAMA_MODEL=granite-code:latest
export PATH="$HOME/.local/bin:$PATH"

# Internal OpenAI-compatible gateway
export DEVENV_AI_BACKEND=openai
export DEVENV_AI_BASE_URL=https://llm.internal.example/v1
export DEVENV_AI_API_KEY=your-token
```

Agent routing (`agents`, `route`, `DEVENV_AI_ROUTE_*`): see the
[devenv-ai-helper README](https://github.com/dsedgmen/devenv-ai-helper).

## Containers / Flatpak

Built from [devenv-packager](https://github.com/dsedgmen/devenv-packager):

```bash
podman pull ghcr.io/dsedgmen/devenv-packager/neovim:latest
```

## Related projects

| Project | Role |
|---------|------|
| [devenv-ai-helper](https://github.com/dsedgmen/devenv-ai-helper) | AI CLI + RPM |
| [devenv-lsp-setup](https://github.com/dsedgmen/devenv-lsp-setup) | LSP + Tree-sitter + plugins |
| [devenv-packager](https://github.com/dsedgmen/devenv-packager) | Images + Flatpak |
| [devenv](https://github.com/dsedgmen/devenv) | Stages this repo + helper + lsp-setup |

Agent guidance: [AGENTS.md](AGENTS.md).
