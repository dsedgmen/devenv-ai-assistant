# LSP and Tree-sitter Setup

Complete LSP (Language Server Protocol) and Tree-sitter setup using **ONLY Fedora system repositories** - no external downloads!

## What You Get

### LSP Servers (from Fedora repos)
- ✅ **Python**: `python-lsp-server` with ruff and black
- ✅ **Go**: `gopls`
- ✅ **Bash**: `bash-language-server`

### Tree-sitter (from Fedora repos)
- ✅ **Core**: `libtree-sitter` + `tree-sitter-cli`
- ✅ **15+ language grammars**: Python, Go, JavaScript, TypeScript, Bash, C, C++, Rust, Java, Ruby, Lua, JSON, YAML, HTML, CSS

### Features
- Code completion as you type
- Go to definition (gd)
- Find references (gr)
- Hover documentation (K)
- Rename refactoring
- Diagnostic errors/warnings
- Syntax highlighting via tree-sitter
- Code folding

## Installation

### Quick Install (Recommended)

```bash
cd ~/vim-ai-assistant
./install-lsp-treesitter.sh
```

This installs all LSP servers and tree-sitter grammars from Fedora repos.

### Manual Install

```bash
# LSP Servers
sudo dnf install -y \
    python3-lsp-server \
    python3-lsp-ruff \
    python3-lsp-black \
    gopls \
    nodejs-bash-language-server

# Tree-sitter
sudo dnf install -y \
    libtree-sitter \
    tree-sitter-cli \
    libtree-sitter-python \
    libtree-sitter-bash \
    libtree-sitter-c \
    libtree-sitter-cpp \
    libtree-sitter-go \
    libtree-sitter-javascript \
    libtree-sitter-typescript \
    libtree-sitter-json \
    libtree-sitter-yaml \
    libtree-sitter-html \
    libtree-sitter-css \
    libtree-sitter-lua \
    libtree-sitter-rust \
    libtree-sitter-java \
    libtree-sitter-ruby
```

### Verify Installation

```bash
# LSP servers
pylsp --help
gopls version
bash-language-server --version

# Tree-sitter
tree-sitter --version
```

## Configuration

Configuration is already added to your neovim setup!

Files:
- `~/.config/nvim/lua/lsp-config.lua` - LSP configuration
- `~/.config/nvim/lua/treesitter-config.lua` - Tree-sitter configuration
- `~/.config/nvim/init.lua` - Loads both automatically

## LSP Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find references |
| `K` | Hover documentation |

### Editing
| Key | Action |
|-----|--------|
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format document |
| `<C-Space>` | Trigger completion (insert mode) |

### Diagnostics
| Key | Action |
|-----|--------|
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>e` | Show diagnostic float |
| `<leader>q` | Show diagnostic list |

## Usage Examples

### Python

```python
# Open a Python file
nvim test.py

# Type code - LSP provides:
def my_function(x: int) -> int:
    return x + 1

# Press 'K' on a function -> hover docs
# Press 'gd' on a variable -> go to definition
# Errors shown with red squiggles
# <C-Space> for completion
```

### Go

```go
// Open a Go file
nvim main.go

// LSP provides completion, go-to-def, formatting
package main

func main() {
    // Press K on 'Println' -> see docs
    fmt.Println("Hello")
}
```

### Bash

```bash
# Open a bash script
nvim script.sh

