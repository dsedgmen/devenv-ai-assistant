# Vim & Neovim Plugin Guide

Comprehensive guide to productivity plugins available from Fedora repos.

## Quick Install

```bash
# For Vim
./install-vim-plugins.sh

# For Neovim
./install-nvim-plugins.sh
```

Both scripts install the same plugins - they work in **both** vim and neovim!

---

## Installed Plugins

### 1. **vim-fugitive** - Git Integration ⭐⭐⭐⭐⭐

**What it does:**
- Complete git workflow inside vim/neovim
- Commit, push, pull, blame, log without leaving editor
- Visual merge conflict resolution
- Stage/unstage changes interactively

**Keybindings:**
| Key | Action |
|-----|--------|
| `<Space>gs` | Git status |
| `<Space>gc` | Git commit |
| `<Space>gp` | Git push |
| `<Space>gl` | Git log |
| `<Space>gb` | Git blame |
| `<Space>gd` | Git diff |

**Common Commands:**
```vim
:Git status          " Show git status
:Git commit          " Commit staged changes
:Git push            " Push to remote
:Git blame           " Show blame for current file
:Git log             " View commit history
:Gwrite              " Stage current file (git add)
:Gread               " Unstage current file
```

**Use Cases:**
- Quick commits without terminal
- Review blame while editing
- Resolve merge conflicts visually
- Browse git history

---

### 2. **vim-gitgutter** - Git Diff in Gutter ⭐⭐⭐⭐⭐

**What it does:**
- Shows `+`, `~`, `-` signs next to changed lines
- Preview/stage/undo changes hunk by hunk
- Jump between changes quickly

**Visual Indicators:**
```
  + = Added line (green)
  ~ = Modified line (yellow)
  - = Deleted line (red)
```

**Keybindings:**
| Key | Action |
|-----|--------|
| `]c` | Next change (hunk) |
| `[c` | Previous change |
| `<Space>hp` | Preview hunk |
| `<Space>hs` | Stage hunk |
| `<Space>hu` | Undo hunk |

**Use Cases:**
- See what changed at a glance
- Stage specific changes (not whole file)
- Review changes before committing
- Undo accidental edits

---

### 3. **vim-nerdtree** - File Explorer ⭐⭐⭐⭐

**What it does:**
- Tree-view file browser sidebar
- Navigate project structure visually
- Create/delete/rename files from tree
- Bookmarks for frequent locations

**Keybindings:**
| Key | Action |
|-----|--------|
| `Ctrl-N` | Toggle NERDTree sidebar |

**Inside NERDTree:**
| Key | Action |
|-----|--------|
| `Enter` | Open file/directory |
| `o` | Open in horizontal split |
| `s` | Open in vertical split |
| `t` | Open in new tab |
| `m` | Menu (create/delete/rename) |
| `I` | Toggle hidden files |
| `?` | Help |

**Use Cases:**
- Browse project structure
- Quick file operations
- Visual navigation (like IDE sidebar)

---

### 4. **vim-ctrlp** - Fuzzy File Finder ⭐⭐⭐⭐⭐

**What it does:**
- Fuzzy search any file in project
- Type partial name → instant match
- Like VSCode's `Cmd-P` or Sublime's `Ctrl-P`

**Keybindings:**
| Key | Action |
|-----|--------|
| `Ctrl-P` | Open fuzzy finder |

**Inside CtrlP:**
| Key | Action |
|-----|--------|
| Type | Filter files |
| `Ctrl-J/K` | Navigate results |
| `Enter` | Open file |
| `Ctrl-T` | Open in new tab |
| `Ctrl-V` | Open in vertical split |

**Examples:**
```
Type: "install" → finds install.sh, install-lsp.sh, etc.
Type: "nvim/init" → finds ~/.config/nvim/init.lua
Type: "readme" → finds README.md
```

**Use Cases:**
- Fastest way to open files
- No need to remember full paths
- Jump between files instantly

---

### 5. **vim-commentary** - Quick Commenting ⭐⭐⭐⭐

**What it does:**
- Comment/uncomment code with one key
- Auto-detects language (Python `#`, C `//`, etc.)
- Works on lines or selections

**Keybindings:**
| Key | Action |
|-----|--------|
| `gcc` | Comment/uncomment current line |
| `gc` (visual) | Comment/uncomment selection |
| `gcap` | Comment paragraph |

**Examples:**
```python
# Before: press gcc on this line
result = calculate_something()

# After:
# result = calculate_something()

# Press gcc again → uncomments
```

**Use Cases:**
- Quick debugging (comment out code)
- Toggle comments instantly
- Works with all languages

---

### 6. **vim-rhubarb** - GitHub Integration

**What it does:**
- Open GitHub URLs from vim
- Works with vim-fugitive
- `:GBrowse` on line → opens GitHub at that line

**Use Cases:**
- Share GitHub links to specific lines
- Open PR/issue from vim

---

### 7. **vim-trailing-whitespace** - Whitespace Management

**What it does:**
- Highlights trailing whitespace
- Auto-removes on save

**Commands:**
```vim
:FixWhitespace       " Remove all trailing whitespace
```

**Use Cases:**
- Clean commits (no whitespace noise)
- Automatic cleanup

---

### 8. **vim-powerline** - Enhanced Status Bar

**What it does:**
- Beautiful status line
- Shows git branch, file info, position
- Visual mode indicators

**Use Cases:**
- See git branch at a glance
- Better visual feedback

---

## Complete Feature Matrix

