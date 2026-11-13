# Release & version framework

Used by GitHub Actions, Packit, and **COPR webhooks** (`.copr/Makefile`).

## Channels

| Git ref | Channel | Example EVR |
|---------|---------|-------------|
| `main` | beta | `1.0.0-0.<date>git<sha>.beta` |
| `release/*` | rc | `1.0.0-0.<date>git<sha>.rc` |
| tag `vX.Y.Z` / `X.Y.Z` | stable | `X.Y.Z-1` |
| tag `…-rc.N` | rc | `X.Y.Z-0.N.rcNgit<sha>` |

Baseline from [`VERSION`](VERSION).

## COPR

Project webhook → this repo. Package settings:

| Field | Value |
|-------|--------|
| SCM clone | `https://github.com/dsedgmen/devenv-ai-assistant.git` |
| Spec | `devenv-ai-assistant.spec` |
| Method | **make_srpm** |
| Auto-rebuild | on |

RPMs: `devenv-ai-assistant`, `devenv-ai-assistant-neovim`, `devenv-ai-assistant-vim`.

## GitHub Actions

| Workflow | Trigger |
|----------|---------|
| `rpm.yml` | main / release / PRs |
| `release.yml` | version tags |
| `security.yml` | push/PR (+ schedule) |

Tag push creates a GitHub Release with RPM assets.

```bash
git tag -a 1.0.0 -m "devenv-ai-assistant 1.0.0" && git push origin 1.0.0
```