# LSP helps with shellcheck, completion
#!/bin/bash
echo "Hello"  # Hover, completion, diagnostics
```

## How LSP and AI Work Together

They complement each other:

| Feature | LSP | AI Assistant |
|---------|-----|--------------|
| **Instant feedback** | ✅ Syntax errors | ❌ Slower |
| **Completion** | ✅ As you type | ✅ Intelligent |
| **Logic bugs** | ❌ Limited | ✅ Understands intent |
| **Refactoring** | ✅ Rename | ✅ Complex rewrites |
| **Offline** | ✅ Yes | ✅ Ollama: Yes |

### Typical Workflow

1. **LSP** shows syntax error instantly
   ```
   def my_func(  # LSP: Missing closing paren
   ```

2. **Fix syntax** - LSP happy
   ```python
   def my_func(x):
       a = b  # LSP: OK (doesn't catch logic error)
   ```

3. **AI** catches logic error
   ```vim
   Select code, press <Space>ax
   AI: "Variable 'b' is undefined, fixing..."
   ```

## Tree-sitter Features

- **Better syntax highlighting** - More accurate than regex
- **Code folding** - Fold functions, classes
- **Incremental parsing** - Fast, even on large files

Enabled automatically for supported file types.

## Troubleshooting

### LSP not starting

```vim
:lua print(vim.inspect(vim.lsp.get_active_clients()))
```

Should show active LSP clients. If empty:

```bash
# Check LSP server is installed
which pylsp gopls bash-language-server

# Check for errors
nvim --startuptime startup.log test.py
cat startup.log | grep -i error
```

### Tree-sitter not working

```vim
:lua vim.treesitter.start()
```

If error about missing parsers:

```bash
# Verify grammars are installed
rpm -qa | grep tree-sitter

# Should see libtree-sitter-python, etc.
```

### Slow completion

LSP is usually instant. If slow:
- Disable AI completion: Just use LSP
- LSP: `<C-Space>` or `<C-x><C-o>`
- AI: `<Space>ac` (for intelligent completion)

## Adding More Languages

Check what's available:

```bash
dnf search tree-sitter | grep libtree
dnf search language-server
```

Examples:

```bash
# Rust
sudo dnf install libtree-sitter-rust

# TypeScript (already in our install)
sudo dnf install libtree-sitter-typescript

# More LSP servers
dnf search lsp | grep server
```

## System-Only Policy

Everything installed from Fedora repos:
- ✅ LSP servers: Fedora packages
- ✅ Tree-sitter: Fedora packages
- ✅ Grammars: System libraries
- ❌ No npm global installs
- ❌ No cargo installs
- ❌ No downloading parsers

Advantages:
- Security: Signed RPMs only
- Updates: Via dnf
- Reproducible: Same on all Fedora systems
- Air-gap friendly: No internet needed after install

## Performance

- **LSP**: Instant (<10ms for completion)
- **Tree-sitter**: Fast incremental parsing
- **AI**: 1-10 seconds (depending on backend)

Use LSP for instant feedback while coding.
Use AI for intelligent assistance when needed.

## What's Not Included

Some language servers not in Fedora repos:
- TypeScript (tsserver) - Would need npm
- Rust (rust-analyzer) - Would need cargo
- Lua (lua-language-server) - Not packaged

Workarounds:
- **TypeScript**: Tree-sitter still works for highlighting
- **Rust**: Tree-sitter highlighting, use AI for assistance  
- **Lua**: Tree-sitter highlighting available

We prioritize the constraint: **system repos only**.

## Comparison Table

| Language | LSP Available | Tree-sitter Available |
|----------|---------------|----------------------|
| Python | ✅ python-lsp-server | ✅ libtree-sitter-python |
| Go | ✅ gopls | ✅ libtree-sitter-go |
| Bash | ✅ bash-language-server | ✅ libtree-sitter-bash |
| JavaScript | ❌ (needs npm) | ✅ libtree-sitter-javascript |
| TypeScript | ❌ (needs npm) | ✅ libtree-sitter-typescript |
| Rust | ❌ (needs cargo) | ✅ libtree-sitter-rust |
| C/C++ | ❌ (clangd complex) | ✅ libtree-sitter-c/cpp |
| Java | ❌ (eclipse complex) | ✅ libtree-sitter-java |
| Ruby | ❌ (solargraph not in repos) | ✅ libtree-sitter-ruby |

Even without LSP, you get:
- Tree-sitter highlighting
- AI assistance
- Basic vim features

## Next Steps

1. Run the install script
2. Open a Python file
3. Try LSP keybindings (gd, K, gr)
4. See errors/warnings appear automatically
5. Use AI for complex tasks (<Space>ax, <Space>aq)

Enjoy your enhanced vim/neovim setup!