| Feature | Vim | Neovim |
|---------|-----|--------|
| **Git - Status/Commit/Push** | ✅ fugitive | ✅ fugitive |
| **Git - Diff in Gutter** | ✅ gitgutter | ✅ gitgutter |
| **File Explorer** | ✅ NERDTree | ✅ NERDTree |
| **Fuzzy Finder** | ✅ CtrlP | ✅ CtrlP |
| **Quick Comments** | ✅ commentary | ✅ commentary |
| **LSP** | ✅ ALE | ✅ Built-in |
| **AI (Ollama/Claude/Gemini)** | ✅ | ✅ |
| **Tree-sitter** | ❌ | ✅ |

**Both editors now have complete IDE features!**

---

## Installation Details

### What Gets Installed

```bash
# These packages (all from Fedora repos):
vim-fugitive              # Git integration
vim-gitgutter             # Git diff signs
vim-nerdtree              # File tree
vim-ctrlp                 # Fuzzy finder
vim-commentary            # Quick commenting
vim-rhubarb               # GitHub integration
vim-trailing-whitespace   # Whitespace cleanup
vim-powerline             # Status bar
```

### Where Configs Go

**Vim:**
- Plugins: System-wide (`/usr/share/vim/vimfiles/`)
- Config: `~/.vimrc` (updated by script)

**Neovim:**
- Plugins: System-wide (same as vim)
- Config: `~/.config/nvim/lua/plugins-config.lua` (created by script)
- Loaded by: `~/.config/nvim/init.lua`

---

## Common Workflows

### Workflow 1: Quick Code Change + Commit

```
1. nvim file.py
2. Make changes
3. Press ]c to see what changed (gitgutter)
4. Press <Space>gs → Git status (fugitive)
5. Press <Space>gc → Git commit
6. Write message, save, quit
7. Press <Space>gp → Git push
```

### Workflow 2: Browse + Edit Project

```
1. nvim
2. Press Ctrl-N → NERDTree file browser
3. Navigate tree, press Enter to open
4. Edit file
5. Press Ctrl-P → fuzzy find another file
6. Type partial name → open instantly
```

### Workflow 3: Review Changes Before Commit

```
1. Make changes across multiple files
2. See + ~ - signs in gutter (gitgutter)
3. Press ]c / [c to navigate changes
4. Press <Space>hp to preview each hunk
5. Press <Space>hs to stage good hunks
6. Press <Space>hu to undo bad changes
7. Press <Space>gc to commit staged hunks
```

### Workflow 4: Git Blame Investigation

```
1. Open file with bug
2. Press <Space>gb → Git blame
3. See who changed each line
4. Press Enter on line → see commit details
5. Press <Space>gl → see full history
```

---

## Troubleshooting

### Plugin not loading

Check if installed:
```bash
rpm -qa | grep vim-fugitive
```

Re-source config:
```vim
:source ~/.vimrc          " vim
:source ~/.config/nvim/init.lua   " neovim
```

### NERDTree shows nothing

Navigate to project directory first:
```bash
cd ~/vim-ai-assistant
nvim
# Then press Ctrl-N
```

### CtrlP doesn't find files

Clear cache:
```vim
:CtrlPClearCache
```

### GitGutter signs don't show

Ensure you're in a git repo:
```bash
cd ~/vim-ai-assistant   # git repo
nvim file.py
# Make changes → signs appear
```

---

## Why These Plugins?

### All from Fedora Repos ✅
- No external downloads
- No `npm install` / `pip install`
- Signed RPM packages
- Updates via `dnf`
- Air-gap friendly

### Work in Both Editors ✅
- Same plugins for vim & neovim
- Consistent keybindings
- Shared muscle memory

### Essential Productivity ✅
- Git without terminal switching
- Fast file navigation
- Visual project browsing
- Quick commenting

---

## What You Have Now

### Complete IDE Setup

**Code Intelligence:**
- ✅ LSP (definitions, hover, completion)
- ✅ Tree-sitter (syntax highlighting)
- ✅ AI assistance (3 backends)

**Git Integration:**
- ✅ Commit/push/pull from editor
- ✅ Visual diff in gutter
- ✅ Blame and history
- ✅ Hunk staging

**Navigation:**
- ✅ Fuzzy file finder (Ctrl-P)
- ✅ File tree browser (Ctrl-N)
- ✅ Jump to definition (gd)
- ✅ Find references (gr)

**Editing:**
- ✅ Quick commenting (gcc)
- ✅ AI code generation
- ✅ AI refactoring
- ✅ Whitespace cleanup

**All from system repos, no external dependencies!**

---

## Next Steps

1. **Install the plugins:**
   ```bash
   cd ~/vim-ai-assistant
   ./install-vim-plugins.sh      # For vim
   ./install-nvim-plugins.sh     # For neovim
   ```

2. **Test key features:**
   ```bash
   nvim ~/vim-ai-assistant
   # Try Ctrl-P → fuzzy find
   # Try Ctrl-N → file tree
   # Try <Space>gs → git status
   ```

3. **Learn keybindings:**
   - Start with Ctrl-P and Ctrl-N
   - Add git commands (<Space>gs, etc.)
   - Use gitgutter navigation (]c, [c)

4. **Customize further:**
   - Edit `~/.vimrc` for vim
   - Edit `~/.config/nvim/lua/plugins-config.lua` for neovim

---

## Comparison: Before vs After

### Before Plugins

```
- Manual git commands in terminal
- cd and ls to find files
- Remember full file paths
- Switch between terminal and editor
- Manual commenting
```

### After Plugins

```
- Git ops inside editor (<Space>gs, gc, gp)
- Fuzzy find any file (Ctrl-P)
- Visual file tree (Ctrl-N)
- See changes in gutter (+ ~ -)
- Quick commenting (gcc)
- Stay in flow!
```

---

**Your vim/neovim is now a complete modern IDE!** 🚀

Built entirely from Fedora repos, no external dependencies, full feature parity with commercial IDEs.
