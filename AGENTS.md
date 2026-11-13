# Agent guide — devenv-ai-assistant

## Purpose

Vim/Neovim **AI keymaps** that call `devenv-ai-helper`. Shallow root layout
(editor configs at the repo root; not a temporary “pre-public” state):

| File | Role |
|------|------|
| `nvim-init.lua` | Neovim AI commands/maps + soft-requires optional Lua modules |
| `vimrc` | Vim AI commands/maps (no ALE; that is devenv-lsp-setup) |
| `rpm/*.lua` / `rpm/*.vim` | Non-destructive RPM loaders (packpath / vimfiles) |
| `devenv-ai-assistant.spec` | Shared RPM + `-neovim` / `-vim` subpackages |
| `install.sh` | User-home install; resolve helper (not used by RPM) |
| `devenv-ai-setup.sh` | Optional Ollama/Python clients |
| `QUICKREF.txt` / `README.md` / `GEMINI_SETUP.md` | Docs |

COPR: `dsedgmen/devenv` → `dnf install devenv-ai-assistant-neovim` /
`devenv-ai-assistant-vim`. Versioning mirrors helper (`VERSION`,
`scripts/rpm-version.sh`, `.copr/Makefile`, Packit).

## Constraints

1. Editor AI only — do not re-vendor helper, lsp-setup, flowchart, or packaging.
2. Keep CLI subcommands: `complete`, `explain`, `review`, `refactor`, `generate`, `chat`.
3. Prefer `DEVENV_AI_*`; accept `VIM_AI_*` fallback.
4. Soft-require `lsp-config` / `treesitter-config` / `code-flowchart` / `plugins-config`
   (`code-flowchart` from devenv-code-flowchart; LSP/TS from devenv-lsp-setup).
5. No secrets or live prompts in git; no third-party AI calls in CI.
6. RPM must not overwrite `~/.vimrc` or `~/.config/nvim/init.lua`.
7. Spec macros `devenv_ai_ver` / `devenv_ai_rel` — do not hardcode Version for CI.

## Verify

- `bash -n install.sh devenv-ai-setup.sh`
- `vim -Nu vimrc -e -s -c quit` when available (ex+silent; avoids hit-enter)
- `./scripts/rpm-version.sh --shell` and local `rpmbuild -ba` when changing packaging
